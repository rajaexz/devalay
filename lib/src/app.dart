import 'dart:io';

import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_cubit.dart';
import 'package:devalay_app/src/application/assign/assign_cubit.dart';
import 'package:devalay_app/src/application/authentication/login/login_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/god_form/god_form_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_dev/explore_dev_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_event/explore_event_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_festival/explore_festival_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_puja/explore_puja_cubit.dart';
import 'package:devalay_app/src/application/feed/notification/notification_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_cancelled_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_completed_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_processing_cubit.dart';
import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/application/language/language_cubit.dart';
import 'package:devalay_app/src/application/profile/noti_setting/noti_setting_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_saved/profile_saved_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_%20comment.dart/feed_comment_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/utils/theme.dart';
import 'package:devalay_app/src/presentation/core/widget/network_connectivity_wrapper.dart';
import 'package:devalay_app/src/presentation/widgets/update_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/authentication/setting/setting_cubit.dart';
import 'application/contribution/contribution_event/contribution_event_cubit.dart';
import 'application/profile/profile_info_about/profile_info_cubit.dart';
import 'application/profile/profile_profile/profile_profile_cubit.dart';

// Global navigator key for showing dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
            !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>(create: (context) => LanguageCubit()),
        BlocProvider(create: (_) => LoginCubit()),
           BlocProvider(create: (_) => NotiSettingCubit()),
            BlocProvider(create: (_) => AdminOrderDetailCubit()),
           
        BlocProvider(create: (_) => ExploreDevalayCubit()),
        BlocProvider(create: (_) => ExploreEventCubit()),
        BlocProvider(create: (_) => ExploreFestivalCubit()),
        BlocProvider(create: (_) => ExplorePujaCubit()),
        BlocProvider(create: (_) => ExploreDevCubit()),
        BlocProvider(create: (_) => ContributeTempleCubit()),
        BlocProvider(create: (_) => ContributeEventCubit()),
        BlocProvider(create: (_) => ContributeDevCubit()),
        BlocProvider(create: (_) => ContributePujaCubit()),
        BlocProvider(create: (_) => ContributeFestivalCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => FeedCommentCubit()),
        BlocProvider(create: (_) => GobelSearchCubit()),
        BlocProvider(create: (_) => FeedHomeCubit()),
        BlocProvider(create: (_) => ProfileInfoCubit()),
        BlocProvider(create: (_) => ProfileLikedTempleCubit()),
        BlocProvider(create: (_) => ProfileSavedCubit()),
        BlocProvider(create: (_) => GodFormCubit()),
        BlocProvider(create: (_) => ProfileConnectionsCubit()),
        BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(create: (_) => ServiceCubit()),
        BlocProvider(create: (_) => SettingCubit()),
        BlocProvider(create: (context) => OrderCubit()),
        BlocProvider(create: (context) => OrderProcessingCubit()),
        BlocProvider(create: (context) => OrderCompletedCubit()),
        BlocProvider(create: (context) => OrderCancelledCubit()),
        BlocProvider(create: (context) => JobCubit()),
        BlocProvider(create: (context) => AssignCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return NetworkConnectivityWrapper(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: _AppWithUpdateCheck(
                child: MaterialApp.router(
                  locale: context.locale,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.light,
                  themeMode: ThemeMode.light,
                  scrollBehavior: ScrollConfiguration.of(context)
                      .copyWith(physics: const BouncingScrollPhysics()),
                  routerConfig: AppRouter.router,
                  builder: (context, child) {
                    final mediaQueryData = MediaQuery.of(context);
                    const scale = 1.0;
                    return MediaQuery(
                      data: mediaQueryData.copyWith(textScaleFactor: scale),
                      child: Navigator(
                        key: navigatorKey,
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) => child!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Runs [UpdateService.checkForUpdates] once after a short delay when the app is ready.
class _AppWithUpdateCheck extends StatefulWidget {
  const _AppWithUpdateCheck({required this.child});

  final Widget child;

  @override
  State<_AppWithUpdateCheck> createState() => _AppWithUpdateCheckState();
}

class _AppWithUpdateCheckState extends State<_AppWithUpdateCheck> {
  static const String _androidPackageId = 'com.devalay';
  // Replace with your iOS App Store ID (numeric) when published, e.g. '1234567890'
  static const String _iosAppStoreId = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        final ctx = navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          UpdateService(
            androidId: _androidPackageId,
            iOSId: _iosAppStoreId,
            useImmediateUpdateOnAndroid: true,
          ).checkForUpdates(ctx);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}