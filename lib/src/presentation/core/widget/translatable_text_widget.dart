import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/colors.dart';

class TranslatableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatableTextWidget> createState() => _TranslatableTextWidgetState();
}

class _TranslatableTextWidgetState extends State<TranslatableTextWidget> {
  bool _isTranslated = false;
  String? _translatedContent;
  bool _isTranslating = false;
  bool _showTranslateButton = false;

  @override
  void initState() {
    super.initState();
    _checkIfEnglish();
  }

  @override
  void didUpdateWidget(TranslatableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _checkIfEnglish();
      _isTranslated = false;
      _translatedContent = null;
    }
  }

  // Check if content is in English
  void _checkIfEnglish() {
    final plainText = widget.text.trim();
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
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final plainText = widget.text.trim();
      if (plainText.isEmpty) return;

      // Get target language from current locale - translate to opposite language
      // If user is viewing in Hindi, translate English posts to Hindi
      // If user is viewing in English, translate English posts to Hindi (default)
      final currentLang = context.locale.languageCode;
      final targetLang = currentLang == 'hi' ? 'hi' : 'hi'; // Always translate to Hindi
      final sourceLang = 'en'; // Assuming source is English

      // Use Google Translate API (free tier)
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=${Uri.encodeComponent(plainText)}');

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

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    final displayText = _isTranslated && _translatedContent != null
        ? _translatedContent!
        : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayText,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        ),
        // Translate button (Instagram style)
        if (_showTranslateButton)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
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
                              AppColor.orangeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Translating...',
                          style: TextStyle(
                            color: AppColor.orangeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _isTranslated ? 'Show original' : 'Translate',
                      style: TextStyle(
                        color: AppColor.orangeColor,
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

