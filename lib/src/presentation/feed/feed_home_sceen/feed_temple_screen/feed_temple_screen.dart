
import 'dart:io';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/presentation/feed/widget/image_tag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FeedTempleScreen extends StatefulWidget {
  final List<XFile> selectedImages;
  final List<Result> selectedTemples;
  const FeedTempleScreen({super.key, required this.selectedImages, required this.selectedTemples});

  @override
  State<FeedTempleScreen> createState() => _FeedTempleScreenState();
}

class _FeedTempleScreenState extends State<FeedTempleScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();



  String? deltaJson;
  String? html;
  late FeedHomeCubit _feedHomeCubit;
  final Map<String, List<ImageTag>> _imageTags = {};
  final Map<String, String> _videoThumbnails = {};
  final Map<String, int> _videoDurations = {};

  bool _isVideo(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'wmv'].contains(extension);
  }

  @override
  void initState() {
    super.initState();
    _feedHomeCubit = context.read<FeedHomeCubit>();
    // Initialize tags for each image
    for (var image in widget.selectedImages) {
      _imageTags[image.path] = [];
      if (_isVideo(image.path)) {
        _loadVideoThumbnail(image.path);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _initializeQuillController();
    });
  }

  void _initializeQuillController() {
  
    _feedHomeCubit.commentController.addListener(_feedHomeCubit.updateCharCount);
  }

  Future<void> _loadVideoThumbnail(String videoPath) async {
    try {
      // Generate thumbnail
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await Directory.systemTemp.createTemp()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        quality: 75,
      );

      // Get video duration

      if (thumbnail != null) {
        setState(() {
          _videoThumbnails[videoPath] = thumbnail;
        });
      }
    } catch (e) {
      print('Error loading video thumbnail: $e');
    }
  }

  String _formatDuration(int milliseconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits((milliseconds ~/ 60000).remainder(60));
    final seconds = twoDigits((milliseconds ~/ 1000).remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _feedHomeCubit.commentController.removeListener(_feedHomeCubit.updateCharCount);

  
    super.dispose();
  }




  void updateCommentContent(String delta, String htmlContent) {
    setState(() {
      deltaJson = delta;
      html = htmlContent;
    });
  }
 void _removeTag(String imagePath, ImageTag tag) {
    setState(() {
      _imageTags[imagePath]?.remove(tag);
      widget.selectedTemples.remove(tag.result);
    });
  }

  void _handleTagMoved(String imagePath, ImageTag tag, Offset newPosition) {
    setState(() {
      tag.position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedHomeCubit, FeedHomeState>(
      builder: (context, state) {
        return 
        Scaffold(
          appBar: AppBar(
            leadingWidth: 30.w,
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            title: Text("New post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
           
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media slider
                    SizedBox(
                      height: 300.h,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: widget.selectedImages.length,
                        onPageChanged: (index) {
                          setState(() {
                          });
                        },
                        itemBuilder: (context, index) {
                          final media = widget.selectedImages[index];
                          if (_isVideo(media.path)) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Video thumbnail
                                if (_videoThumbnails[media.path] != null)
                                  Image.file(
                                    File(_videoThumbnails[media.path]!),
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                // Play button overlay
                                Center(
                                  child: Container(
                                    width: 50.w,
                                    height: 50.w,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30.sp,
                                    ),
                                  ),
                                ),
                                // Video duration
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.play_arrow, color: Colors.white, size: 16.sp),
                                        if (_videoDurations[media.path] != null)
                                          Text(
                                            _formatDuration(_videoDurations[media.path]!),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Tags for video
                                if (_imageTags[media.path]?.isNotEmpty ?? false)
                                  ..._imageTags[media.path]!.map((tag) => Positioned(
                                    left: tag.position.dx * MediaQuery.of(context).size.width,
                                    top: tag.position.dy * 300.h,
                                    child: GestureDetector(
                                      onTap: () => _removeTag(media.path, tag),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(4),
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
                                            Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                              ],
                            );
                          } else {
                            return ImageTagWidget(
                              imagePath: media.path,
                              tags: _imageTags[media.path] ?? [],
                              onRemoveTag: (tag) => _removeTag(media.path, tag),
                              onTagMoved: (tag, newPosition) => _handleTagMoved(media.path, tag, newPosition),
                            );
                          }
                        },
                      ),
                    ),
                            SizedBox(height: 16.h),
                                if (widget.selectedTemples.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: widget.selectedTemples.length,
                                    itemBuilder: (context, index) {
                                      final temple = widget.selectedTemples[index];
                                      return ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: temple.image != null
                                              ? Image.network(
                                                  temple.image!,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        color: Colors.grey[200],
                                                        child: const Icon(Icons.church),
                                                      ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.church),
                                                ),
                                        ),
                                        title: Text(
                                          temple.title ?? temple.name ?? 'Unnamed Temple',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                       
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              widget.selectedTemples.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
