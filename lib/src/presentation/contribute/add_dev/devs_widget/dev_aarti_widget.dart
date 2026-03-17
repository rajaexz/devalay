import 'dart:convert';

import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/create_temple/widget/temple_complete_screen.dart';
import '../../../create/widget/common_guideline_text.dart';

class DevAartiWidget extends StatefulWidget {
  const DevAartiWidget(
      {super.key, required this.onNext, this.onBack, this.devId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? devId;

  @override
  State<DevAartiWidget> createState() => _DevAartiWidgetState();
}

class _DevAartiWidgetState extends State<DevAartiWidget> {
  late QuillController _aartiController;
  bool _isDataLoaded = false;
  @override
  void initState() {
    super.initState();
    _aartiController = QuillController.basic();
    if (widget.devId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPujaData();
      });
    }
  }

  Future<void> _loadPujaData() async {
    final pujaCubit = context.read<ContributeDevCubit>();
    await pujaCubit.fetchSingleContributeDevData(widget.devId ?? '');
  }

  void _bindPujaData(ContributeDevLoaded state) {
    if (!_isDataLoaded && state.singleData != null) {
      final devDetail = state.singleData!;

      if (devDetail.aarti != null) {
        try {
          final purposeDeltaStr = devDetail.aarti!.delta as String;
          final purposeDelta = json.decode(purposeDeltaStr);
          final ops =
              List<Map<String, dynamic>>.from(purposeDelta['ops'] as List);
          if (ops.isNotEmpty &&
              !(ops.last['insert'] as String).endsWith('\n')) {
            ops.add({'insert': '\n'});
          }
          final delta = Delta.fromJson(ops);
          final document = Document.fromDelta(delta);
          _aartiController = QuillController(
              document: document,
              selection: const TextSelection.collapsed(offset: 0));
        } catch (e, stackTrace) {
          debugPrint('Error binding purpose data: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      if (devDetail.aarti != null) {
        try {
          final procedureDeltaStr = devDetail.aarti!.delta as String;
          final procedureDelta = json.decode(procedureDeltaStr);
          final ops =
              List<Map<String, dynamic>>.from(procedureDelta['ops'] as List);
          if (ops.isNotEmpty &&
              !(ops.last['insert'] as String).endsWith('\n')) {
            ops.add({'insert': '\n'});
          }
          final delta = Delta.fromJson(ops);
          final document = Document.fromDelta(delta);
          _aartiController = QuillController(
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
    _aartiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeDevCubit, ContributeDevState>(
        builder: (context, state) {
      final devCubit = context.read<ContributeDevCubit>();
      final pujaCubit = context.read<ContributeDevCubit>();
      if (state is ContributeDevLoaded && state.singleData != null) {
        _bindPujaData(state);
      }

      return Form(
        key: pujaCubit.pujaPurposeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.artiTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Gap(10.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: _aartiController,
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
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: _aartiController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CommonFooterText(
              onNextTap: () async {
                final delta = _aartiController.document.toDelta();
                final deltaJson = delta.toJson();
                final html = DeltaToHTML.encodeJson(deltaJson);
                final aartiOutput = {
                  'delta': jsonEncode({'ops': deltaJson}),
                  'html': html,
                };
                debugPrint('Purpose Output: ${jsonEncode(aartiOutput)}');
                await devCubit.updateDevAarti(widget.devId ?? '', aartiOutput);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TempleCompleteScreen()));
                AppRouter();
              },
              onBackTap: widget.onBack,
            ),
            Gap(20.h),
            Guideline(title: StringConstant.guideline, points: [
              StringConstant.guidelineGodAarti,
              StringConstant.guidelineGodHeadingAarti,
            ]),
            Gap(20.h)
          ],
        ),
      );
    });
  }
}

