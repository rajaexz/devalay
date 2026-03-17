import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';

// Dialog function jo guest user ko login ke liye prompt karega
Future<bool?> showGuestLoginDialog(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // User ko back press se close nahi hone dega
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : AppColor.whiteColor,
        title: Row(
       mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline, 
              color: AppColor.orangeColor, 
              size: 28
            ),
            const SizedBox(width: 10),
            Center(
              child: Text(
              'Login Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                letterSpacing: 0,
              ),
            ),
            )
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need to login to access this feature.',
              style: theme.textTheme.bodyMedium,
            ),
          
           
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: Text(
              'Skip',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColor.greyColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Login
              AppRouter.go(RouterConstant.loginScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.orangeColor,
              foregroundColor: AppColor.whiteColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Login',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColor.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Helper function jo check karega aur dialog show karega
Future<bool> checkAndPromptLogin(BuildContext context) async {
  bool isGuest =  await PrefManager.getIsGuest() ;
  if (isGuest) {
    await showGuestLoginDialog(context);
    return false; // Guest user hai, action perform nahi hoga
  }
  
  return true; // User logged in hai, action proceed kar sakta hai
}

//import 'package:flutter/material.dart';

class GuestPopScreen extends StatelessWidget {
 

  const GuestPopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Protected Feature'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 20),
              Text(
                'You need to log in to access this feature.'
                  ,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
     
                Text(
                  'Would you like to log in now?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () async {
                  // Use AppRouter.go directly since this is a full screen, not a dialog
                  AppRouter.go(RouterConstant.loginScreen);
                },
                icon: const Icon(Icons.login),
                label: const Text('Login Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
