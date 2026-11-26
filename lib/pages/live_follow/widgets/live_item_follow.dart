import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models_new/live/live_follow/item.dart';
import 'package:PiliPlus/pages/live/widgets/live_card_details.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:material_ui/material_ui.dart';

// 视频卡片 - 垂直布局
class LiveCardVFollow extends StatelessWidget {
  final LiveFollowItem liveItem;

  const LiveCardVFollow({
    super.key,
    required this.liveItem,
  });

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(
      title: liveItem.title,
      cover: liveItem.roomCover,
    );
    return Card(
      shape: Style.feedCardShape,
      child: InkWell(
        onTap: () => PageUtils.toLiveRoom(liveItem.roomid),
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        customBorder: Style.feedCardShape,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            AspectRatio(
              aspectRatio: Style.aspectRatio,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  double maxWidth = boxConstraints.maxWidth;
                  double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        src: liveItem.roomCover!,
                        width: maxWidth,
                        height: maxHeight,
                        borderRadius: const .vertical(top: Style.feedCardCorner),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: videoStat(),
                      ),
                    ],
                  );
                },
              ),
            ),
            LiveCardDetails(title: liveItem.title, author: liveItem.uname),
          ],
        ),
      ),
    );
  }

  Widget videoStat() {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(top: 26, left: 10, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black54,
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            liveItem.areaName.toString(),
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          if (liveItem.textSmall case final textSmall?)
            Text(
              '$textSmall围观',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
