import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLottieLoader extends StatelessWidget {
  final String? lottieAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool? animate;
  final String? message;

  const CustomLottieLoader({
    super.key,
    this.lottieAsset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Default animation if none provided
    final String animationPath = lottieAsset ?? 'assets/icon/loader_animation.json';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animationPath,
            width: width ?? 88.w,
            height: height ?? 88.h,
            fit: fit,
            animate: animate ?? true,
            repeat: repeat,
          ),
          if (message != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// Usage example for loader in your filter widget:
// Replace your current CustomLottieLoader with this:

/*
return const CustomLottieLoader(
  lottieAsset: 'assets/animations/temple_loader.json',
  message: 'Loading temple data...',
);
*/

// To use as full screen loader:

class CustomLottieFullScreenLoader extends StatelessWidget {
  final String? lottieAsset;
  final String? message;
  final Color? backgroundColor;

  const CustomLottieFullScreenLoader({
    super.key,
    this.lottieAsset,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white.withOpacity(0.7),
      child: CustomLottieLoader(
        lottieAsset: lottieAsset,
        message: message,
      ),
    );
  }
}

// Overlay implementation for loader that can be shown on top of any screen

class LottieLoaderOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    String? lottieAsset,
    String? message,
    Color? backgroundColor,
  }) {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => CustomLottieFullScreenLoader(
        lottieAsset: lottieAsset,
        message: message,
        backgroundColor: backgroundColor,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}



//post Card


class LoadingPostCard extends StatelessWidget {
  const LoadingPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile Image Placeholder
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // User Info Placeholder
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Follow Button Placeholder
                    Container(
                      height: 24,
                      width: 70,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // More Options Placeholder
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Post Content Placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 220,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Media Content Placeholder
          Container(
            height: 200,
            color: baseColor,
          ),

          // Post Actions Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      height: 16,
                      width: 30,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                // Comment
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      height: 16,
                      width: 30,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                // Share
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingPostList extends StatelessWidget {
  final int itemCount;
  
  const LoadingPostList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const LoadingPostCard(),
    );
  }
}