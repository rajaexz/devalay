import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/application/kirti/service/service_state.dart';
import 'package:devalay_app/src/data/model/kirti/fetch_skill_model.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/add_skill_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/helper/loader.dart';

class ViewSkillScreen extends StatefulWidget {
  final String skillId;
  const ViewSkillScreen({super.key, required this.skillId});

  @override
  State<ViewSkillScreen> createState() => _ViewSkillScreenState();
}

class _ViewSkillScreenState extends State<ViewSkillScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCubit>().fetchSkillData(widget.skillId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.blackColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            if (state is ServiceLoadedState && state.fetchSkillModel != null) {
              final pandit = state.fetchSkillModel!.pandit;
              final displayName = _resolvePanditName(pandit);
              return Text(
                displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0B0B0B),
                      letterSpacing: 1,
                    ),
              );
            }
            return const Text('Skill Details');
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final currentState = context.read<ServiceCubit>().state;
              if (currentState is ServiceLoadedState &&
                  currentState.fetchSkillModel != null) {
                final isUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSkillScreen(
                      existingSkill: currentState.fetchSkillModel,
                    ),
                  ),
                );

                if (isUpdated == true && mounted) {
                  context.read<ServiceCubit>().fetchSkillData(widget.skillId);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skill information is still loading'),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColor.blackColor,
            ),
          ),
          IconButton(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Skill'),
                  content: const Text(
                      'Are you sure you want to delete this skill?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (!(shouldDelete ?? false) || !mounted) return;

              final deleted =
                  await context.read<ServiceCubit>().deleteSkillData(widget.skillId);

              if (!mounted) return;

              if (deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Skill deleted successfully')),
                );
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(
              Icons.delete_outline,
              color: AppColor.blackColor,
            ),
          ),

        ],
      ),
      body: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoadedState) {
            if (state.loadingState) {
              return const Center(child: CustomLottieLoader());
            }

            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }

            final skill = state.fetchSkillModel;

            if (skill == null) {
              return const Center(child: Text('No skill information found.'));
            }

            final skillsDetail = skill.skillsDetail;
            final workImages = skill.workImages;
            final experienceLabel =
                (skillsDetail?.experience?.trim().isNotEmpty ?? false)
                    ? skillsDetail!.experience!
                    : _mapExperience(skill.experience);
            final travelLabel =
                (skillsDetail?.travelPreference?.trim().isNotEmpty ?? false)
                    ? skillsDetail!.travelPreference!
                    : _mapTravelPreference(skill.travelPreference);
            final aboutText = _resolveAbout(skill.abouts);
            final availableOnline =
                skill.isAvailableForOnline ?? false;

            return SingleChildScrollView(
              padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 15.h, bottom: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skill Name with Edit Icon (Figma design)
                  _buildSkillNameWithEdit(
                    context: context,
                    skillName: skillsDetail?.role ?? '-',
                    onEdit: () async {
                      final currentState = context.read<ServiceCubit>().state;
                      if (currentState is ServiceLoadedState &&
                          currentState.fetchSkillModel != null) {
                        final isUpdated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddSkillScreen(
                              existingSkill: currentState.fetchSkillModel,
                            ),
                          ),
                        );

                        if (isUpdated == true && mounted) {
                          context.read<ServiceCubit>().fetchSkillData(widget.skillId);
                        }
                      }
                    },
                  ),
                  Gap(4.h),
                  // Category
                  Text(
                    [
                      skillsDetail?.category ?? '',
                      skillsDetail?.expertise ?? '',
                    ].where((value) => value.trim().isNotEmpty).join(' | '),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000).withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  Gap(14.h),
                  // Available for Online Services
                  _buildDetailRow(
                    context: context,
                    title: 'Available for Online Services',
                    value: availableOnline ? 'Yes' : 'No',
                  ),
                  Gap(4.h),
                  // Experience
                  _buildDetailRow(
                    context: context,
                    title: 'Experience',
                    value: experienceLabel,
                  ),
                  Gap(4.h),
                  // Travel preference
                  _buildDetailRow(
                    context: context,
                    title: 'Travel preference',
                    value: travelLabel,
                  ),
                  Gap(6.h),
                  // About
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000).withOpacity(0.8),
                    ),
                  ),
                  Gap(6.h),
                  Text(
                    aboutText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000).withOpacity(0.8),
                      height: 1.8,
                      letterSpacing: 0.42,
                    ),
                  ),
                  Gap(31.h),
                  // Work Showcase
                  Text(
                    'Work Showcase',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000).withOpacity(0.9),
                    ),
                  ),
                  Gap(15.h),
                  if (workImages!.isEmpty)
                    _buildPlaceholderGrid()
                  else
                    _buildWorkShowcaseGrid(workImages),
                ],
              ),
            );
          }

          return const Center(child: CustomLottieLoader());
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000).withOpacity(0.9),
          ),
        ),
        Gap(4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF000000).withOpacity(0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillNameWithEdit({
    required BuildContext context,
    required String skillName,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            skillName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF000000).withOpacity(0.9),
              letterSpacing: 1,
            ),
          ),
        ),
  
      ],
    );
  }

  Widget _buildWorkShowcaseGrid(List<dynamic> workImages) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 1.32,
      ),
      itemBuilder: (context, index) {
        final imageData = workImages[index];
        final imageUrl = imageData is Map ? (imageData["file"] ?? "") : imageData.toString();
        
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 0.93,
            ),
          ),
          child: Stack(
            children: [
              if (imageUrl.toString().isNotEmpty)
                Image.network(
                  imageUrl.toString(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFD9D9D9),
                    child: const Icon(Icons.broken_image),
                  ),
                )
              else
                Container(
                  color: const Color(0xFFD9D9D9),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 1.32,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 0.93,
          ),
          color: const Color(0xFFD9D9D9),
        ),
        child: const Icon(Icons.add, color: Colors.grey),
      ),
    );
  }


  String _resolvePanditName(Pandit? pandit) {
    if (pandit == null) return '-';

    final parts = <String>[
      if (pandit.firstName?.trim().isNotEmpty ?? false) pandit.firstName!.trim(),
      if (pandit.lastName?.trim().isNotEmpty ?? false) pandit.lastName!.trim(),
    ];

    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    if (pandit.name?.trim().isNotEmpty ?? false) {
      return pandit.name!.trim();
    }

    if (pandit.username?.trim().isNotEmpty ?? false) {
      return pandit.username!.trim();
    }

    return '-';
  }

  String _resolveAbout(dynamic abouts) {
    if (abouts == null) return 'No description added.';
    final text = abouts.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return 'No description added.';
    }
    return text;
  }


  String _mapExperience(int? experienceId) {
    switch (experienceId) {
      case 1:
        return '0+ year';
      case 2:
        return '1+ years';
      case 3:
        return '2+ years';
      case 4:
        return '3+ years';
      case 5:
        return '5+ years';
      case 6:
        return '10+ years';
      default:
        return '-';
    }
  }

  String _mapTravelPreference(dynamic travel) {
    if (travel == null) return '-';
    if (travel is String && travel.isNotEmpty) return travel;
    if (travel is int) {
      switch (travel) {
        case 1:
          return 'Local';
        case 2:
          return 'Outstation';
      }
    }
    return travel.toString();
  }
}
