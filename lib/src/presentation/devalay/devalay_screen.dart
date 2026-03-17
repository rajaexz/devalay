import 'package:devalay_app/src/application/feed/notification/notification_cubit.dart';
import 'package:devalay_app/src/application/language/language_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/feed_appBar.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevalayScreen extends StatelessWidget {
  const DevalayScreen({super.key});


  @override
  Widget build(BuildContext context) {
  NotificationCubit   notificationCubit = context.read<NotificationCubit>();
     notificationCubit.connectToSocketWithSession();
    return BlocConsumer<LanguageCubit, Locale>(
     listener: (context,locale)=>debugPrint('Language changed to: $locale'),
     
      builder: (context, state) {
        return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: CustomAppBar(brandName: StringConstant.appName),
            ),
            body: const FeedScreen());
      },
    );
  }
}
