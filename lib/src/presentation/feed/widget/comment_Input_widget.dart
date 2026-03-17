import 'dart:async';
import 'dart:convert';

import 'package:delta_to_html/delta_to_html.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CommentInputWidget extends StatefulWidget {
  final Function(String deltaJson, String html)? onContentChanged;

  const CommentInputWidget({super.key, this.onContentChanged});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  late FeedHomeCubit feedHomeCubit;
  late GobelSearchCubit gobelSearchCubit;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounceTimer;
  StreamSubscription? _documentChangesSubscription;

  String currentHashtag = '';
  bool showSearchResults = false;
  Map<String, int> taggedTemples = {};

  @override
  void initState() {
    super.initState();
    gobelSearchCubit = context.read<GobelSearchCubit>();
    feedHomeCubit = context.read<FeedHomeCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
      // final parent = context.findAncestorWidgetOfExactType<FeedCreateScreen>();
      // if (parent?.existingPost != null) {
      //   Future.delayed(Duration(milliseconds: 100), _generateOutput);
      // }
    });
  }

  void _setupListeners() {
    _documentChangesSubscription = feedHomeCubit
        .commentController.document.changes
        .listen((_) => _generateOutput());
  }

  void _generateOutput() {
    if (widget.onContentChanged == null) return;
    try {
      final deltaJson = jsonEncode(
          {"ops": feedHomeCubit.commentController.document.toDelta().toJson()});
      final html = convertToHtml(feedHomeCubit.commentController.document);
      widget.onContentChanged!(deltaJson, html);
    } catch (_) {}
  }

  @override
  void dispose() {
    _documentChangesSubscription?.cancel();

    _focusNode.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.blackColor
                : AppColor.whiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(minHeight: 40, maxHeight: 200),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: feedHomeCubit.commentController,
                scrollPhysics: const ClampingScrollPhysics(),
                autoFocus: false,
                showCursor: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                placeholder: StringConstant.addCaption,
                enableInteractiveSelection: true,
                expands: false,
                customStyles: const DefaultStyles(
                  placeHolder: DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 16, 
                      color: Colors.grey,
                    ),
                    VerticalSpacing(0, 0),
                    VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
              scrollController: _scrollController,
              focusNode: _focusNode,
            ),
          ),
        ),
      ],
    );
  }
}

String convertToHtml(Document document) {
  try {
    return DeltaToHTML.encodeJson(document.toDelta().toJson());
  } catch (_) {
    return "";
  }
}
