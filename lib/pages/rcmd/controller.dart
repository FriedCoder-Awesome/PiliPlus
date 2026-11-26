import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/rcmd_source.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/common/common_controller.dart'
    show RefreshImplMixin;
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

class RcmdController
    extends
        CommonListController<
          List<BaseRcmdVideoItemModel>,
          BaseRcmdVideoItemModel
        >
    with RefreshImplMixin {
  late bool enableSaveLastData = Pref.enableSaveLastData;

  /// 可在设置页切换后立即生效，无需重启
  RcmdSource rcmdSource = Pref.rcmdSource;

  // Carry a filtered page's unpaired item into the next batch from the same source.
  BaseRcmdVideoItemModel? _unpaired;
  RcmdSource? _unpairedSource;
  late RcmdSource _requestSource;
  Future<void>? _request;

  int? lastRefreshAt;
  late bool savedRcmdTip = Pref.savedRcmdTip;

  @override
  bool get isEnd => false;

  @override
  void onInit() {
    super.onInit();
    page = 0;
    queryData();
  }

  @override
  Future<LoadingState<List<BaseRcmdVideoItemModel>>> customGetData() {
    _requestSource = rcmdSource;
    return switch (_requestSource) {
      RcmdSource.app => VideoHttp.rcmdVideoListApp(freshIdx: page, ps: 10),
      RcmdSource.desktop => VideoHttp.rcmdVideoList(
        freshIdx: page,
        ps: 30,
        desktop: true,
      ),
      RcmdSource.web => VideoHttp.rcmdVideoList(freshIdx: page, ps: 20),
    };
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    return _request ??= super.queryData(isRefresh).whenComplete(() {
      isLoading = false;
      _request = null;
    });
  }

  @override
  bool handleError(String? errMsg) {
    return enableSaveLastData &&
        loadingState.value.dataOrNull?.isNotEmpty == true;
  }

  @override
  void handleListResponse(List<BaseRcmdVideoItemModel> dataList) {
    final carry = _unpaired;
    if (carry != null && _unpairedSource == _requestSource) {
      final alreadyIncluded = dataList.any(
        (item) =>
            item.goto == carry.goto &&
            (carry.aid != null && item.aid == carry.aid ||
                carry.bvid != null && item.bvid == carry.bvid),
      );
      if (!alreadyIncluded) dataList.insert(0, carry);
    }
    _unpaired = dataList.length.isOdd ? dataList.removeLast() : null;
    _unpairedSource = _requestSource;

    if (page != 0) return;
    lastRefreshAt = null;
    final previous = loadingState.value.dataOrNull;
    if (enableSaveLastData && previous != null && previous.isNotEmpty) {
      if (savedRcmdTip && dataList.isNotEmpty) lastRefreshAt = dataList.length;
      dataList.addAll(previous.length > 200 ? previous.take(50) : previous);
    }
  }

  void removeVideo(BaseRcmdVideoItemModel item) {
    final items = loadingState.value.dataOrNull;
    if (items == null) return;
    final index = items.indexOf(item);
    if (index == -1) return;
    items.removeAt(index);
    if (lastRefreshAt case final boundary?) {
      final updated = index < boundary ? boundary - 1 : boundary;
      lastRefreshAt = updated > 0 && updated < items.length ? updated : null;
    }
    loadingState.refresh();
  }

  @override
  Future<void> onRefresh() async {
    await _request;
    final previousPage = page;
    page = 0;
    await queryData();
    if (page == 0) page = previousPage;
  }

  @override
  Future<void> onReload() async {
    await _request;
    return super.onReload();
  }

  void toTopAndRefresh() {
    scrollController.jumpToTop();
    showRefresh();
  }
}
