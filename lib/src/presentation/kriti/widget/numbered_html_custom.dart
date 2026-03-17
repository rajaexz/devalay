import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NumberedHtmlListRenderer extends StatelessWidget {
  final String htmlContent;

  const NumberedHtmlListRenderer({
    super.key,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _parseHtmlToList(htmlContent);

    if (steps.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}. ",
                style: Theme.of(context).textTheme.bodyMedium
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<String> _parseHtmlToList(String html) {
    final List<String> result = [];
    final RegExp pTagRegex = RegExp(r'<p[^>]*>(.*?)<\/p>', dotAll: true);
    final matches = pTagRegex.allMatches(html);

    for (final match in matches) {
      var content = match.group(1) ?? '';
      content = content.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove nested HTML
      content = content.replaceAll('﻿', '').trim(); // Remove invisible characters
      if (content.isNotEmpty) result.add(content);
    }

    return result;
  }
}
