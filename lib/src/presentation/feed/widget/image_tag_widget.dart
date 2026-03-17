import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';

class ImageTag {
  final String type; // 'temple' or 'person'
  final Result result;
  Offset position;

  ImageTag({
    required this.type,
    required this.result,
    required this.position,
  });

  String get name => type == 'temple' ? result.title ?? '' : result.name ?? '';
  int get id => result.id ?? 0;
}

class ImageTagWidget extends StatefulWidget {
  final String imagePath;
  final List<ImageTag> tags;
  final Function(ImageTag tag) onRemoveTag;
  final Function(ImageTag tag, Offset newPosition) onTagMoved;

  const ImageTagWidget({
    super.key,
    required this.imagePath,
    required this.tags,
    required this.onRemoveTag,
    required this.onTagMoved,
  });

  @override
  State<ImageTagWidget> createState() => _ImageTagWidgetState();
}

class _ImageTagWidgetState extends State<ImageTagWidget> {
  ImageTag? _draggedTag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        ...widget.tags.map((tag) => Positioned(
              left: tag.position.dx,
              top: tag.position.dy,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _draggedTag = tag;
                  });
                },
                onPanUpdate: (details) {
                  if (_draggedTag == tag) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final Offset localPosition = box.globalToLocal(details.globalPosition);
                    widget.onTagMoved(tag, localPosition);
                  }
                },
                onPanEnd: (details) {
                  setState(() {
                    _draggedTag = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tag.type == 'temple' ? Icons.church : Icons.person,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        tag.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => widget.onRemoveTag(tag),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),

            
      ],
    );
  }
} 