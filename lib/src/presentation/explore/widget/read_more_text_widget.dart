import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';

import 'package:url_launcher/url_launcher.dart';

class ReadMoreTextWidget extends StatelessWidget {
  const ReadMoreTextWidget({
    super.key,
    required this.title,
    this.trimLines = 5,
  });

  final String title;
  final int? trimLines;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      title,
      trimLines: trimLines!,
      colorClickableText: AppColor.orangeColor,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'Read More',
      trimExpandedText: 'Read Less',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 0.5,
            height: 2, 
          ),
      moreStyle: const TextStyle(
        color: AppColor.orangeColor,
        fontWeight: FontWeight.bold,
      ),
      lessStyle: const TextStyle(
        color: AppColor.orangeColor,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class SeeMoreTextWidget extends StatefulWidget {
  final String title;

  const SeeMoreTextWidget({super.key, required this.title});

  @override
  State<SeeMoreTextWidget> createState() => _SeeMoreTextWidgetState();
}

class _SeeMoreTextWidgetState extends State<SeeMoreTextWidget> {
  bool _expanded = false;
  bool _isOverflowing = false;
  final int _trimLines = 5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final linkColor = isDark ? Colors.lightBlueAccent : Colors.blue;

    final TextStyle? normalTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 14.sp, height: 1.8, color: textColor
    );

    final TextStyle? linkTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 14.sp, height: 1.8, color: linkColor, decoration: TextDecoration.underline
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          children: _buildTextSpans(widget.title, normalTextStyle!, linkTextStyle!),
        );

        final tp = TextPainter(
          text: span,
          maxLines: _trimLines,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
        )..layout(maxWidth: constraints.maxWidth);

        _isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(0, -2),
              child: SelectionArea(
                child: Text.rich(
                  span,
                  maxLines: _expanded ? null : _trimLines,
                  textAlign: TextAlign.justify,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
              ),
            ),
            if (_isOverflowing)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _expanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: AppColor.orangeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<InlineSpan> _buildTextSpans(
    String text,
    TextStyle normalStyle,
    TextStyle linkStyle,
  ) {
    final regex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = regex.allMatches(text);

    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: normalStyle,
        ));
      }

      final url = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: url,
        style: linkStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: normalStyle,
      ));
    }

    return spans;
  }
}
