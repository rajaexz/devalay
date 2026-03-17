
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostContentWidget extends StatefulWidget {
  final String postContent;
  final List<Tags> tags;
  final String postId;

  const PostContentWidget({
    super.key,
    required this.postContent,
    required this.tags,
    required this.postId,
  });

  @override
  State<PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<PostContentWidget> {
  static const int _wordLimit = 20;
  // HTML tags that shouldn't receive auto-closing tags when truncating
  static const Set<String> _selfClosingTags = {
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
  };
  bool _isExpanded = false;
  late String _displayContent;
  late bool _needsExpansion;
  String userid = '';
  bool _isTranslated = false;
  String? _translatedContent;
  bool _isTranslating = false;
  bool _showTranslateButton = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _processContent();
    _checkIfEnglish();
  }

   Future<void> _getUserData() async {
    userid = (await PrefManager.getUserDevalayId()) ?? '';
    if (mounted) {
      setState(() {});
    }
  }


  @override
  void didUpdateWidget(PostContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postContent != widget.postContent) {
      _processContent();
      _checkIfEnglish();
      _isTranslated = false;
      _translatedContent = null;
    }
  }

  // Check if content is in English
  void _checkIfEnglish() {
    final plainText = widget.postContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (plainText.isEmpty) {
      _showTranslateButton = false;
      return;
    }
    
    // Simple English detection - check if text contains mostly English characters
    final englishPattern = RegExp(r'^[a-zA-Z0-9\s.,!?;:()\-]+$');
    final words = plainText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    
    if (words.isEmpty) {
      _showTranslateButton = false;
      return;
    }
    
    int englishWords = 0;
    final wordsToCheck = words.length > 10 ? words.take(10).toList() : words;
    for (var word in wordsToCheck) {
      final cleanedWord = word.replaceAll(RegExp(r'[.,!?;:()\-]'), '');
      if (cleanedWord.isNotEmpty && englishPattern.hasMatch(cleanedWord)) {
        englishWords++;
      }
    }
    
    // If more than 70% words are English, show translate button
    _showTranslateButton = wordsToCheck.isNotEmpty && (englishWords / wordsToCheck.length) > 0.7;
  }

  // Translate text using Google Translate API
  Future<void> _translateContent() async {
    if (_isTranslated && _translatedContent != null) {
      // Toggle back to original
      setState(() {
        _isTranslated = false;
      });
      _processContent();
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final plainText = widget.postContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (plainText.isEmpty) return;

      // Get target language from current locale - translate to opposite language
      // If user is viewing in Hindi, translate English posts to Hindi
      // If user is viewing in English, translate English posts to Hindi (default)
      final currentLang = context.locale.languageCode;
      final targetLang = currentLang == 'hi' ? 'hi' : 'hi'; // Always translate to Hindi
      final sourceLang = 'en'; // Assuming source is English

      // Use Google Translate API (free tier)
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=${Uri.encodeComponent(plainText)}');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data[0] != null && data[0].isNotEmpty) {
          final translatedText = data[0].map((item) => item[0]).join('');
          
          setState(() {
            _translatedContent = translatedText;
            _isTranslated = true;
            _isTranslating = false;
          });
          
          // Update display content with translated text
          _processContent();
        } else {
          setState(() {
            _isTranslating = false;
          });
        }
      } else {
        setState(() {
          _isTranslating = false;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _processContent() {
    // Use translated content if available, otherwise use original
    String contentToProcess;
    if (_isTranslated && _translatedContent != null) {
      // Wrap translated text in HTML tags
      contentToProcess = '<p>${_translatedContent!.replaceAll('\n', '<br>')}</p>';
    } else {
      contentToProcess = widget.postContent;
    }
    
    final wordCount = _countWords(contentToProcess);
    _needsExpansion = wordCount > _wordLimit;
    _displayContent = _needsExpansion && !_isExpanded
        ? _truncateHtml(contentToProcess, _wordLimit)
        : contentToProcess;
    
    // Add "See less" link if content is expanded and needs expansion
    if (_isExpanded && _needsExpansion) {
      _displayContent += '<span class="less-link">See less</span>';
    }
  }

  int _countWords(String html) {
    final plainText = html.replaceAll(RegExp(r'<[^>]*>'), '');
    return plainText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  String _truncateHtml(String html, int wordLimit) {
    final pattern = RegExp(r'(<[^>]*>)|([^<]+)');
    final matches = pattern.allMatches(html);

    int wordCount = 0;
    String result = '';
    bool limitReached = false;

    for (var match in matches) {
      final tag = match.group(1);
      final text = match.group(2);

      if (tag != null) {
        if (limitReached && tag.startsWith('</')) continue;
        result += tag;
      } else if (text != null && !limitReached) {
        final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
        for (var word in words) {
          if (wordCount < wordLimit) {
            result += '${wordCount > 0 ? ' ' : ''}$word';
            wordCount++;
          } else {
            limitReached = true;
            break;
          }
        }
      }

      if (limitReached) break;
    }

    final openTags = RegExp(r'<([a-zA-Z]+)[^>]*>').allMatches(result).map((m) => m.group(1)).toList();
    final closedTags = RegExp(r'</([a-zA-Z]+)>')
        .allMatches(result)
        .map((m) => m.group(1)?.toLowerCase())
        .whereType<String>()
        .toList();

    for (var i = openTags.length - 1; i >= 0; i--) {
      final tag = openTags[i]?.toLowerCase();
      // Skip void/self-closing tags like img/br to avoid generating invalid </img>
      if (tag != null && !_selfClosingTags.contains(tag) && !closedTags.contains(tag)) {
        result += '</$tag>';
      }
    }

    // Add the "more" link to the truncated content
    result += '<span class="more-link">...more</span>';

    return result;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _processContent();
    });
  }

  Widget _buildTagsWidget() {
    if (widget.tags.isEmpty) return const SizedBox.shrink();

    // Build a safe list of tags (skip ones without id or name)
    final List<Map<String, String>> tagsList = widget.tags
        .where((tag) => (tag.objectId ?? '').isNotEmpty && (tag.name ?? '').isNotEmpty)
        .map((tag) => {
              'name': tag.name ?? '',
              'content_type': tag.type ?? '',
              'object_id': tag.objectId ?? '',
            })
        .toList();

    if (tagsList.isEmpty) return const SizedBox.shrink();

    // Build HTML links for tags; routing is resolved in _handleTagTap
    final String tagsHtml =
        '<div class="tags-container">${tagsList.map((tag) {
      final name = tag['name'] ?? '';
      final type = tag['content_type']?.toLowerCase() ?? '';
      final id = tag['object_id'] ?? '';

      switch (type) {
        case 'devalay':
          return '<a href="/devalay/$id">$name</a>';
        case 'user':
          // Use generic /user route; _handleTagTap decides self vs other profile
          return '<a href="/user/$id">$name</a>';
        case 'post':
          return '<a href="/post/$id">$name</a>';
        default:
          // Fallback: /type/id
          return '<a href="/$type/$id">$name</a>';
      }
    }).join(' ')}</div>';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Html(
        data: tagsHtml,
        onLinkTap: (url, _, __) => _handleTagTap(context, url),
        style: {
          "a": Style(
            textDecoration: TextDecoration.underline,
            fontSize: FontSize(14),
            lineHeight: const LineHeight(1.5),
          ),
          "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        },
      ),
    );
  }

  void _handleTagTap(BuildContext context, String? url) async {
    if (url == null) return;
    try {
      final cleanUrl = url.startsWith('/') ? url : '/$url';
      final parts = cleanUrl.split('/');
      if (parts.length >= 3) {
        final type = parts[1].toLowerCase();
        final id = parts[2];

        if (id.isEmpty) {
          // Invalid id, do nothing
          return;
        }

        switch (type) {
          case 'devalay':
            AppRouter.go('/singleDevalay/$id');
            break;
          case 'user':
            // Current user's own profile vs other user's profile
            userid == id
                ? AppRouter.go('/profileMainScreen/$id/profile')
                : AppRouter.go('/profileMainScreen/$id/devotees');
            break;
          case 'post':
            AppRouter.go('/post/$id');
            break;
          default:
            AppRouter.push(cleanUrl);
        }
      } else {
        throw Exception('Invalid route format');
      }
    } catch (e) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        print('Fallback failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.postContent.trim();
    if (content.isEmpty || content == '<p></p>') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Html(
            data: _displayContent,
            onLinkTap: (url, _, __) => _handleTagTap(context, url),
            style: {
              "br": Style(
                display: Display.none, // This completely hides br tags
              ),
              "body": Style(
                margin: Margins.zero, 
                padding: HtmlPaddings.zero,
              ),
              "p": Style(
                margin: Margins.zero, 
                padding: HtmlPaddings.zero,
                lineHeight: const LineHeight(1.2),
              ),
              "div": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "span": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              ".more-link": Style(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              ".less-link": Style(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            },
            extensions: [
              // Extension to completely remove br tags
              TagExtension(
                tagsToExtend: {"br"},
                builder: (context) {
                  return const SizedBox.shrink(); // Returns empty widget
                },
              ),
              TagExtension(
                tagsToExtend: {"span"},
                builder: (context) {
                  final className = context.element?.className;
                  if (className == 'more-link' || className == 'less-link') {
                    return GestureDetector(
                      onTap: _toggleExpanded,
                      child: Text(
                        className == 'more-link' ? StringConstant.more : StringConstant.seeLess,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
        // Tags are already in postContent (caption HTML); no separate tags row to avoid duplicate
        if (_showTranslateButton)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: GestureDetector(
              onTap: _translateContent,
              child: _isTranslating
                  ? Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          StringConstant.translating,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _isTranslated ? StringConstant.showOriginal : StringConstant.translate,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}