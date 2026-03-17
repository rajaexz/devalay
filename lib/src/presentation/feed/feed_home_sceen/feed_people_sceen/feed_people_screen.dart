import 'dart:io';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/presentation/feed/widget/image_tag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../presentation/widgets/custom_cache_image.dart';

class FeedPeopleScreen extends StatefulWidget {
  final List<XFile> selectedImages;
  final List<Result> selectedPeople;

  const FeedPeopleScreen({
    super.key,
    required this.selectedImages,
    required this.selectedPeople,
  });

  @override
  State<FeedPeopleScreen> createState() => _FeedPeopleScreenState();
}

class _FeedPeopleScreenState extends State<FeedPeopleScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  String? deltaJson;
  String? html;
  final Map<String, List<ImageTag>> _imageTags = {};
  final Map<String, String> _videoThumbnails = {};

  bool _isVideo(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'wmv'].contains(extension);
  }

  @override
  void initState() {
    super.initState();
    print('Initializing FeedPeopleScreen with ${selectedImages.length} images');
    // Initialize tags for each image
    for (var image in selectedImages) {
      print('Processing image: ${image.path}');
      _imageTags[image.path] = [];
      if (_isVideo(image.path)) {
        _loadVideoThumbnail(image.path);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
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

      if (thumbnail != null) {
        setState(() {
          _videoThumbnails[videoPath] = thumbnail;
        });
      } else {
        print('Failed to generate thumbnail for: $videoPath');
      }
    } catch (e) {
      print('Error loading video thumbnail: $e');
    }
  }


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _removeTag(String imagePath, ImageTag tag) {
    setState(() {
      _imageTags[imagePath]?.remove(tag);
      selectedPeople.remove(tag.result);
    });
  }

  void _handleTagMoved(String imagePath, ImageTag tag, Offset newPosition) {
    setState(() {
      tag.position = newPosition;
    });
  }

  List<XFile> get selectedImages => widget.selectedImages;
  List<Result> get selectedPeople => widget.selectedPeople;

  @override
  Widget build(BuildContext context) {
    print('Building FeedPeopleScreen with ${selectedImages.length} images');
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30.w,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        
        title: Text(
          "Tag People",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
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
                Container(
                  height: 300.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: selectedImages.isEmpty
                      ? Center(
                          child: Text(
                            'No images selected',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : PageView.builder(
                          itemCount: selectedImages.length,
                          onPageChanged: (index) {
                            print('Page changed to index: $index');
                            setState(() {
                            });
                          },
                          itemBuilder: (context, index) {
                            final media = selectedImages[index];
                            print('Building page for image: ${media.path}');
                            if (_isVideo(media.path)) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
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
                                                Icons.person,
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
                if (selectedPeople.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedPeople.length,
                    itemBuilder: (context, index) {
                      final person = selectedPeople[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomCacheImage(
                            imageUrl: person.dp ?? '',
                            width: 40,
                            showLogo: true,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          person.name ?? 'Unnamed User',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        subtitle: person.email != null
                            ? Text(
                                person.email!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              selectedPeople.removeAt(index);
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
  }
} 