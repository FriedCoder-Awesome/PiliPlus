import 'package:PiliPlus/common/skeleton/video_card_v.dart';
import 'package:PiliPlus/common/sliver_single_child_delegate.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/video_card/video_card_v.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/rcmd/controller.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class RcmdPage extends StatefulWidget {
  const RcmdPage({super.key});

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.put(RcmdController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = ColorScheme.of(context);
    final child = Container(
      clipBehavior: .hardEdge,
      margin: const .symmetric(horizontal: Style.safeSpace / 2),
      decoration: const BoxDecoration(borderRadius: Style.feedCardBorderRadius),
      child: refreshIndicator(
        key: controller.refreshKey,
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const .only(top: Style.cardSpace / 2, bottom: 100),
              sliver: Obx(
                () => _buildBody(colorScheme, controller.loadingState.value),
              ),
            ),
          ],
        ),
      ),
    );
    if (PlatformUtils.isDesktop && Pref.showRefreshFAB) {
      return ScaffoldLayout(
        body: child,
        fab: Padding(
          padding: const .only(
            right: kFloatingActionButtonMargin,
            bottom: 80 + kFloatingActionButtonMargin,
          ),
          child: FloatingActionButton(
            tooltip: '刷新',
            onPressed: controller.toTopAndRefresh,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: const Icon(Icons.refresh),
          ),
        ),
      );
    }
    return child;
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace / 2,
    crossAxisSpacing: Style.cardSpace / 2,
    maxCrossAxisExtent: Pref.recommendCardWidth,
    childAspectRatio: VideoCardV.coverAspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(72),
  );

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<BaseRcmdVideoItemModel>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => _buildSkeleton,
      Success(:final response) when response != null && response.isNotEmpty =>
        _buildFeed(response, colorScheme),
      Success() => HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }

  Widget _buildFeed(List<BaseRcmdVideoItemModel> items, ColorScheme colors) {
    SliverGrid grid(int start, int end) => SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemCount: end - start,
      itemBuilder: (context, index) {
        final position = start + index;
        if (position == items.length - 1) controller.onLoadMore();
        final item = items[position];
        return VideoCardV(
          videoItem: item,
          onRemove: () => controller.removeVideo(item),
        );
      },
    );

    final boundary = controller.lastRefreshAt;
    if (boundary == null || boundary <= 0 || boundary >= items.length) {
      return grid(0, items.length);
    }
    return SliverMainAxisGroup(
      slivers: [
        grid(0, boundary),
        SliverToBoxAdapter(
          child: TextButton(
            onPressed: controller.toTopAndRefresh,
            style: TextButton.styleFrom(
              foregroundColor: colors.vipColor,
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Row(
              mainAxisAlignment: .center,
              mainAxisSize: .min,
              children: [
                Flexible(child: Text('刚刚看到这里，点击刷新')),
                SizedBox(width: 8),
                Icon(Icons.sync, size: 16),
              ],
            ),
          ),
        ),
        grid(boundary, items.length),
      ],
    );
  }

  Widget get _buildSkeleton => SliverGrid(
    gridDelegate: gridDelegate,
    delegate: const SliverSingleChildDelegate(
      count: 10,
      child: VideoCardVSkeleton(
        showStatRow: false,
        coverAspectRatio: VideoCardV.coverAspectRatio,
        coverCorner: Style.feedCardCorner,
      ),
    ),
  );
}
