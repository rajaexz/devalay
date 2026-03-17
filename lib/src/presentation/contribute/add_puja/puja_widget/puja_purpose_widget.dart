import 'dart:convert';

import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../../../../application/contribution/contribution_puja/contribution_puja_cubit.dart';
import '../../../../application/contribution/contribution_puja/contribution_puja_state.dart';
import '../../widget/common_footer_text.dart';
// Import other required packages

class PujaPurposeWidget extends StatefulWidget {
  const PujaPurposeWidget(
      {super.key, required this.onNext, this.onBack, this.pujaId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? pujaId;

  @override
  State<PujaPurposeWidget> createState() => _PujaPurposeWidgetState();
}

class _PujaPurposeWidgetState extends State<PujaPurposeWidget> {
  late QuillController _purposeController;
  late QuillController _procedureController;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _purposeController = QuillController.basic();
    _procedureController = QuillController.basic();

    // Load data if pujaId is provided
    if (widget.pujaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPujaData();
      });
    }
  }

  Future<void> _loadPujaData() async {
    final pujaCubit = context.read<ContributePujaCubit>();
    await pujaCubit.fetchSingleContributePujaData(widget.pujaId ?? '');
  }

  void _bindPujaData(ContributePujaLoaded state) {
    if (!_isDataLoaded && state.singlePuja != null) {
      final pujaDetail = state.singlePuja!;

      debugPrint('Purpose data: ${pujaDetail.purpose}');
      debugPrint('Procedure data: ${pujaDetail.procedure}');

      // Bind purpose
      if (pujaDetail.purpose != null) {
        try {
          final purposeDeltaStr = pujaDetail.purpose!.delta as String;
          final purposeDelta = json.decode(purposeDeltaStr);
          final ops =
              List<Map<String, dynamic>>.from(purposeDelta['ops'] as List);
          if (ops.isNotEmpty &&
              !(ops.last['insert'] as String).endsWith('\n')) {
            ops.add({'insert': '\n'});
          }
          final delta = Delta.fromJson(ops);
          final document = Document.fromDelta(delta);
          _purposeController = QuillController(
              document: document,
              selection: const TextSelection.collapsed(offset: 0));
        } catch (e, stackTrace) {
          debugPrint('Error binding purpose data: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      // Bind procedure
      if (pujaDetail.procedure != null) {
        try {
          final procedureDeltaStr = pujaDetail.procedure!.delta as String;
          final procedureDelta = json.decode(procedureDeltaStr);
          final ops =
              List<Map<String, dynamic>>.from(procedureDelta['ops'] as List);
          if (ops.isNotEmpty &&
              !(ops.last['insert'] as String).endsWith('\n')) {
            ops.add({'insert': '\n'});
          }
          final delta = Delta.fromJson(ops);
          final document = Document.fromDelta(delta);
          _procedureController = QuillController(
              document: document,
              selection: const TextSelection.collapsed(offset: 0));
        } catch (e, stackTrace) {
          debugPrint('Error binding procedure data: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _procedureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributePujaCubit, ContributePujaState>(
      builder: (context, state) {
        final pujaCubit = context.read<ContributePujaCubit>();

        // Bind data when state has pujaDetail
        if (state is ContributePujaLoaded && state.singlePuja != null) {
          _bindPujaData(state);
        }

        return Form(
          key: pujaCubit.pujaPurposeFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Purpose",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    controller: _purposeController,
                    showFontFamily: true,
                    showColorButton: true,
                    showBackgroundColorButton: false,
                    showAlignmentButtons: false,
                    showListNumbers: false,
                    showListBullets: false,
                    showListCheck: false,
                    showCodeBlock: false,
                    showQuote: true,
                    showInlineCode: false,
                    showIndent: false,
                    showLink: true,
                    multiRowsDisplay: false,
                    showStrikeThrough: false,
                    showClearFormat: false,
                    showRedo: false,
                    showUndo: false,
                    showUnderLineButton: true,
                    showItalicButton: true,
                    showBoldButton: true,
                    showHeaderStyle: false,
                  ),
                ),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      controller: _purposeController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Procedure",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    toolbarIconAlignment: WrapAlignment.start,
                    toolbarIconCrossAlignment: WrapCrossAlignment.start,
                    controller: _procedureController,
                    showFontFamily: true,
                    showColorButton: true,
                    showBackgroundColorButton: false,
                    showAlignmentButtons: false,
                    showListNumbers: false,
                    showListBullets: false,
                    showListCheck: false,
                    showCodeBlock: false, 
                    showQuote: true,
                    showInlineCode: false,
                    showIndent: false,
                    showLink: true,
                    multiRowsDisplay: false,
                    showStrikeThrough: false,
                    showClearFormat: false,
                    showRedo: false,
                    showUndo: false,
                    showUnderLineButton: true,
                    showItalicButton: true,
                    showBoldButton: true,
                    showHeaderStyle: false,
                  ),
                ),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      controller: _procedureController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CommonFooterText(
                  onNextTap: () async {
                    final delta = _purposeController.document.toDelta();
                    final procedureDelta =
                        _procedureController.document.toDelta();
                    final deltaJson = delta.toJson();
                    final procedureDeltaJson = procedureDelta.toJson();
                    final html = DeltaToHTML.encodeJson(deltaJson);
                    final procedureHtml =
                        DeltaToHTML.encodeJson(procedureDeltaJson);
                    final purposeOutput = {
                      'delta': jsonEncode({'ops': deltaJson}),
                      'html': html,
                    };
                    final procedureOutput = {
                      'delta': jsonEncode({'ops': procedureDeltaJson}),
                      'html': procedureHtml,
                    };
                    debugPrint('Purpose Output: ${jsonEncode(purposeOutput)}');
                    debugPrint(
                        'procedure Output: ${jsonEncode(procedureOutput)}');
                    await pujaCubit.updatePujaPurpose(
                        widget.pujaId ?? '', purposeOutput, procedureOutput);
                    widget.onNext();
                  },
                  onBackTap: widget.onBack,
                  nextText: StringConstant.submit,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
