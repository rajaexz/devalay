import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCacheImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final bool showBorder;
  final Color? color;
  final BoxFit fit;
  final bool showLogo;

  const CustomCacheImage({
    super.key,
    required this.imageUrl,
    this.height = double.infinity,
    this.width = double.infinity,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
    this.border,
    this.color,
    this.showLogo = false,
    this.fit = BoxFit.fill,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if the URL ends with .svg
    if (imageUrl!.toLowerCase().endsWith('.svg')) {
      return _buildSvgImage();
    }

    return _buildCachedImage();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(showLogo ? 4 : 0),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(100),
        border: showBorder
            ? Border.all(
                color: Colors.black,
                width: 0.4,
              )
            : null,
      ),
      child: const ClipOval(
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSvgImage() {
    return SvgPicture.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      key: UniqueKey(),
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: showBorder ? border : null,
          color: color ?? Colors.grey[100],
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          border: showBorder ? border : null,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          color: color ?? Colors.grey[100],
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 0.2, color: Colors.black),
        ),
      ),
      errorWidget: (context, url, error) {
        return _buildPlaceholder();
      },
    );
  }
}
