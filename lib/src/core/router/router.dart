import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/dev/contribute_dev_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/devs_widget/add_dev_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/view_dev/view_dev_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/event/contribute_event_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/events_widget/add_event_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/view_event/view_event_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival/contribute_festival_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/add_festival_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/view_festival/view_festival_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja/contribute_puja_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/add_puja_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/view_puja/view_puja_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_temple/temple/contribute_temple_screen.dart';
import 'package:devalay_app/src/presentation/drawer/drawer_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/contact_us_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/help_center.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/add_skill_screen.dart';
import 'package:devalay_app/src/presentation/explore_search/dev/explore_dev_details.dart';
import 'package:devalay_app/src/presentation/feed/feed_comment_screen/feed_comment_screen.dart';
import 'package:devalay_app/src/presentation/feed/feed_deatail_screen/feed_deatil_screen.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_gallery_screen.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_screen.dart';
import 'package:devalay_app/src/presentation/intro_screen/first_intro_screen.dart';
import 'package:devalay_app/src/presentation/kriti/kriti_screen.dart';
import 'package:devalay_app/src/presentation/kriti/myorder_screen.dart';
import 'package:devalay_app/src/presentation/kriti/registration_screen.dart';
import 'package:devalay_app/src/presentation/kriti/service_provider.dart';
import 'package:devalay_app/src/presentation/kriti/widget/puja_service_detail_screen.dart';
import 'package:devalay_app/src/presentation/landing_screen.dart/landing_screen.dart';
import 'package:devalay_app/src/presentation/login_screen/login_screen.dart';
import 'package:devalay_app/src/presentation/login_screen/number_otp.dart';
import 'package:devalay_app/src/presentation/notification/notification.dart';
import 'package:devalay_app/src/presentation/profile/about/about_screen.dart';
import 'package:devalay_app/src/presentation/profile/profile_main_screen.dart';
import 'package:devalay_app/src/presentation/search/search_screen.dart';
import 'package:devalay_app/src/presentation/signup/sigin_screen.dart';
import 'package:devalay_app/src/presentation/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/contribute/add_temple/view_temple/view_temple_screen.dart';
import '../../presentation/create/create_temple/create_temple_screen.dart';
import '../../presentation/explore_search/event/explore_event_details.dart';
import '../../presentation/explore_search/festival/explore_festival_details.dart';
import '../../presentation/explore_search/temple/explore_temple_details.dart';
import '../../presentation/introduction_popup/introducion_popup_screen.dart';
import '../../presentation/profile/media/widget/media_list_scroller.dart';

class AppRouter {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter _router = GoRouter(
 redirect: (context, state) async {
  final uri = state.uri;
 
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
 
  final isAuthRequiredPath = segments.contains('singleDevalay') ||
      segments.contains('singlePuja') ||
      segments.contains('singleGod') ||
      segments.contains('feedDetail') ||
      segments.contains('singleDevotee') ||
      segments.contains('singleFestival') ||
      segments.contains('singleEvent');
  final isLoggedIn = await PrefManager.getUserSessionId();
  if (isLoggedIn == null && isAuthRequiredPath) {
    return RouterConstant.loginScreen;
  }
  
  if (segments.isNotEmpty) {
  
    if (segments.length >= 3 &&
        (segments[0] == 'apis' || segments[0] == 'api')) {
      final pathType = segments[1];
      final id = segments[2];
      switch (pathType) {
        case 'Devalay':
          return '/singleDevalay/$id';
        case 'Post':
          return '${RouterConstant.feedDetail}/$id';
        case 'Puja':
          return '/singlePuja/$id';
        case 'Festivel':
        case 'Festivals':
          return '/singleFestival/$id';
        case 'Dev':
        case 'Gods':
          return '/singleGod/$id';
        case 'Devotees':
          return '/singleDevotee/$id';
        case 'Event':
          return '/singleEvent/$id';
      }
    }
    // Pattern 2: /Post/123 (direct paths)
    else if (segments.length >= 2) {
      final pathType = segments[0];
      final id = segments[1];
      switch (pathType) {
        case 'Devalay':
          return '/singleDevalay/$id';
        case 'Post':
          return '${RouterConstant.feedDetail}/$id';
        case 'Puja':
          return '/singlePuja/$id';
        case 'Festivel':
        case 'Festivals':
          return '/singleFestival/$id';
        case 'Dev':
        case 'Gods':
          return '/singleGod/$id';
        case 'Devotees':
          return '/singleDevotee/$id';
        case 'Event':
          return '/singleEvent/$id';
      }
    }
  }
  return null;
},
    navigatorKey: navigatorKey,
    
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.introScreen,
        builder: (context, state) => const IntroScreen(),
      ),
      
      GoRoute(
        path:RouterConstant.createAddSkillScreen,
        
        builder: (context, state) { 
          
          return const AddSkillScreen(
         );},
      ),
      
          GoRoute(
        path: RouterConstant.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.landingScreen,
        builder: (context, state) => const LandingScreen(),
      ),
      
      // Feed Home Screen
      GoRoute(
        path: RouterConstant.feedHome,
        builder: (context, state) => const FeedScreen(),
      ),

      GoRoute(
        path: "${RouterConstant.createProfile}/:id/:type",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final type = state.pathParameters['type'];
          return IntroductionPopupScreen(
            id: int.parse(id.toString()),
            type: type,
          );
        },
      ),

      GoRoute(
        path: RouterConstant.feedCreate,
        builder: (context, state) {
          return InstagramGalleryPicker(
            onMediaSelected: (List<XFile> media) {},
          );
        },
      ),

      GoRoute(
        path: "${RouterConstant.feedComment}/:id",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return FeedCommentScreen(
            id: id ?? "",
            isAppbar: true,
          );
        },
      ),
      
      GoRoute(
        path: "${RouterConstant.feedDetail}/:id",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return FeedDetailScreen(id: id!);
        },
      ),

      // Deep link routes
      GoRoute(
        path: '/singleDevalay/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ExploreTempleDetails(id: id ?? "");
        },
      ),
      
      GoRoute(
        path: '/singleEvent/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ExploreEventDetails(id: id ?? "");
        },
      ),
      
      GoRoute(
        path: '/singleFestival/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ExploreFestivalDetails(id: id ?? "");
        },
      ),
      
      GoRoute(
        path: '/singleGod/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ExploreDevDetails(id: id ?? "");
        },
      ),
      
      GoRoute(
        path: '/singleDevotee/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ProfileMainScreen(
            id: id != null ? int.tryParse(id) : null,
            profileType: 'devotee',
          );
        },
      ),
      
      GoRoute(
        path: '/singlePuja/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ViewPujaScreen(
            pujaId: id ?? '',
            calledFrom: 'deeplink',
          );
        },
      ),

      // Contribute routes
      GoRoute(
        path: RouterConstant.contributeTemple,
        builder: (context, state) => const ContributeTempleScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.contributeEvents,
        builder: (context, state) => const ContributeEventScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.contributePujas,
        builder: (context, state) => const ContributePujaScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.contributeFestivals,
        builder: (context, state) => const ContributeFestivalScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.contributeDevs,
        builder: (context, state) => const ContributeDevScreen(),
      ),

      // Drawer routes
      GoRoute(
        path: RouterConstant.drawer,
        builder: (context, state) => const DrawerScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.contact,
        builder: (context, state) => const ContactUsScreen(),
      ),
      
      GoRoute(
        path: RouterConstant.helpCenter,
        builder: (context, state) => const HelpCenter(),
      ),

      // Add/Edit routes
      GoRoute(
        path: '/addTemple/:templeId/:governedById/:calledFrom/:initialIndex',
        builder: (context, state) {
          final templeId = state.pathParameters['templeId'];
          final governedById = state.pathParameters['governedById'];
          final calledFrom = state.pathParameters['calledFrom'];
          final initialIndex = state.pathParameters['initialIndex'];
          return CreateTemple(
            templeId: templeId,
            governingId: governedById,
            calledFrom: calledFrom,
            initialIndex: int.parse(initialIndex ?? '0'),
          );
        },
      ),
      
      GoRoute(
        path: '/addEvent/:eventId/:calledFrom/:initialIndex',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'];
          final calledFrom = state.pathParameters['calledFrom'];
          final initialIndex = state.pathParameters['initialIndex'];
          return AddEventScreen(
            eventId: eventId,
            calledFrom: calledFrom,
            initialIndex: int.parse(initialIndex ?? '0'),
          );
        },
      ),
      
      GoRoute(
        path: '/addDev/:devId/:calledFrom/:initialIndex',
        builder: (context, state) {
          final devId = state.pathParameters['devId'];
          final calledFrom = state.pathParameters['calledFrom'];
          final initialIndex = state.pathParameters['initialIndex'];
          return AddDevScreen(
            devId: devId,
            calledFrom: calledFrom,
            initialIndex: int.parse(initialIndex ?? '0'),
          );
        },
      ),
      
      GoRoute(
        path: '/addPuja/:pujaId/:calledFrom/:initialIndex',
        builder: (context, state) {
          final pujaId = state.pathParameters['pujaId'];
          final calledFrom = state.pathParameters['calledFrom'];
          final initialIndex = state.pathParameters['initialIndex'];
          return AddPujaScreen(
            pujaId: pujaId,
            calledFrom: calledFrom,
            initialIndex: int.parse(initialIndex ?? '0'),
          );
        },
      ),

      GoRoute(
        path: '/addFestival/:festivalId/:calledFrom/:initialIndex',
        builder: (context, state) {
          final festivalId = state.pathParameters['festivalId'];
          final calledFrom = state.pathParameters['calledFrom'];
          final initialIndex = state.pathParameters['initialIndex'];
          return AddFestivalScreen(
            festivalId: festivalId,
            calledFrom: calledFrom,
            initialIndex: int.parse(initialIndex ?? '0'),
          );
        },
      ),

      // View routes
      GoRoute(
        path: '/viewTemple/:templeId/:governedById/:calledFrom',
        builder: (context, state) {
          final templeId = state.pathParameters['templeId'];
          final governedById = state.pathParameters['governedById'];
          final calledFrom = state.pathParameters['calledFrom'];
          return ViewTempleScreen(
            templeId: templeId ?? '',
            governedId: governedById ?? '',
            calledFrom: calledFrom,
          );
        },
      ),
      
      GoRoute(
        path: '/viewEvent/:eventId/:calledFrom',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'];
          final calledFrom = state.pathParameters['calledFrom'];
          return ViewEventScreen(
            eventId: eventId ?? '',
            calledFrom: calledFrom,
          );
        },
      ),
      
      GoRoute(
        path: '/viewDev/:devId/:calledFrom',
        builder: (context, state) {
          final devId = state.pathParameters['devId'];
          final calledFrom = state.pathParameters['calledFrom'];
          return ViewDevScreen(
            devId: devId ?? '',
            calledFrom: calledFrom,
          );
        },
      ),

      GoRoute(
        path: '/viewPuja/:pujaId/:calledFrom',
        builder: (context, state) {
          final pujaId = state.pathParameters['pujaId'];
          final calledFrom = state.pathParameters['calledFrom'];
          return ViewPujaScreen(
            pujaId: pujaId ?? '',
            calledFrom: calledFrom,
          );
        },
      ),
      
      GoRoute(
        path: '/viewFestival/:festivalId/:calledFrom',
        builder: (context, state) {
          final festivalId = state.pathParameters['festivalId'];
          final calledFrom = state.pathParameters['calledFrom'];
          return ViewFestivalScreen(
            festivalId: festivalId ?? '',
            calledFrom: calledFrom,
          );
        },
      ),

      // Search and Profile routes
      GoRoute(
        path: "${RouterConstant.templeSearchScreen}/:type",
        builder: (context, state) {
          final type = state.pathParameters['type'];
          return SearchScreen(type: type);
        },
      ),

      GoRoute(
        path: "/profileMainScreen/:id/:type",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final type = state.pathParameters['type'];
          return ProfileMainScreen(
            id: id != null ? int.tryParse(id) : null,
            profileType: type,
          );
        },
      ),

      GoRoute(
        path: "${RouterConstant.aboutScreen}/:id",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final type = state.uri.queryParameters['type'];
          return AboutScreen(
            id: id != null ? int.tryParse(id) ?? 0 : 0,
            type: type,
          );
        },
      ),

      GoRoute(
        path: "${RouterConstant.mediaDetail}/:id",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return MediaListScroller(id: id ?? "");
        },
      ),
      
      GoRoute(
        path: RouterConstant.notificationScreen,
        builder: (context, state) => const NotificationScreen(),
      ),
      
      GoRoute(
        path: "${RouterConstant.otpPVerificationScreen}/:num",
        builder: (context, state) {
          final phone = state.pathParameters['num'];
          return OTPVerificationScreen(phoneNumber: phone ?? "");
        },
      ),

      // Kriti section
      GoRoute(
        path: RouterConstant.serviceUser,
        builder: (context, state) => const KritiScreen(),
      ),

      GoRoute(
        path: RouterConstant.serviceProvider,
        builder: (context, state) => const ServiceProvider(),
      ),

      GoRoute(
        path: RouterConstant.registrationScreen,
        builder: (context, state) => const RegistrationScreen(),
      ),

      GoRoute(
        path: '/pujaDetailScreen/:pujaName/:serviceId',
        builder: (context, state) {
          return PujaServiceDetailScreen(
            pujaName: state.pathParameters['pujaName'] ?? '',
            serviceId: state.pathParameters['serviceId'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouterConstant.myOrder,
        builder: (context, state) => const MyorderScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;
  
  static void push(String path, {Map<String, String>? params, Object? extra}) {
    String fullPath = path;
    if (params != null && params.isNotEmpty) {
      final queryString =
          params.entries.map((e) => '${e.key}=${e.value}').join('&');
      fullPath += '?$queryString';
    }
    _router.push(fullPath, extra: extra);
  }

  static void go(String path) {
    _router.go(path);
  }

  static bool canPop() {
    return router.canPop();
  }

  static void pop() {
    _router.pop();
  }
}