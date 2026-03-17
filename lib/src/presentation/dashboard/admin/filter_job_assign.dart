import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart'
    show AppColor;
import 'package:devalay_app/src/presentation/search/filter/admin_asign_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/kirti/service/service_cubit.dart';
import '../../../application/kirti/service/service_state.dart';
import '../../../data/model/kirti/category_model.dart';
import '../../../data/model/kirti/expertise_model.dart';
import '../../../data/model/kirti/fetch_skill_model.dart';
import '../../../data/model/kirti/language_model.dart';

class FilterJobAssign extends StatefulWidget {
  final AdminOrderDetailModel? order;
  final String? orderId;

  const FilterJobAssign({
    super.key,
    this.order,
    this.orderId,
  }) : assert(order != null || orderId != null, 'Either order or orderId must be provided');

  @override
  _FilterJobAssignState createState() => _FilterJobAssignState();
}

class _FilterJobAssignState extends State<FilterJobAssign> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Dynamic selections (same data as AddSkillScreen)
  LanguageModel? selectedRole;
  CategoryModel? selectedCategory;
  ExpertiseModel? selectedExpertise;

  /// IDs used for API calls
  String selectedRoleId = '';
  String selectedCategoryId = '';

  /// Dropdown visibility flags
  bool showRoleList = false;
  bool showCategoryList = false;
  bool showExpertiseList = false;

  late ServiceCubit serviceCubit;

  // Helper method to get orderId
  int get _orderId {
    if (widget.order?.id != null) {
      return widget.order!.id!;
    } else if (widget.orderId != null) {
      return int.tryParse(widget.orderId!) ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    serviceCubit = context.read<ServiceCubit>();
    serviceCubit.fetchRoleData();
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
    
    // Auto-refresh when page opens if expertise is already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (serviceCubit.expId != null) {
        serviceCubit.fetchAvailablePandits(
          orderId: _orderId,
          expertiseIds: [serviceCubit.expId!],
          query: serviceCubit.currentFilterQuery,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more pandits when near bottom
      serviceCubit.loadMorePandits();
    }
  }

  @override
  Widget build(BuildContext context) {
    void showDevBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColor.transparentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        builder: (context) => AdminAsignFilterWidget(order: widget.order),
      ).then((_) {
        // Refresh list when filter bottom sheet closes (in case filters were applied)
        // applyFilters already handles the refresh, but this ensures UI updates
        if (mounted && serviceCubit.expId != null) {
          // Small delay to ensure applyFilters completes
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
      });
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: Text(
            'Assign Order',  
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xE6000000), // rgba(0,0,0,0.9)
              letterSpacing: 1,
            ),
          ),
          centerTitle: false,
        ),
        body: BlocConsumer<ServiceCubit, ServiceState>(
          listener: (context, state) {
            if (state is ServiceLoadedState) {
              if (state.errorMessage.isNotEmpty) {
                final isSuccess =
                    state.errorMessage.toLowerCase().contains('success');
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: isSuccess ? Colors.green : Colors.red,
                    ),
                  );
                serviceCubit.clearError();
              }
              
              // Auto-refresh when availablePandits list changes (after filter applied)
              if (state.availablePandits != null && serviceCubit.expId != null) {
                // This ensures the list is refreshed when filters are applied
              }
            }
          },
          builder: (context, state) {
            final isLoading =
                state is ServiceLoadedState && state.loadingState == true;

            final roleList = state is ServiceLoadedState
                ? (state.languageList ?? [])
                : <LanguageModel>[];

            final categoryList = state is ServiceLoadedState
                ? (state.categoryList ?? [])
                : <CategoryModel>[];

            final expertiseList = state is ServiceLoadedState
                ? (state.expertiseList ?? [])
                : <ExpertiseModel>[];

            final availablePandits = state is ServiceLoadedState
                ? (state.availablePandits ?? [])
                : <Pandit>[];

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh pandits list with current filters
                if (serviceCubit.expId != null) {
                  await serviceCubit.fetchAvailablePandits(
                    orderId: _orderId,
                    expertiseIds: [serviceCubit.expId!],
                    query: serviceCubit.currentFilterQuery,
                    loadMore: false,
                  );
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 16.h, left: 15.w, right: 15.w, top: 0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select service provider',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Search bar - Figma design
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(fontSize: 12.sp),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0x993C3C43), // rgba(60,60,67,0.6)
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: const Color(0x993C3C43),
                                  size: 20.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 11.w,
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            showDevBottomSheet();
                          },
                          child: Container(
                            width: 16.w,
                            height: 18.h,
                            child: Icon(
                              Icons.filter_list,
                              color: Colors.grey[600],
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Filters (Role / Category / Expertise) - Figma design
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Column(
                      children: [
                        // Role
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xD9345484), // rgba(52,64,84,0.85)
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showRoleList = !showRoleList;
                                  showCategoryList = false;
                                  showExpertiseList = false;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: 42.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0x2E3C3C43), // rgba(60,60,67,0.18)
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedRole?.name ?? 'Select Role',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: selectedRole == null
                                              ? Colors.grey[500]
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      showRoleList
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey[600],
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if (showRoleList)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: isLoading && roleList.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: roleList.length,
                                    itemBuilder: (context, index) {
                                      final role = roleList[index];
                                      final isSelected =
                                          selectedRole?.id == role.id;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedRole = role;
                                            selectedRoleId =
                                                role.id?.toString() ?? '';
                                            // reset dependent selections
                                            selectedCategory = null;
                                            selectedExpertise = null;
                                            selectedCategoryId = '';
                                            showRoleList = false;
                                            showCategoryList = false;
                                            showExpertiseList = false;
                                          });
                                          if (selectedRoleId.isNotEmpty) {
                                            serviceCubit.fetchCategoryData(
                                                selectedRoleId);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          color: isSelected
                                              ? Colors.blue.withOpacity(0.06)
                                              : Colors.transparent,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  role.name ?? '',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.black,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        const SizedBox(height: 12),

                        // Category
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xD9345484), // rgba(52,64,84,0.85)
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: selectedRoleId.isEmpty
                                  ? null
                                  : () {
                                      setState(() {
                                        showCategoryList = !showCategoryList;
                                        showRoleList = false;
                                        showExpertiseList = false;
                                      });
                                    },
                              child: Container(
                                width: double.infinity,
                                height: 42.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: selectedRoleId.isEmpty
                                      ? Colors.grey[100]
                                      : Colors.white,
                                  border: Border.all(
                                    color: const Color(0x2E3C3C43), // rgba(60,60,67,0.18)
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedRoleId.isEmpty
                                            ? 'Select Role first'
                                            : (selectedCategory?.category ??
                                                'Select Category'),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: selectedRoleId.isEmpty
                                              ? Colors.grey[500]
                                              : (selectedCategory == null
                                                  ? Colors.grey[500]
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      showCategoryList
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey[600],
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if (showCategoryList && selectedRoleId.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: isLoading && categoryList.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : categoryList.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'No categories available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: categoryList.length,
                                        itemBuilder: (context, index) {
                                          final category = categoryList[index];
                                          final isSelected =
                                              selectedCategory?.id ==
                                                  category.id;
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedCategory = category;
                                                selectedCategoryId =
                                                    category.id?.toString() ??
                                                        '';
                                                selectedExpertise = null;
                                                showCategoryList = false;
                                                showExpertiseList = false;
                                              });
                                              if (selectedRoleId.isNotEmpty &&
                                                  selectedCategoryId
                                                      .isNotEmpty) {
                                                serviceCubit.fetchExpertiseData(
                                                  selectedRoleId,
                                                  selectedCategoryId,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              color: isSelected
                                                  ? Colors.blue
                                                      .withOpacity(0.06)
                                                  : Colors.transparent,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      category.category ?? '',
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.blue
                                                            : Colors.black,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    const Icon(
                                                      Icons.check,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        const SizedBox(height: 12),

                        // Expertise
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expertise',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xD9345484), // rgba(52,64,84,0.85)
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: selectedCategoryId.isEmpty
                                  ? null
                                  : () {
                                      setState(() {
                                        showExpertiseList = !showExpertiseList;
                                        showRoleList = false;
                                        showCategoryList = false;
                                      });
                                    },
                              child: Container(
                                width: double.infinity,
                                height: 42.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: selectedCategoryId.isEmpty
                                      ? Colors.grey[100]
                                      : Colors.white,
                                  border: Border.all(
                                    color: const Color(0x2E3C3C43), // rgba(60,60,67,0.18)
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedCategoryId.isEmpty
                                            ? 'Select Category first'
                                            : (selectedExpertise?.expertise ??
                                                'Select Expertise'),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: selectedCategoryId.isEmpty
                                              ? Colors.grey[500]
                                              : (selectedExpertise == null
                                                  ? Colors.grey[500]
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      showExpertiseList
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.grey[600],
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (showExpertiseList && selectedCategoryId.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: isLoading && expertiseList.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : expertiseList.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'No expertise available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: expertiseList.length,
                                        itemBuilder: (context, index) {
                                          final exp = expertiseList[index];
                                          final isSelected =
                                              selectedExpertise?.id == exp.id;
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedExpertise = exp;
                                                showExpertiseList = false;
                                              });
                                              final expId = exp.id;
                                              if (expId != null) {
                                                serviceCubit.expId = expId;
                                                serviceCubit
                                                    .fetchAvailablePandits(
                                                        orderId: _orderId,
                                                        expertiseIds: [expId],
                                                        query: serviceCubit.currentFilterQuery);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              color: isSelected
                                                  ? Colors.blue
                                                      .withOpacity(0.06)
                                                  : Colors.transparent,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      exp.expertise ?? '',
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.blue
                                                            : Colors.black,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    const Icon(
                                                      Icons.check,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 19.h),

                  // Available Service Providers header - Figma design
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Service Providers (${availablePandits.length})',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Service providers list (dynamic from API) - Figma design
                  if (availablePandits.isEmpty && !isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                        child: Text(
                          'No providers found for selected filters',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availablePandits.length + (serviceCubit.hasMorePandits && availablePandits.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == availablePandits.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final pandit = availablePandits[index];
                        return _buildServiceProviderCard(pandit);
                      },
                    ),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  String _resolvePanditName(Pandit pandit) {
    if ((pandit.name ?? '').trim().isNotEmpty) {
      return pandit.name!.trim();
    }

    final parts = <String>[];
    if ((pandit.firstName ?? '').trim().isNotEmpty) {
      parts.add(pandit.firstName!.trim());
    }
    if ((pandit.lastName ?? '').trim().isNotEmpty) {
      parts.add(pandit.lastName!.trim());
    }
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    if ((pandit.username ?? '').trim().isNotEmpty) {
      return pandit.username!.trim();
    }

    return 'Pandit';
  }

  Widget _buildServiceProviderCard(Pandit pandit) {
    final displayName = _resolvePanditName(pandit);
    final location = pandit.biography ?? '';
    final phone = pandit.phone ?? '';
    final rating = pandit.rating ?? 0;
    final jobsCompleted = pandit.jobsCompleted ?? 0;
    final isRequested = pandit.requestStatus == "Requested";

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.w, top: 15.h, right: 8.w, bottom: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Profile, Name, Location, Contact, Pandit badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image with orange border (2px, #fe9f1e)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFE9F1E),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28.5.r,
                    backgroundImage:
                        pandit.dp != null && pandit.dp!.isNotEmpty
                            ? NetworkImage(pandit.dp!)
                            : null,
                    backgroundColor: Colors.grey[300],
                    child: pandit.dp == null || pandit.dp!.isEmpty
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20.sp,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF262626),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        location.isNotEmpty ? location : 'N/A',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0x66000000), // rgba(0,0,0,0.4)
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        phone.isNotEmpty ? 'Contact No. $phone' : 'Contact No. N/A',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0x66000000), // rgba(0,0,0,0.4)
                        ),
                      ),
                    ],
                  ),
                ),
                // Pandit badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB040),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Pandit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // Three sections: Ratings, Jobs completed, Total no.of jobs completed
            Row(
              children: [
                // Ratings section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ratings',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF241601),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: List.generate(5, (index) {
                          final starRating = rating.floor();
                          return Icon(
                            index < starRating
                                ? Icons.star
                                : Icons.star_outline,
                            color: Colors.amber[600],
                            size: 16.sp,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 9.w),
                // Jobs completed section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jobs completed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF241601),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        '$jobsCompleted Pooja',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF241601),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 9.w),
                // Total no.of jobs completed section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total no.of jobs completed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF241601),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: List.generate(5, (index) {
                          // Calculate stars based on jobs completed (1 star per 10 jobs, max 5 stars)
                          final starRating = ((jobsCompleted / 10).floor()).clamp(0, 5);
                          return Icon(
                            index < starRating
                                ? Icons.star
                                : Icons.star_outline,
                            color: Colors.amber[600],
                            size: 16.sp,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // Assign/Request Send button
            SizedBox(
              width: double.infinity,
              height: 31.h,
              child: ElevatedButton(
                onPressed: pandit.id == null || isRequested
                    ? null
                    : () {
                        final panditId = pandit.id!;
                        serviceCubit.requestPandits(
                          orderId: _orderId,
                          panditIds: [panditId],
                        );
                        setState(() {
                          pandit.requestStatus = "Requested";
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRequested
                      ? const Color(0xFF12B76A) // Green for requested
                      : Colors.white,
                  foregroundColor: isRequested
                      ? Colors.white
                      : const Color(0xFF0B0B0B),
                  side: isRequested
                      ? BorderSide.none
                      : const BorderSide(
                          color: Color(0xFF555151),
                          width: 1,
                        ),
                  padding: EdgeInsets.symmetric(horizontal: 54.w, vertical: 3.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: isRequested
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Request Send',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Assign',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF0B0B0B),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
