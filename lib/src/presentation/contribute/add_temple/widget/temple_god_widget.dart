import 'dart:io';

import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/application/contribution/god_form/god_form_cubit.dart';
import 'package:devalay_app/src/application/contribution/god_form/god_form_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widget/custom_border_checkbox.dart';
import '../../../create/widget/common_guideline_text.dart';

class TempleGodWidget extends StatefulWidget {
  const TempleGodWidget(
      {super.key, required this.onNext, this.onBack, this.templeId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;

  @override
  State<TempleGodWidget> createState() => _TempleGodWidgetState();
}

class _TempleGodWidgetState extends State<TempleGodWidget> {
  Map<String, int> selectedItems = {};
  bool showItems = false;
  List<String> selectedGod = [];
  final _imagePicker = ImagePicker();
  Map<String, File?> pickedImageFiles = {};
  Map<String, String> godApiResponseIds = {};

  Map<String, bool> godApiLoadingStates = {};
  Map<String, bool> imageUploadLoadingStates = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _filteredGodList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _filterGodList(List<dynamic>? godList) {
    if (godList == null) {
      _filteredGodList = [];
      return;
    }

    if (_searchQuery.isEmpty) {
      _filteredGodList = godList;
    } else {
      _filteredGodList = godList.where((god) {
        final title = god?.title?.toLowerCase() ?? '';
        return title.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _loadExistingData() {
    final cubit = context.read<ContributeTempleCubit>();
    final currentState = cubit.state;

    if (currentState is ContributeTempleLoaded) {
      if (cubit.selectedItems.isNotEmpty) {
        setState(() {
          selectedItems = Map.from(cubit.selectedItems);
          selectedGod = List.from(cubit.selectedGod);
          godApiResponseIds = Map.from(cubit.godApiResponseIds);
        });
      }
    }
  }

  Future<void> _handleGodSelection(dynamic items, bool? value) async {
    if (items?.title == null || items?.id == null) {
      debugPrint("Invalid god data");
      return;
    }

    final godTitle = items.title!;
    final godId = items.id!;

    setState(() {
      if (value == true) {
        selectedItems[godTitle] = godId;
        if (!selectedGod.contains(godId.toString())) {
          selectedGod.add(godId.toString());
        }
        godApiLoadingStates[godTitle] = true;
      } else {
        selectedItems.remove(godTitle);
        selectedGod.removeWhere((id) => id == godId.toString());
        godApiResponseIds.remove(godTitle);
        godApiLoadingStates.remove(godTitle);
      }
    });

    final cubit = context.read<ContributeTempleCubit>();

    if (widget.templeId != null && value == true) {
      try {
        final response = await cubit.updateTempleGod(
          widget.templeId!,
          godId.toString(),
        );

        if (response != null && response.id != null) {
          setState(() {
            godApiResponseIds[godTitle] = response.id.toString();
            godApiLoadingStates[godTitle] = false;
          });

          debugPrint("God API Response ID for $godTitle: ${response.id}");
        } else {
          setState(() {
            godApiLoadingStates[godTitle] = false;
            selectedItems.remove(godTitle);
            selectedGod.removeWhere((id) => id == godId.toString());
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add $godTitle. Please try again.')),
          );
        }
      } catch (error) {
        setState(() {
          godApiLoadingStates[godTitle] = false;
          selectedItems.remove(godTitle);
          selectedGod.removeWhere((id) => id == godId.toString());
        });

        debugPrint("Error calling updateTempleGod: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding $godTitle: $error')),
        );
      }
    }

    cubit.setSelectedGods(
      selectedItems: selectedItems,
      selectedGod: selectedGod,
      godApiResponseIds: godApiResponseIds,
    );

    debugPrint("Selected items: $selectedItems");
    debugPrint("Selected god IDs: $selectedGod");
    debugPrint("God API Response IDs: $godApiResponseIds");
  }

  void _pickedImage(String godKey, ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxHeight: 1024,
        maxWidth: 1024,
      );

      if (pickedImage == null) return;

      setState(() {
        pickedImageFiles[godKey] = File(pickedImage.path);
        imageUploadLoadingStates[godKey] = true;
      });

      final cubit = context.read<ContributeTempleCubit>();

      Map<String, dynamic> updatedImages = Map.from(cubit.godImages);
      updatedImages[godKey] = pickedImage.path;
      cubit.setGodImages(updatedImages);

      String? apiResponseId = godApiResponseIds[godKey];
      if (apiResponseId != null) {
        try {
          await cubit.updateGodPhoto(
            apiResponseId,
            pickedImageFiles[godKey],
            widget.templeId ?? '',
          );

          setState(() {
            imageUploadLoadingStates[godKey] = false;
          });

          debugPrint("Image uploaded successfully for $godKey");
        } catch (error) {
          setState(() {
            imageUploadLoadingStates[godKey] = false;
          });

          debugPrint("Error uploading image for $godKey: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image for $godKey')),
          );
        }
      } else {
        setState(() {
          imageUploadLoadingStates[godKey] = false;
        });

        debugPrint("No API response ID found for god: $godKey");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cannot upload image for $godKey. Please try selecting the god again.')),
        );
      }
    } catch (error) {
      setState(() {
        imageUploadLoadingStates[godKey] = false;
      });

      debugPrint("Error picking image: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $error')),
      );
    }
  }

  Future<void> showImagePicker(String godKey) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            child: SizedBox(
              height: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _pickedImage(godKey, ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 30.sp,
                          color: AppColor.blackColor,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          StringConstant.camera,
                          style: const TextStyle(color: AppColor.blackColor),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _pickedImage(godKey, ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo,
                          size: 30.sp,
                          color: AppColor.blackColor,
                        ),
                        SizedBox(height: 5.h),
                        Text(StringConstant.gallery,
                            style: const TextStyle(color: AppColor.blackColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteGodChip(String godKey) {
    setState(() {
      final godId = selectedItems[godKey];
      selectedItems.remove(godKey);
      if (godId != null) {
        selectedGod.removeWhere((id) => id == godId.toString());
      }
      godApiResponseIds.remove(godKey);
      pickedImageFiles.remove(godKey);
      godApiLoadingStates.remove(godKey);
      imageUploadLoadingStates.remove(godKey);
    });

    final cubit = context.read<ContributeTempleCubit>();
    cubit.setSelectedGods(
      selectedItems: selectedItems,
      selectedGod: selectedGod,
      godApiResponseIds: godApiResponseIds,
    );
    Map<String, dynamic> updatedImages = Map.from(cubit.godImages);
    updatedImages.remove(godKey);
    cubit.setGodImages(updatedImages);

    debugPrint("Deleted god: $godKey, remaining: $selectedItems");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        if (state is ContributeTempleLoaded) {
          final cubit = context.read<ContributeTempleCubit>();
          if (cubit.selectedItems.isNotEmpty && selectedItems.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                selectedItems = Map.from(cubit.selectedItems);
                selectedGod = List.from(cubit.selectedGod);
                godApiResponseIds = Map.from(cubit.godApiResponseIds);
              });
            });
          }
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(StringConstant.select),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.boxColor),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.sp),
                        child: Text(
                          "${StringConstant.tabAdd} ${StringConstant.gods}",
                          style:
                              const TextStyle(color: AppColor.lightTextColor),
                        ),
                      ),
                    ),
                    InkWell(
                      child: !showItems
                          ? const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor.lightTextColor,
                            )
                          : const Icon(
                              Icons.close,
                              color: AppColor.lightTextColor,
                            ),
                      onTap: () {
                        setState(() {
                          showItems = !showItems;
                          if (!showItems) {
                            _clearSearch();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Gap(4.h),
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
                              _filterGodList(state.godList);
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.sp),
                                child: SizedBox(
                                  height: 280.h,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                      border:
                                          Border.all(color: AppColor.boxColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: 300.h,
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: _filteredGodList.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    _searchQuery.isNotEmpty
                                                        ? 'No gods found for "$_searchQuery"'
                                                        : 'No gods available',
                                                    style: TextStyle(
                                                      color: AppColor
                                                          .lightTextColor,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _filteredGodList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final items =
                                                        _filteredGodList[index];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  18.0.sp,
                                                              vertical: 6.sp),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                                  items.title ??
                                                                      '')),
                                                          BorderedCheckbox(
                                                            value: selectedItems
                                                                .containsKey(
                                                                    items
                                                                        .title),
                                                            onChanged:
                                                                (bool? value) {
                                                              _handleGodSelection(
                                                                  items, value);
                                                            },
                                                            activeColor: AppColor
                                                                .appbarBgColor,
                                                            inactiveBorderColor:
                                                                AppColor
                                                                    .greyColor,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Wrap(
                spacing: 8.0.sp,
                children: selectedItems.entries.map((item) {
                  final isLoading = godApiLoadingStates[item.key] ?? false;
                  return Chip(
                    backgroundColor: const Color(0xffFDF2EE),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isLoading) ...[
                          SizedBox(width: 8.sp),
                          SizedBox(
                            width: 12.sp,
                            height: 12.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      _deleteGodChip(item.key);
                    },
                  );
                }).toList(),
              ),
              Gap(10.h),
              selectedItems.isNotEmpty
                  ? Text(
                      StringConstant.uploadImages,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : const SizedBox.shrink(),
              Gap(20.h),
              selectedItems.isNotEmpty
                  ? BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
                      builder: (context, state) {
                        if (state is ContributeTempleLoaded) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: selectedItems.length,
                              // Replace your existing GridView.builder itemBuilder section with this:

                              itemBuilder: (context, index) {
                                String title = selectedItems.keys.toList()[index];
                                final isUploading = imageUploadLoadingStates[title] ?? false;
                                final hasApiId = godApiResponseIds.containsKey(title);

                                return InkWell(
                                  onTap: hasApiId ? () => showImagePicker(title) : null,
                                  child: Container(
                                    height: 180.h,
                                    width: 160.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: pickedImageFiles[title] != null
                                          ? null
                                          : AppColor.blackColor.withOpacity(0.40),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Image container with proper aspect ratio
                                        if (pickedImageFiles[title] != null)
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4.r),
                                              child: Image.file(
                                                pickedImageFiles[title]!,
                                                fit: BoxFit.cover, // This will maintain aspect ratio and fill the container
                                                alignment: Alignment.center, // Center the image
                                              ),
                                            ),
                                          ),

                                        // Overlay for darkening effect
                                        if (pickedImageFiles[title] != null)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4.r),
                                                color: AppColor.blackColor.withOpacity(0.20),
                                              ),
                                            ),
                                          ),

                                        // Center content (plus icon, loading indicator, text)
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Gap(40.h),
                                              if (isUploading)
                                                const CircularProgressIndicator(
                                                  color: AppColor.whiteColor,
                                                )
                                              else if (pickedImageFiles[title] != null)
                                                Icon(
                                                  Icons.add,
                                                  color: AppColor.whiteColor,
                                                  size: 40.sp,
                                                )
                                              else
                                                SvgPicture.asset(
                                                  "assets/icon/Plus.svg",
                                                  height: 50.sp,
                                                  width: 50.sp,
                                                  color: hasApiId
                                                      ? AppColor.whiteColor
                                                      : AppColor.whiteColor.withOpacity(0.5),
                                                ),
                                              Gap(20.h),
                                              Text(
                                                title,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: hasApiId
                                                      ? AppColor.whiteColor
                                                      : AppColor.whiteColor.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Upload status indicator
                                        if (isUploading)
                                          Positioned(
                                            top: 8.h,
                                            right: 8.h,
                                            child: Container(
                                              padding: EdgeInsets.all(4.sp),
                                              decoration: BoxDecoration(
                                                color: AppColor.blackColor.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                'Uploading...',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppColor.whiteColor,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  : const SizedBox.shrink(),
              CommonFooterText(
                onNextTap: widget.onNext,
                onBackTap: widget.onBack,
              ),
              Gap(20.h),
              Guideline(
                title: StringConstant.guideline,
                points: [
                  StringConstant.godGuideline,
                  StringConstant.godSubGuideline,
                  StringConstant.uploadGodImages,
                  StringConstant.uploadGodHighQualityImages,
                ],
              ),
              Gap(10.h),
            ],
          ),
        );
      },
    );
  }
}


// import 'dart:io';
//
// import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
// import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
// import 'package:devalay_app/src/application/contribution/god_form/god_form_cubit.dart';
// import 'package:devalay_app/src/application/contribution/god_form/god_form_state.dart';
// import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
// import 'package:devalay_app/src/presentation/core/constants/strings.dart';
// import 'package:devalay_app/src/presentation/core/utils/colors.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../core/widget/custom_border_checkbox.dart';
// import '../../../create/widget/common_guideline_text.dart';
//
// class TempleGodWidget extends StatefulWidget {
//   const TempleGodWidget(
//       {super.key, required this.onNext, this.onBack, this.templeId});
//   final void Function() onNext;
//   final VoidCallback? onBack;
//   final String? templeId;
//
//   @override
//   State<TempleGodWidget> createState() => _TempleGodWidgetState();
// }
//
// class _TempleGodWidgetState extends State<TempleGodWidget> {
//   Map<String, int> selectedItems = {};
//   bool showItems = false;
//   List<String> selectedGod = [];
//   final _imagePicker = ImagePicker();
//   Map<String, File?> pickedImageFiles = {};
//   Map<String, String> godApiResponseIds = {};
//
//   Map<String, bool> godApiLoadingStates = {};
//   Map<String, bool> imageUploadLoadingStates = {};
//
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   List<dynamic> _filteredGodList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadExistingData();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//     });
//   }
//
//   void _filterGodList(List<dynamic>? godList) {
//     if (godList == null) {
//       _filteredGodList = [];
//       return;
//     }
//
//     if (_searchQuery.isEmpty) {
//       _filteredGodList = godList;
//     } else {
//       _filteredGodList = godList.where((god) {
//         final title = god?.title?.toLowerCase() ?? '';
//         return title.contains(_searchQuery);
//       }).toList();
//     }
//   }
//
//   void _clearSearch() {
//     _searchController.clear();
//     setState(() {
//       _searchQuery = '';
//     });
//   }
//
//   void _loadExistingData() {
//     final cubit = context.read<ContributeTempleCubit>();
//     final currentState = cubit.state;
//
//     if (currentState is ContributeTempleLoaded) {
//       if (cubit.selectedItems.isNotEmpty) {
//         setState(() {
//           selectedItems = Map.from(cubit.selectedItems);
//           selectedGod = List.from(cubit.selectedGod);
//           godApiResponseIds = Map.from(cubit.godApiResponseIds );
//         });
//       }
//     }
//   }
//
//   Future<void> _handleGodSelection(dynamic items, bool? value) async {
//     if (items?.title == null || items?.id == null) {
//       debugPrint("Invalid god data");
//       return;
//     }
//
//     final godTitle = items.title!;
//     final godId = items.id!;
//
//     setState(() {
//       if (value == true) {
//         selectedItems[godTitle] = godId;
//         if (!selectedGod.contains(godId.toString())) {
//           selectedGod.add(godId.toString());
//         }
//         godApiLoadingStates[godTitle] = true;
//       } else {
//         selectedItems.remove(godTitle);
//         selectedGod.removeWhere((id) => id == godId.toString());
//         godApiResponseIds.remove(godTitle);
//         godApiLoadingStates.remove(godTitle);
//       }
//     });
//
//     final cubit = context.read<ContributeTempleCubit>();
//
//     if (widget.templeId != null && value == true) {
//       try {
//         final response = await cubit.updateTempleGod(
//           widget.templeId!,
//           godId.toString(),
//         );
//
//         if (response != null && response.id != null) {
//           setState(() {
//             godApiResponseIds[godTitle] = response.id.toString();
//             godApiLoadingStates[godTitle] = false;
//           });
//
//           debugPrint("God API Response ID for $godTitle: ${response.id}");
//         } else {
//           setState(() {
//             godApiLoadingStates[godTitle] = false;
//             selectedItems.remove(godTitle);
//             selectedGod.removeWhere((id) => id == godId.toString());
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to add $godTitle. Please try again.')),
//           );
//         }
//       } catch (error) {
//         setState(() {
//           godApiLoadingStates[godTitle] = false;
//           selectedItems.remove(godTitle);
//           selectedGod.removeWhere((id) => id == godId.toString());
//         });
//
//         debugPrint("Error calling updateTempleGod: $error");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error adding $godTitle: $error')),
//         );
//       }
//     }
//
//     cubit.setSelectedGods(
//       selectedItems: selectedItems,
//       selectedGod: selectedGod,
//       godApiResponseIds: godApiResponseIds,
//     );
//
//     debugPrint("Selected items: $selectedItems");
//     debugPrint("Selected god IDs: $selectedGod");
//     debugPrint("God API Response IDs: $godApiResponseIds");
//   }
//
//   void _pickedImage(String godKey, ImageSource source) async {
//     try {
//       final pickedImage = await _imagePicker.pickImage(
//         source: source,
//         imageQuality: 75,
//         maxHeight: 1024,
//         maxWidth: 1024,
//       );
//
//       if (pickedImage == null) return;
//
//       setState(() {
//         pickedImageFiles[godKey] = File(pickedImage.path);
//         imageUploadLoadingStates[godKey] = true;
//       });
//
//       final cubit = context.read<ContributeTempleCubit>();
//
//       Map<String, dynamic> updatedImages = Map.from(cubit.godImages);
//       updatedImages[godKey] = pickedImage.path;
//       cubit.setGodImages(updatedImages);
//
//       String? apiResponseId = godApiResponseIds[godKey];
//       if (apiResponseId != null) {
//         try {
//           await cubit.updateGodPhoto(
//             apiResponseId,
//             pickedImageFiles[godKey],
//             widget.templeId ?? '',
//           );
//
//           setState(() {
//             imageUploadLoadingStates[godKey] = false;
//           });
//
//           debugPrint("Image uploaded successfully for $godKey");
//         } catch (error) {
//           setState(() {
//             imageUploadLoadingStates[godKey] = false;
//           });
//
//           debugPrint("Error uploading image for $godKey: $error");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to upload image for $godKey')),
//           );
//         }
//       } else {
//         setState(() {
//           imageUploadLoadingStates[godKey] = false;
//         });
//
//         debugPrint("No API response ID found for god: $godKey");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Cannot upload image for $godKey. Please try selecting the god again.')),
//         );
//       }
//     } catch (error) {
//       setState(() {
//         imageUploadLoadingStates[godKey] = false;
//       });
//
//       debugPrint("Error picking image: $error");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: $error')),
//       );
//     }
//   }
//
//   Future<void> showImagePicker(String godKey) {
//     return showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Material(
//             child: SizedBox(
//               height: 170,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CupertinoButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () {
//                       _pickedImage(godKey, ImageSource.camera);
//                       Navigator.of(context).pop();
//                     },
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.camera_alt_outlined, size: 30.sp),
//                         SizedBox(height: 5.h),
//                         Text(StringConstant.camera),
//                       ],
//                     ),
//                   ),
//                   CupertinoButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () {
//                       _pickedImage(godKey, ImageSource.gallery);
//                       Navigator.of(context).pop();
//                     },
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.photo, size: 30.sp),
//                         SizedBox(height: 5.h),
//                         Text(StringConstant.gallery),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Improved chip deletion
//   void _deleteGodChip(String godKey) {
//     setState(() {
//       final godId = selectedItems[godKey];
//       selectedItems.remove(godKey);
//       if (godId != null) {
//         selectedGod.removeWhere((id) => id == godId.toString());
//       }
//       godApiResponseIds.remove(godKey);
//       pickedImageFiles.remove(godKey);
//       godApiLoadingStates.remove(godKey);
//       imageUploadLoadingStates.remove(godKey);
//     });
//
//     final cubit = context.read<ContributeTempleCubit>();
//     cubit.setSelectedGods(
//       selectedItems: selectedItems,
//       selectedGod: selectedGod,
//       godApiResponseIds: godApiResponseIds,
//     );
//
//     // Update images
//     Map<String, dynamic> updatedImages = Map.from(cubit.godImages);
//     updatedImages.remove(godKey);
//     cubit.setGodImages(updatedImages);
//
//     debugPrint("Deleted god: $godKey, remaining: $selectedItems");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
//       builder: (context, state) {
//         if (state is ContributeTempleLoaded) {
//           final cubit = context.read<ContributeTempleCubit>();
//           if (cubit.selectedItems.isNotEmpty && selectedItems.isEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               setState(() {
//                 selectedItems = Map.from(cubit.selectedItems);
//                 selectedGod = List.from(cubit.selectedGod);
//                 godApiResponseIds = Map.from(cubit.godApiResponseIds );
//               });
//             });
//           }
//         }
//
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Search and dropdown container
//               Text(StringConstant.select),
//               Gap(10.h),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColor.boxColor),
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 8.sp),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.sp),
//                         child: Text(
//                           "${StringConstant.tabAdd} ${StringConstant.gods}",
//                           style: const TextStyle(color: AppColor.lightTextColor),
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       child: !showItems
//                           ? const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: AppColor.lightTextColor,
//                       )
//                           : const Icon(
//                         Icons.close,
//                         color: AppColor.lightTextColor,
//                       ),
//                       onTap: () {
//                         setState(() {
//                           showItems = !showItems;
//                           if (!showItems) {
//                             _clearSearch();
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Gap(4.h),
//
//               // God selection list
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 300),
//                 child: showItems
//                     ? BlocProvider(
//                   create: (context) => GodFormCubit()..fetchGodForm(),
//                   child: BlocBuilder<GodFormCubit, GodFormState>(
//                     builder: (context, state) {
//                       if (state is GodFormLoaded) {
//                         if (state.loadingState) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         if (state.errorMessage.isNotEmpty) {
//                           return Center(child: Text(state.errorMessage));
//                         }
//                         _filterGodList(state.godList);
//
//                         return Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 0.sp),
//                           child: SizedBox(
//                             height: 280.h,
//                             child: Container(
//                               margin: EdgeInsets.only(top: 4.h),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(4.r),
//                                 border: Border.all(color: AppColor.boxColor),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               constraints: BoxConstraints(
//                                 maxHeight: 300.h,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Expanded(
//                                     child: _filteredGodList.isEmpty
//                                         ? Center(
//                                       child: Text(
//                                         _searchQuery.isNotEmpty
//                                             ? 'No gods found for "$_searchQuery"'
//                                             : 'No gods available',
//                                         style: TextStyle(
//                                           color: AppColor.lightTextColor,
//                                           fontSize: 14.sp,
//                                         ),
//                                       ),
//                                     )
//                                         : ListView.builder(
//                                       shrinkWrap: true,
//                                       itemCount: _filteredGodList.length,
//                                       itemBuilder: (context, index) {
//                                         final items = _filteredGodList[index];
//                                         // final isLoading = godApiLoadingStates[items?.title] ?? false;
//
//                                         return Padding(
//                                           padding:  EdgeInsets.symmetric(horizontal: 18.0.sp, vertical: 6.sp),
//                                           child: Row(
//                                             children: [
//
//                                               // Gap(10.w),
//                                               Expanded(child: Text(items.title ?? '')),
//                                               BorderedCheckbox(
//                                                 value:
//                                                 selectedItems.containsKey(items.title),
//                                                 onChanged: (bool? value) {
//                                                   _handleGodSelection(items, value);
//                                                 },
//                                                 activeColor: AppColor.appbarBgColor,
//                                                 inactiveBorderColor: AppColor.greyColor,
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       return const Center(child: CircularProgressIndicator());
//                     },
//                   ),
//                 )
//                     : const SizedBox.shrink(),
//               ),
//
//               // Selected gods chips
//               Wrap(
//                 spacing: 8.0.sp,
//                 children: selectedItems.entries.map((item) {
//                   final isLoading = godApiLoadingStates[item.key] ?? false;
//
//                   return Chip(
//                     backgroundColor: const Color(0xffFDF2EE),
//                     label: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           item.key,
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         if (isLoading) ...[
//                           SizedBox(width: 8.sp),
//                           SizedBox(
//                             width: 12.sp,
//                             height: 12.sp,
//                             child: const CircularProgressIndicator(
//                               strokeWidth: 1.5,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                     deleteIcon: const Icon(Icons.close),
//                     onDeleted: () {
//                       _deleteGodChip(item.key);
//                     },
//                   );
//                 }).toList(),
//               ),
//               Gap(10.h),
//
//               // Upload images section
//               selectedItems.isNotEmpty
//                   ? Text(
//                 StringConstant.uploadImages,
//                 textAlign: TextAlign.start,
//                 style: Theme.of(context).textTheme.bodyMedium,
//               )
//                   : const SizedBox.shrink(),
//               Gap(20.h),
//
//               // Image grid
//               selectedItems.isNotEmpty
//                   ? BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
//                 builder: (context, state) {
//                   if (state is ContributeTempleLoaded) {
//                     return GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 8.0,
//                         mainAxisSpacing: 8.0,
//                       ),
//                       itemCount: selectedItems.length,
//                       itemBuilder: (context, index) {
//                         String title = selectedItems.keys.toList()[index];
//                         final isUploading = imageUploadLoadingStates[title] ?? false;
//                         final hasApiId = godApiResponseIds.containsKey(title);
//
//                         return InkWell(
//                           onTap: hasApiId ? () => showImagePicker(title) : null,
//                           child: Container(
//                             height: 180.h,
//                             width: 160.h,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(4.r),
//                               color: pickedImageFiles[title] != null
//                                   ? null
//                                   : AppColor.blackColor.withOpacity(0.40),
//                               image: pickedImageFiles[title] != null
//                                   ? DecorationImage(
//                                 image: FileImage(pickedImageFiles[title]!),
//                                 fit: BoxFit.cover,
//                                 colorFilter: ColorFilter.mode(
//                                   AppColor.blackColor.withOpacity(0.20),
//                                   BlendMode.darken,
//                                 ),
//                               )
//                                   : null,
//                             ),
//                             child: Stack(
//                               children: [
//                                 // Main content
//                                 Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       Gap(40.h),
//                                       if (isUploading)
//                                         const CircularProgressIndicator(
//                                           color: AppColor.whiteColor,
//                                         )
//                                       else if (pickedImageFiles[title] != null)
//                                         Icon(
//                                           Icons.add,
//                                           color: AppColor.whiteColor,
//                                           size: 40.sp,
//                                         )
//                                       else
//                                         SvgPicture.asset(
//                                           "assets/icon/Plus.svg",
//                                           height: 50.sp,
//                                           width: 50.sp,
//                                           color: hasApiId
//                                               ? AppColor.whiteColor
//                                               : AppColor.whiteColor.withOpacity(0.5),
//                                         ),
//                                       Gap(20.h),
//                                       Text(
//                                         title,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium
//                                             ?.copyWith(
//                                           color: hasApiId
//                                               ? AppColor.whiteColor
//                                               : AppColor.whiteColor.withOpacity(0.5),
//                                         ),
//                                       ),
//
//                                     ],
//                                   ),
//                                 ),
//
//                                 if (isUploading)
//                                   Positioned(
//                                     top: 8.h,
//                                     right: 8.h,
//                                     child: Container(
//                                       padding: EdgeInsets.all(4.sp),
//                                       decoration: BoxDecoration(
//                                         color: AppColor.blackColor.withOpacity(0.7),
//                                         borderRadius: BorderRadius.circular(4.r),
//                                       ),
//                                       child: Text(
//                                         'Uploading...',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodySmall
//                                             ?.copyWith(
//                                           color: AppColor.whiteColor,
//                                           fontSize: 10.sp,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox();
//                 },
//               )
//                   : const SizedBox.shrink(),
//
//               // Footer and guidelines
//               CommonFooterText(
//                 onNextTap: widget.onNext,
//                 onBackTap: widget.onBack,
//               ),
//               Gap(20.h),
//               Guideline(
//                 title: StringConstant.guideline,
//                 points: [
//                   StringConstant.godGuideline,
//                   StringConstant.godSubGuideline,
//                   StringConstant.uploadGodImages,
//                   StringConstant.uploadGodHighQualityImages,
//                 ],
//               ),
//               Gap(10.h),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
//