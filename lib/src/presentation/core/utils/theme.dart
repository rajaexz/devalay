import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class AppTheme {
  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// Light style
  static final ThemeData light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    highlightColor: const Color(0xffFFFDFF),
    scaffoldBackgroundColor: AppColor.whiteColor,
    appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.lightScaffoldColor,
        foregroundColor: AppColor.whiteColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColor.orangeColor,
      unselectedItemColor: Color(0xff757575),
      backgroundColor: AppColor.lightScaffoldColor,
    ),
    disabledColor: const Color(0xffE0E0E0),
    primaryColor: accentColor,
    iconTheme: const IconThemeData(color: Color(0xff757575)),
    pageTransitionsTheme: _pageTransitionsTheme,
    fontFamily: 'SF Pro',
    textTheme: const TextTheme(
      //For Appbar
      headlineLarge: TextStyle(
        letterSpacing: 0,
        height: 1.2,
        fontSize: 40.0,
        fontWeight: FontWeight.normal,
        color: AppColor.orangeColor,
      ),

      //For dashboard name
      headlineMedium: TextStyle(
        height: 1.2,
        fontSize: 24.0,
        letterSpacing: 0,
        fontWeight: FontWeight.normal,
        color: AppColor.orangeColor,
      ),

      //Widgets title
      headlineSmall: TextStyle(
        height: 1.4,
        fontSize: 20.0,
        letterSpacing: 1,
        fontWeight: FontWeight.w500,
        color: AppColor.orangeColor,
      ),

      //bottomsheet title
      bodyLarge: TextStyle(
          height: 1.4,
          fontSize: 18.0,
          letterSpacing: 1,
          fontWeight: FontWeight.w400,
          color: Color(0xff616161)),

      //Textfield label
      bodyMedium: TextStyle(
          height: 1.4,
          fontSize: 16.0,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
          color: AppColor.lightTextColor),

      //Fab actions title
      bodySmall: TextStyle(
          height: 1.4,
          fontSize: 14.0,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
          color: Color(0xff212121)),
      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),

      labelLarge: TextStyle(
          height: 1.4,
          fontSize: 12.0,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          color: AppColor.orangeColor),

      labelSmall: TextStyle(
          fontSize: 14,
          height: 1.8,
          letterSpacing: 0.3,
          fontWeight: FontWeight.normal,
          color: AppColor.subTitleTextColor),

      // Add more text styles as needed
    ),
    // textTheme: GoogleFonts.latoTextTheme((ThemeData.light().textTheme)),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    colorScheme: const ColorScheme.light()
        .copyWith(
            primary: accentColor,
            secondary: accentColor,
            onSecondary: Colors.white,
            error: const Color(0xffCA1D08))
        .copyWith(secondary: accentColor),
    dividerColor: const Color(0xffE0E0E0),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              color: Color(0xff4368FF),
              fontSize: 14.0),
        ),
      ),
    ),
  );

  /// Dark style
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff202125),
    highlightColor: const Color(0xff424242),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff2A2B2F),
        foregroundColor: Color(0xff2A2B2F),
        systemOverlayStyle: SystemUiOverlayStyle.light),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColor.appbarBgColor,
        unselectedItemColor: Color(0xffE0E0E0),
        backgroundColor: Color(0xff202125)),
    disabledColor: const Color(0xff343539),
    pageTransitionsTheme: _pageTransitionsTheme,
    fontFamily: 'SF Pro',
    iconTheme: const IconThemeData(color: Color(0xffE0E0E0)),
    textTheme: const TextTheme(
      //For Appbar
      headlineLarge: TextStyle(
        letterSpacing: 0,
        height: 1.2,
        fontSize: 40.0,
        fontWeight: FontWeight.normal,
        color: AppColor.whiteColor,
      ),

      //For dashboard name
      headlineMedium: TextStyle(
        height: 1.2,
        fontSize: 24.0,
        letterSpacing: 0,
        fontWeight: FontWeight.normal,
        color: AppColor.whiteColor,
      ),

      //Widgets title
      headlineSmall: TextStyle(
        height: 1.4,
        fontSize: 20.0,
        letterSpacing: 1,
        fontWeight: FontWeight.w500,
        color: AppColor.whiteColor,
      ),

      //bottomsheet title
      bodyLarge: TextStyle(
        height: 1.4,
        fontSize: 18.0,
        letterSpacing: 1,
        fontWeight: FontWeight.w400,
        color: AppColor.whiteColor,
      ),

      //Textfield label
      bodyMedium: TextStyle(
          height: 1.4,
          fontSize: 16.0,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
          color: AppColor.whiteColor),

      //Fab actions title
      bodySmall: TextStyle(
        height: 1.4,
        fontSize: 14.0,
        letterSpacing: 0,
        fontWeight: FontWeight.normal,
        color: AppColor.whiteColor,
      ),

      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),

      labelLarge: TextStyle(
        height: 1.4,
        fontSize: 12.0,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: AppColor.whiteColor,
      ),

      labelSmall: TextStyle(
        fontSize: 14,
        height: 1.8,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
        color: AppColor.whiteColor,
      ),

      // Add more text styles as needed
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColor.orangeColor,
      secondary: AppColor.orangeColor,
      background: const Color(0xff202125),
      surface: const Color(0xff2A2B2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: const Color(0xffCA1D08),
    ),
  );
}
