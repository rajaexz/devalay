import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconHtmlListRenderer extends StatelessWidget {
  final String htmlContent;
  final String? icon;
  final Color? iconColor;
  final Color? textColor;

  const IconHtmlListRenderer(
      {super.key,
      required this.htmlContent,
      this.icon,
      this.iconColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    final parsedItems = _parseHtmlToParagraphs(htmlContent);

    if (parsedItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parsedItems.map((text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
               icon??'',
                color: iconColor,
                width: 20.sp,
                height: 20.sp,
              ),
              // Icon(icon, size: 20.sp, color: iconColor,),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<String> _parseHtmlToParagraphs(String htmlContent) {
    if (htmlContent.trim().isEmpty) return [];

    // Decode HTML entities
    String decoded = htmlContent
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00A0', ' '); // numeric nbsp

    // Extract from <p> tags
    final RegExp regex = RegExp(r'<p[^>]*>(.*?)<\/p>', dotAll: true);
    final matches = regex.allMatches(decoded);

    final paragraphs = matches
        .map((match) {
          var content = match.group(1) ?? '';
          content =
              content.replaceAll(RegExp(r'<[^>]*>'), ''); // remove inner tags
          content = content
              .replaceAll('&nbsp;', ' ')
              .replaceAll('\u00A0', ' ')
              .replaceAll('﻿', '')
              .trim(); // remove zero-width chars
          return content;
        })
        .where((text) => text.isNotEmpty)
        .toList();

    return paragraphs;
  }
}
