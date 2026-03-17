// ignore_for_file: use_build_context_synchronously

import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract mixin class BlurDialog {}

class BlurredDialogBox extends StatelessWidget implements BlurDialog {
  final String? cancelButtonName;
  final bool? divider;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String? title;
  final Widget content;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancelButton;
  final bool? barrierDismissible;
  final bool? isAcceptContainerPush;
  final bool? useDarkMode;

  const BlurredDialogBox({
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.title,
    required this.content,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancelButton,
    this.svgImagePath,
    this.svgImageColor,
    this.barrierDismissible,
    this.isAcceptContainerPush,
    this.divider,
    this.useDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isBack = true;
    final bool isDarkMode = useDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    
    // Dark mode color configurations
    final backgroundColor = isDarkMode 
        ? AppColor.blackColor 
        : AppColor.whiteColor;
    
    final defaultTextColor = isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;
    
    final defaultCancelButtonColor = isDarkMode
        ? AppColor.blackColor
        : AppColor.lightScaffoldColor;
    
    final defaultAcceptButtonColor = isDarkMode
        ? AppColor.appbarBgColor 
        : AppColor.gradientDarkColor;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.black.withOpacity(0.0)),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (barrierDismissible ?? false) {
                Navigator.pop(context);
              }
            },
            child: Container(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.5)  // Darker overlay for dark mode
                  : Colors.black.withOpacity(0.14),
            ),
          ),
          PopScope(
            canPop: isBack,
            onPopInvoked: (didPop) {
              if (backAllowedButton == false) {
                isBack = false;
                return;
              }
              isBack = true;
              return;
            },
            child: LayoutBuilder(builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent, // Prevent color tinting in Material 3
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 186 / 2,
                        backgroundColor: isDarkMode
                            ? AppColor.whiteColor.withOpacity(0.1)
                            : AppColor.blackColor.withOpacity(0.1),
                        child: SizedBox(
                            width: 87 / 2,
                            height: 87 / 2,
                            child: SvgPicture.asset(
                              svgImagePath!,
                              color: svgImageColor ?? (isDarkMode ? Colors.white : null),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    title != null
                        ? Text(
                            title!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: defaultTextColor,
                            ),
                          )
                        : const SizedBox.shrink(),
                    if (divider == true) 
                      Divider(
                        color: isDarkMode 
                          ? Colors.white.withOpacity(0.2) 
                          : Colors.black.withOpacity(0.2),
                      ),
                  ],
                ),
                content: content,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancelButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor: cancelButtonColor ?? defaultCancelButtonColor,
                      buttonName: cancelButtonName ?? "Cancel",
                      textColor: cancelTextColor ?? (isDarkMode ? Colors.white : AppColor.blackColor),
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  Builder(builder: (context) {
                    if (showCancelButton == false) {
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: button(
                            context,
                            constraints: constraints,
                            buttonColor: acceptButtonColor ?? defaultAcceptButtonColor,
                            buttonName: acceptButtonName ?? "OK",
                            textColor: acceptTextColor ?? (isDarkMode ? Colors.white : AppColor.blackColor),
                            onTap: () async {
                              await onAccept?.call();

                              if (isAcceptContainerPush == false ||
                                  isAcceptContainerPush == null) {
                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      );
                    }
                    return button(
                      context,
                      constraints: constraints,
                      buttonColor: acceptButtonColor ?? defaultAcceptButtonColor,
                      buttonName: acceptButtonName ?? "OK",
                      textColor: acceptTextColor ?? Colors.white,
                      onTap: () async {
                        await onAccept?.call();
                        if (isAcceptContainerPush == false ||
                            isAcceptContainerPush == null) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              Navigator.pop(context, true);
                            },
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  Widget button(BuildContext context,
      {required BoxConstraints constraints,
      required Color buttonColor,
      required String buttonName,
      required Color textColor,
      required VoidCallback onTap,
      required bool isDarkMode}) {
    return SizedBox(
      width: (constraints.maxWidth / 3),
      child: MaterialButton(
          elevation: 0,
          height: 39,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : AppColor.appbarBgColor,
              )),
          color: buttonColor,
          onPressed: onTap,
          child: Text(
            buttonName,
            style: TextStyle(color: textColor),
          )),
    );
  }
}

class BlurredDialogBuilderBox extends StatelessWidget implements BlurDialog {
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget? Function(BuildContext context, BoxConstraints constrains)
      contentBuilder;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancelButton;
  final bool? isAcceptContainsPush;
  final bool? useDarkMode;

  const BlurredDialogBuilderBox({
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    required this.title,
    required this.contentBuilder,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancelButton,
    this.svgImagePath,
    this.svgImageColor,
    this.isAcceptContainsPush,
    this.useDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isBack = true;
    final bool isDarkMode = useDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    
    // Dark mode color configurations
    final backgroundColor = isDarkMode 
        ? AppColor.blackColor
        : makeColorDark(AppColor.appbarBgColor);
    
    final defaultTextColor = isDarkMode
        ? AppColor.whiteColor 
        : AppColor.blackColor;
    
    final defaultCancelButtonColor = isDarkMode
        ? AppColor.blackColor 
        : AppColor.whiteColor.withOpacity(0.10);
    
    final defaultAcceptButtonColor = isDarkMode
        ? AppColor.appbarBgColor 
        : AppColor.blackColor;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.black.withOpacity(0.0)),
      child: Stack(
        children: [
          Container(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.5)  // Darker overlay for dark mode
                : Colors.black.withOpacity(0.14),
          ),
          PopScope(
            canPop: isBack,
            onPopInvoked: (didPop) async {
              if (backAllowedButton == false) {
                isBack = false;
                return;
              }
              isBack = true;
              return;
            },
            child: LayoutBuilder(builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent, // Prevent color tinting in Material 3
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 98 / 2,
                        backgroundColor: isDarkMode
                            ? AppColor.whiteColor.withOpacity(0.1)
                            : AppColor.blackColor.withOpacity(0.1),
                        child: SizedBox(
                            width: 87 / 2,
                            height: 87 / 2,
                            child: SvgPicture.asset(
                              svgImagePath!,
                              color: svgImageColor ?? (isDarkMode ? Colors.white : null),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    Text(
                      title, 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: defaultTextColor,
                      ),
                    ),
                  ],
                ),
                content: contentBuilder.call(context, constraints),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancelButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor: cancelButtonColor ?? defaultCancelButtonColor,
                      buttonName: cancelButtonName ?? "Cancel",
                      textColor: cancelTextColor ?? (isDarkMode ? Colors.white : AppColor.blackColor),
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  Builder(builder: (context) {
                    if (showCancelButton == false) {
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: button(
                            context,
                            constraints: constraints,
                            buttonColor: acceptButtonColor ?? defaultAcceptButtonColor,
                            buttonName: acceptButtonName ?? "OK",
                            textColor: acceptTextColor ?? (isDarkMode ? Colors.white : AppColor.blackColor),
                            onTap: () async {
                              await onAccept?.call();

                              if (isAcceptContainsPush == false ||
                                  isAcceptContainsPush == null) {
                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      );
                    }
                    return button(
                      context,
                      constraints: constraints,
                      buttonColor: acceptButtonColor ?? defaultAcceptButtonColor,
                      buttonName: acceptButtonName ?? "OK",
                      textColor: acceptTextColor ?? Colors.white,
                      onTap: () async {
                        await onAccept?.call();
                        if (isAcceptContainsPush == false ||
                            isAcceptContainsPush == null) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              Navigator.pop(context, true);
                            },
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  Widget button(BuildContext context,
      {required BoxConstraints constraints,
      required Color buttonColor,
      required String buttonName,
      required Color textColor,
      required VoidCallback onTap,
      required bool isDarkMode}) {
    return SizedBox(
      width: (constraints.maxWidth / 3),
      child: MaterialButton(
        elevation: 0,
        height: 39,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isDarkMode 
              ? BorderSide(color: Colors.white.withOpacity(0.1))
              : BorderSide.none,
        ),
        color: buttonColor,
        onPressed: onTap,
        child: Text(
          buttonName,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}

class EmptyDialogBox extends StatelessWidget with BlurDialog {
  final Widget child;
  final bool? barrierDismissible;
  final bool? useDarkMode;

  const EmptyDialogBox({
    super.key, 
    required this.child, 
    this.barrierDismissible,
    this.useDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = useDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
        child: Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (barrierDismissible ?? true) Navigator.pop(context);
          },
          child: Container(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.5)  // Darker overlay for dark mode
                : Colors.black.withOpacity(0.3),
          ),
        ),
        Center(child: child),
      ],
    ));
  }
}