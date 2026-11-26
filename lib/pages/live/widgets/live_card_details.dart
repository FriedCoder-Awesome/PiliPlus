import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:material_ui/material_ui.dart';

class LiveCardDetails extends StatelessWidget {
  const LiveCardDetails({
    super.key,
    required this.title,
    required this.author,
    this.showMenu = false,
  });

  final String? title;
  final String? author;
  final bool showMenu;

  static const _padding = EdgeInsets.fromLTRB(6, 5, 6, 5);

  static TextStyle _titleStyle(ThemeData theme) =>
      theme.textTheme.bodyMedium!.copyWith(height: 1.38);

  static TextStyle _authorStyle(ThemeData theme) => theme.textTheme.labelMedium!
      .copyWith(height: 1.5, color: theme.colorScheme.outline);

  static SliverGridDelegateWithExtentAndRatio gridDelegate(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    double measure(String text, TextStyle style) {
      painter.text = TextSpan(text: text, style: style);
      painter.layout();
      return painter.height.ceilToDouble();
    }

    final titleHeight = measure('播\n播', _titleStyle(theme));
    final authorHeight = measure('播', _authorStyle(theme));
    painter.dispose();
    return SliverGridDelegateWithExtentAndRatio(
      mainAxisSpacing: Style.cardSpace / 2,
      crossAxisSpacing: Style.cardSpace / 2,
      maxCrossAxisExtent: Grid.smallCardWidth,
      childAspectRatio: Style.aspectRatio,
      mainAxisExtent: _padding.vertical + titleHeight + authorHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Text(
                title ?? '',
                style: _titleStyle(theme),
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: showMenu ? 22 : 0),
              child: Text(
                author ?? '',
                style: _authorStyle(theme),
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
