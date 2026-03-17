import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/god_form/god_form_cubit.dart';
import '../../../../application/contribution/god_form/god_form_state.dart';
import '../../../core/utils/colors.dart';
import '../../widget/common_footer_text.dart';

class PujaGodWidget extends StatefulWidget {
  const PujaGodWidget({super.key, required this.onNext, this.onBack, this.pujaId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? pujaId;

  @override
  State<PujaGodWidget> createState() => _PujaGodWidgetState();
}

class _PujaGodWidgetState extends State<PujaGodWidget> {
  Map<String, int> selectedItems = {};
  bool showItems = false;
  List<String> selectedGod = [];

  @override
  void initState() {
    super.initState();
    // Fetch puja data when widget initializes
    if (widget.pujaId != null) {
      context.read<ContributePujaCubit>().fetchSingleContributePujaData(widget.pujaId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributePujaCubit, ContributePujaState>(
      builder: (context, state) {
        final pujaCubit = context.read<ContributePujaCubit>();

        // Initialize selected gods from puja data
        if (state is ContributePujaLoaded && 
            state.singlePuja?.devs != null && 
            selectedItems.isEmpty) {
          for (var dev in state.singlePuja!.devs!) {
            if (dev.id != null && dev.title != null) {
              selectedItems[dev.title!] = dev.id!;
              if (!selectedGod.contains(dev.id.toString())) {
                selectedGod.add(dev.id.toString());
              }
            }
          }
        }

        return Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColor.lightTextColor),
                    top: BorderSide.none,
                    left: BorderSide.none,
                    right: BorderSide.none),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: selectedItems.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10.sp),
                            child: Text(
                              "${StringConstant.tabAdd} ${StringConstant.gods}",
                              style: const TextStyle(color: AppColor.lightTextColor),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0.sp,
                            children: selectedItems.entries.map((item) {
                              return Chip(
                                label: Text(item.key),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () {
                                  setState(() {
                                    selectedItems.remove(item.key);
                                    selectedGod.remove(item.value.toString());
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  InkWell(
                    child: !showItems
                        ? const Icon(
                            Icons.add,
                            color: AppColor.lightTextColor,
                          )
                        : const Icon(
                            Icons.close,
                            color: AppColor.lightTextColor,
                          ),
                    onTap: () {
                      setState(() {
                        showItems = !showItems;
                      });
                    },
                  )
                ],
              ),
            ),
            Gap(10.h),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: showItems
                  ? BlocProvider(
                      create: (context) => GodFormCubit()..fetchGodForm(),
                      child: BlocBuilder<GodFormCubit, GodFormState>(
                        builder: (context, state) {
                          if (state is GodFormLoaded) {
                            if (state.loadingState) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (state.errorMessage.isNotEmpty) {
                              return Center(child: Text(state.errorMessage));
                            }

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: SizedBox(
                                height: 200.h,
                                child: Card(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: state.godList?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final items = state.godList?[index];
                                        return CheckboxListTile(
                                          dense: true,
                                          title: Text(items?.title ?? ""),
                                          value: selectedItems.containsKey(items?.title),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedItems[items?.title ?? ''] = items!.id!;
                                                selectedGod.add(items.id.toString());
                                              } else {
                                                selectedItems.remove(items!.title);
                                                selectedGod.remove(items.id.toString());
                                              }
                                            });
                                          },
                                        );
                                      },
                                    )),
                              ),
                            );
                          }

                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            CommonFooterText(
              onNextTap: () async {
                await pujaCubit.updatePujaGod(widget.pujaId ?? '', selectedGod);
                widget.onNext();
              },
              onBackTap: widget.onBack
            )
          ],
        );
      }
    );
  }
}
