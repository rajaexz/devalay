import 'package:devalay_app/src/application/feed/notification/notificatio_state.dart';
import 'package:devalay_app/src/application/feed/notification/notification_cubit.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/data/model/feed/notification_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/notification/web_socket/web_socket.dart';
import 'package:devalay_app/src/presentation/notification/widget/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late NotificationCubit _notificationCubit;
  late NotificationSocketService _socketService;
  late ScrollController _scrollController;
  late TabController _tabController;

  final List<String> _tabs = [
    'All',
    'Temple',
    'People',
    'Event',
    'God',
    'Dashboard'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationCubit = context.read<NotificationCubit>();
    _socketService = NotificationSocketService();
    _scrollController = ScrollController();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChange);

    _socketService.connectWithCookie();
    _socketService.loadNotificationCount();

    // Initial fetch for "All" tab
    _initializeNotifications();
        
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketService.resetNotificationCount();
    });
  }

  void _initializeNotifications() {
    _notificationCubit.fetchNotification(
      isRead: false,
      isRefresh: true,
      type: _tabs[0] // Start with first tab
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreNotifications();
    }
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) {
      // Fetch notifications for the new tab
      final selectedTab = _tabs[_tabController.index];

      _notificationCubit.fetchNotification(
        isRead: false,
        isRefresh: true,
        type: selectedTab
      );
    }
  }

  void _loadMoreNotifications() {
    final state = _notificationCubit.state;
    if (state is NotificationLoaded &&
        state.hasMoreData &&
        !state.isLoadingMore) {
      _notificationCubit.loadMoreNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                isScrollable: true,
                controller: _tabController,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.whiteColor
                    : AppColor.blackColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColor.appbarBgColor,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final selectedTab = _tabs[_tabController.index];
                  
                  _notificationCubit.fetchNotification(
                      isRead: false, 
                      isRefresh: true, 
                      type: selectedTab
                  );
                  
                  // Wait for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocConsumer<NotificationCubit, NotificationState>(
                  listener: (context, state) {
                    // Handle any additional state changes if needed
                  },
                  builder: (context, state) {
                    if (state is NotificationInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is NotificationLoaded) {
                      if (state.loadingState && (state.data?.isEmpty ?? true)) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.hasError && (state.data?.isEmpty ?? true)) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64.w,
                                color: Colors.grey.shade400,
                              ),
                              Gap(16.h),
                              Text(
                                state.errorMessage ?? 'An error occurred',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {
                                  final selectedTab = _tabs[_tabController.index];
                                  
                                  _notificationCubit.fetchNotification(
                                      isRead: false, 
                                      isRefresh: true, 
                                      type: selectedTab
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.data?.isEmpty ?? true) {
                        return Center(
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 3),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: 64.w,
                                      color: Colors.grey.shade400,
                                    ),
                                    Gap(16.h),
                                    Text(
                                      'No ${_tabs[_tabController.index].toLowerCase() == 'all' ? '' : _tabs[_tabController.index].toLowerCase()} notifications yet',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildNotificationList(state.data!, state);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 30,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        StringConstant.notification,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      leading: IconButton(
        onPressed: () {
          AppRouter.pop();
        },
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            _notificationCubit.markAllAsRead();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(
            Icons.done_all,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationList(
      List<NotificationModel> notifications, NotificationLoaded state) {
    final Map<String, List<NotificationModel>> groupedNotifications = {};

    for (final notification in notifications) {
      if (notification.createdAt == null) {
        continue;
      }

      try {
        final DateTime createdDate = DateTime.parse(notification.createdAt!);
        String groupKey;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final notificationDate =
            DateTime(createdDate.year, createdDate.month, createdDate.day);

        if (notificationDate == today) {
          groupKey = 'Today';
        } else if (notificationDate == yesterday) {
          groupKey = 'Yesterday';
        } else if (now.difference(notificationDate).inDays <= 7) {
          groupKey = 'This week';
        } else {
          groupKey = DateFormat('MMMM d, yyyy').format(createdDate);
        }

        if (!groupedNotifications.containsKey(groupKey)) {
          groupedNotifications[groupKey] = [];
        }

        groupedNotifications[groupKey]!.add(notification);
      } catch (e) {
        print("Error parsing date for notification ${notification.id}: $e");
      }
    }

    final List<Widget> listItems = [];

    // Sort groups by date (newest first)
    final sortedGroups = groupedNotifications.entries.toList()
      ..sort((a, b) {
        // Custom sorting to put Today, Yesterday, This week first
        if (a.key == 'Today') return -1;
        if (b.key == 'Today') return 1;
        if (a.key == 'Yesterday') return -1;
        if (b.key == 'Yesterday') return 1;
        if (a.key == 'This week') return -1;
        if (b.key == 'This week') return 1;
        
        // For other dates, sort chronologically (newest first)
        try {
          final dateA = DateFormat('MMMM d, yyyy').parse(a.key);
          final dateB = DateFormat('MMMM d, yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

    for (final entry in sortedGroups) {
      final date = entry.key;
      final notificationsList = entry.value;
      
      // Sort notifications within group by creation time (newest first)
      notificationsList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt ?? '');
          final dateB = DateTime.parse(b.createdAt ?? '');
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      listItems.add(_buildSectionHeader(date));

      for (final notification in notificationsList) {
        listItems.add(
          Dismissible(
            key: ValueKey("notification_${notification.id}"),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              if (notification.id != null) {
                _notificationCubit.removeNotification(notification.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification removed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: GestureDetector(
              onTap: () {
                // Mark single notification as read when tapped
                if (notification.id != null && !(notification.isRead ?? false)) {
                  _notificationCubit.markSingleAsRead(notification.id!);
                }
                _handleNotificationTap(notification);
              },
              child: Column(
                children: [
                  NotiCard(notification: notification),
                  Gap(10.h),
                ],
              ),
            ),
          ),
        );
      }
      
      // Add some spacing between groups
      if (entry != sortedGroups.last) {
        listItems.add(Gap(20.h));
      }
    }

    // Loading more indicator
    if (state.isLoadingMore) {
      listItems.add(
        Padding(
          padding: EdgeInsets.all(16.h),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // No more data indicator
    if (!state.hasMoreData && notifications.isNotEmpty) {
      listItems.add(
        Padding(
          padding: EdgeInsets.all(16.h),
          child: Center(
            child: Text(
              'No more notifications',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: listItems.length,
        itemBuilder: (context, index) => listItems[index],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {

    // Navigate based on the notification type and available data
    if (notification.type != null) {
      final type = notification.type!.toLowerCase();
      if ((type == 'temple' || type == 'event' || type == 'post') &&
          notification.post?.id != null) {
        AppRouter.push('${RouterConstant.feedDetail}/${notification.post!.id}');
      } else if (type == 'people' && notification.actionUser?.id != null) {
        AppRouter.push(
            '${RouterConstant.profileMainScreen}/${notification.actionUser!.id}/profile');
      } else if (type == 'dashboard' && notification.post?.id != null) {
        AppRouter.push('${RouterConstant.feedDetail}/${notification.post!.id}');
      } else if (notification.actionUser?.id != null) {
        AppRouter.push(
            '${RouterConstant.profileMainScreen}/${notification.actionUser!.id}/profile');
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 6.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}