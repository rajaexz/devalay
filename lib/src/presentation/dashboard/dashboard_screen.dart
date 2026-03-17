import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/admin_assign_view_status.dart';
import 'package:devalay_app/src/presentation/dashboard/event/event_dashboard.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_view_status.dart';
import 'package:devalay_app/src/presentation/dashboard/order/order_view_status.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/approved.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/manage_temple.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/rejected.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/review_temple_widget.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/submitted.dart';
import 'package:devalay_app/src/presentation/dashboard/temple/temple_daraf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'god/dev_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  late ScrollController _scrollController;
  bool _showTitle = false;
  String? userName;
  String? userId;
  bool? isPandit;
  String? admin;
  bool isLoading = true; // Add loading state

  static const String _selectedTabKey = 'dashboard_selected_tab';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    // Don't initialize TabController until data is loaded
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load user data first (this triggers API call)
    await _loadUserData();
    // Wait for ProfileInfoCubit to fetch data from API
    await _loadAdminDataFromAPI();
    // Load saved state (only after TabController is created)
    await _loadSavedState();
    // Update loading state only after everything is loaded
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  


  void _updateTabController() {
    if (!mounted) return;
    
    final bool isAdminUser = admin == 'true';
    final bool showJobsTab = !isAdminUser && (isPandit ?? false);

    final int tabLength;
    if (isAdminUser) {
      tabLength = 4; // Temples, Events, Gods, Admin
    } else {
      tabLength = showJobsTab ? 5 : 4; // Temples, Events, Gods, Order, (Jobs if pandit)
    }

    // Only recreate TabController if length has changed
    if (_tabController == null || _tabController!.length != tabLength) {
      final int? previousIndex = _tabController?.index;
      _tabController?.dispose();
      _tabController = TabController(
        length: tabLength,
        vsync: this,
      );
      
      // Restore previous index if valid, otherwise set to 0
      if (previousIndex != null && previousIndex < tabLength) {
        _tabController!.index = previousIndex;
      }
      
      // Call setState to trigger rebuild with new TabController
      setState(() {});
    }
  }

  Future<void> _loadAdminDataFromAPI() async {
    // Get ProfileInfoCubit and wait for it to fetch data
    final profileCubit = context.read<ProfileInfoCubit>();
    
    // Wait for profile data to be fetched (with timeout)
    int attempts = 0;
    const maxAttempts = 20; // Wait up to 2 seconds (20 * 100ms)
    
    while (attempts < maxAttempts) {
      final state = profileCubit.state;
      if (state is ProfileInfoLoaded && !state.loadingState) {
        // Data is loaded, extract admin and isPandit
        final profileModel = state.profileInfoModel;
        if (profileModel != null) {
          // Get admin status (can be bool or string)
          if (profileModel.admin is bool) {
            admin = (profileModel.admin as bool).toString();
          } else if (profileModel.admin != null) {
            admin = profileModel.admin.toString();
          } else {
            admin = 'false';
          }
          
          // Get isPandit status
          isPandit = profileModel.isPandit ?? false;
          
          break;
        }
      }
      
      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Fallback to SharedPreferences if API data is not available
    if (admin == null || isPandit == null) {
      admin = await PrefManager.getAdmin() ?? 'false';
      isPandit = await PrefManager.getIsPandit() ?? false;
    }

    // Update TabController based on loaded data
    _updateTabController();
  }

  void _scrollListener() {
    final shouldShowTitle = _scrollController.offset > 100;
    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  Future<void> _loadUserData() async {
    userId = await PrefManager.getUserDevalayId();
    userName = await PrefManager.getUserName();
    // Initialize ProfileInfoCubit to fetch fresh data from API
    if (userId != null && userId!.isNotEmpty) {
      context.read<ProfileInfoCubit>().init(userId.toString());
    }
  }

  Future<void> _loadSavedState() async {
    if (_tabController == null) return;
    
    final savedTab = await PrefManager.getInt(_selectedTabKey);
    if (savedTab != null && savedTab < _tabController!.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController != null) {
          _tabController!.animateTo(savedTab);
        }
      });
    }
  }

  Future<void> _saveCurrentState() async {
    if (_tabController != null) {
      await PrefManager.setInt(_selectedTabKey, _tabController!.index);
    }
  }

  Widget _buildTabBar(List<Tab> tabs) {
    if (_tabController == null) {
      return const SizedBox.shrink();
    }
    
    return TabBar(
      controller: _tabController!,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelStyle: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.whiteColor
                : AppColor.blackColor,
          ),
      unselectedLabelColor: AppColor.lightTextColor,
      indicatorColor: AppColor.blackColor,
      indicatorWeight: 3,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 3.w, color: AppColor.blackColor),
        insets: EdgeInsets.zero,
      ),
      dividerColor: Colors.transparent,
      onTap: (index) {
        _saveCurrentState();
      },
      tabs: tabs,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Show loading indicator while data is being fetched or TabController is not ready
    if (isLoading || _tabController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isAdminUser = admin == 'true';
    final bool showJobsTab = !isAdminUser && (isPandit ?? false);

    final tabs = [
      Tab(text: StringConstant.temples),
      Tab(text: StringConstant.events),
      Tab(text: StringConstant.gods),
      if (!isAdminUser) Tab(text: StringConstant.order),
      if (showJobsTab) Tab(text: StringConstant.jobs),
      if (isAdminUser) const Tab(text: StringConstant.admin),
    ];

    final screenTabs = [
      const TempleViewDaraf(),
      const EventViewDaraf(),
      const DevView(),
      if (!isAdminUser) const OrderViewStatus(),
      if (showJobsTab) const JobViewStatus(),
      if (isAdminUser) const AdminAssignViewStatus(),
    ];

    return BlocListener<ProfileInfoCubit, ProfileInfoState>(
      listener: (context, state) {
        // Listen for profile data changes and update tabs accordingly
        if (state is ProfileInfoLoaded && !state.loadingState) {
          final profileModel = state.profileInfoModel;
          if (profileModel != null) {
            // Check if isPandit or admin status has changed
            final newIsPandit = profileModel.isPandit ?? false;
            String? newAdmin;
            if (profileModel.admin is bool) {
              newAdmin = (profileModel.admin as bool).toString();
            } else if (profileModel.admin != null) {
              newAdmin = profileModel.admin.toString();
            } else {
              newAdmin = 'false';
            }
            
            // Only update if values have changed
            if (newIsPandit != isPandit || newAdmin != admin) {
              isPandit = newIsPandit;
              admin = newAdmin;
              // Update TabController directly with new values
              _updateTabController();
            }
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,


                  children: [
                    Text(StringConstant.dashboard, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),),
                                   ],
                  ),
              ),
              _buildTabBar(tabs),
              Expanded(
                child: TabBarView(controller: _tabController!, children: screenTabs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class TempleViewDaraf extends StatefulWidget {
  const TempleViewDaraf({super.key});

  @override
  State<TempleViewDaraf> createState() => _TempleViewDarafState();
}

class _TempleViewDarafState extends State<TempleViewDaraf>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  String? admin;
  bool isLoading = true;

  static const String _selectedChipKey = 'temple_selected_chip';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadAdminData();
    await _loadSavedChipState();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadAdminData() async {
    // Load fresh admin data from API via ProfileInfoCubit
    final profileCubit = context.read<ProfileInfoCubit>();
    
    // Wait for profile data to be fetched (with timeout)
    int attempts = 0;
    const maxAttempts = 20; // Wait up to 2 seconds (20 * 100ms)
    
    while (attempts < maxAttempts) {
      final state = profileCubit.state;
      if (state is ProfileInfoLoaded && !state.loadingState) {
        // Data is loaded, extract admin
        final profileModel = state.profileInfoModel;
        if (profileModel != null) {
          // Get admin status (can be bool or string)
          if (profileModel.admin is bool) {
            admin = (profileModel.admin as bool).toString();
          } else if (profileModel.admin != null) {
            admin = profileModel.admin.toString();
          } else {
            admin = 'false';
          }
          break;
        }
      }
      
      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Fallback to SharedPreferences if API data is not available
    admin ??= await PrefManager.getAdmin() ?? 'false';
  }
  
  /// Refresh data when screen becomes visible
  Future<void> refreshData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await _initializeData();
  }

  Future<void> _loadSavedChipState() async {
    final savedChip = await PrefManager.getInt(_selectedChipKey);
    if (savedChip != null) {
      setState(() {
        selectedIndex = savedChip;
      });
      _handleSectionSelection(savedChip);
    }
  }

  Future<void> _saveChipState() async {
    await PrefManager.setInt(_selectedChipKey, selectedIndex);
  }

  void _handleSectionSelection(int index) {
    if (index > 4) return;
    final cubit = context.read<ContributeTempleCubit>();
    String? value;
    if (index == 3) {
      value = 'false';
    } else if (index == 4) {
      value = 'true';
    }
    cubit.applyFilter(
      newSectionIndex: index,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Show loading indicator while data is being fetched
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget buildChipTab(String label, int index) {
      final bool isSelected = selectedIndex == index;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: ChoiceChip(
          label: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(),
          ),
          selected: isSelected,
          selectedColor: AppColor.appbarBgColor2,
          side: BorderSide(
            color: isSelected
                ? AppColor.appbarBorderColor2
                : AppColor.blackColor.withOpacity(0.1),
          ),
          backgroundColor: isSelected
              ? AppColor.appbarBgColor2.withOpacity(0.1)
              : AppColor.whiteColor,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (_) {
            setState(() => selectedIndex = index);
            _saveChipState();
            _handleSectionSelection(index);
          },
        ),
      );
    }

    List<String> tabTitle = admin == 'true'
        ? [
            StringConstant.darft,
            StringConstant.submit,
            StringConstant.approved,
            StringConstant.rejected,
            StringConstant.manageTemple,
            StringConstant.reviewTemple,
          ]
        : [
            StringConstant.darft,
            StringConstant.submit,
            StringConstant.approved,
            StringConstant.rejected,
          ];

    Widget getSelectedWidget(int index) {
      switch (index) {
        case 0:
          return const TempleDaraf();
        case 1:
          return const Submitted();
        case 2:
          return const Approved();
        case 3:
          return const Rejected();
        case 4:
          return const ManageTemple();
        case 5:
          return const ReviewTempleWidget();
        default:
          return SizedBox(
            child: Text(StringConstant.noDataAvailable),
          );
      }
    }

    return Column(
      children: [
        Gap(10.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            clipBehavior: Clip.antiAlias,
            scrollDirection: Axis.horizontal,
            itemCount: tabTitle.length,
            itemBuilder: (context, index) {
              return buildChipTab(tabTitle[index], index);
            },
          ),
        ),
        Gap(10.h),
        Expanded(child: getSelectedWidget(selectedIndex))
      ],
    );
  }
}