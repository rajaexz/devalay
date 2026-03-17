import 'dart:io';
import 'dart:convert';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/show_blurred_dialoge.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/blurred_dialoge_box.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_people_sceen/feed_people_screen.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_temple_screen/feed_temple_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devalay_app/src/presentation/feed/widget/comment_Input_widget.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:devalay_app/src/presentation/feed/widget/image_tag_widget.dart';
import 'dart:async';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/people/person_search_sheet.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/temple/temple_search_sheet.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/location/location_search_sheet.dart';

class SelectedGallery extends StatefulWidget {
  final List<XFile> selectedImages;
  const SelectedGallery({super.key, required this.selectedImages});

  @override
  State<SelectedGallery> createState() => _SelectedGalleryState();
}

class _SelectedGalleryState extends State<SelectedGallery> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  String? _selectedLocation;
  final List<Result> _selectedTemples = [];

                 
  final List<Result> _selectedPeople = [];
  final GobelSearchCubit _templeSearchCubit = GobelSearchCubit();
  final GobelSearchCubit _userSearchCubit = GobelSearchCubit();
  String? deltaJson;
  String? html;
  late FeedHomeCubit _feedHomeCubit;
  final Map<String, List<ImageTag>> _imageTags = {};
  int _currentImageIndex = 0;
  final List<Offset> _tagPositions = [
    const Offset(0.2, 0.2),
    const Offset(0.8, 0.2),
    const Offset(0.5, 0.5),
    const Offset(0.2, 0.8),
    const Offset(0.8, 0.8),
  ];
  final Map<String, String> _videoThumbnails = {};
  final Map<String, int> _videoDurations = {};
  bool _isPosting = false;

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
    _feedHomeCubit.commentController = QuillController.basic();
    _feedHomeCubit.commentController.addListener(() {
      _feedHomeCubit.updateCharCount();
      _updateContent();
    });
  }

  void _updateContent() {
    try {
      final delta = _feedHomeCubit.commentController.document.toDelta();
      final Map<String, dynamic> deltaMap = {"ops": delta.toJson()};
      final deltaJson = jsonEncode(deltaMap);
      final html = convertToHtml(_feedHomeCubit.commentController.document);

      setState(() {
        this.deltaJson = deltaJson;
        this.html = html;
      });
    } catch (e) {
      print("Error updating content: $e");
    }
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
    _feedHomeCubit.commentController.removeListener(() {
      _feedHomeCubit.updateCharCount();
      _updateContent();
    });
    _templeSearchCubit.close();
    _userSearchCubit.close();
    super.dispose();
  }

  Future<void> _showLocationSearch() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
      
       SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
        
            children: [
              SizedBox(height: 50.h),
               Flexible(
                child: LocationSearchSheet(onLoactionSelected:(l)=>{
              
                  setState(() {
                    _selectedLocation = l;
                  })
              
              
                },selectedLocation: _selectedLocation ?? "",),
              ),
            ],
          ),
        ),

      ),
    );
  
    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _showTempleSearch() async {
    final currentImage = widget.selectedImages[_currentImageIndex];
    final currentTags = _imageTags[currentImage.path] ?? [];
    final availablePositions = _tagPositions.where((position) {
      return !currentTags.any((tag) =>
          tag.position.dx == position.dx && tag.position.dy == position.dy);
    }).toList();

    if (availablePositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringConstant.maximumTagsReached)),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 4,
              ),
              Flexible(
                child: TempleSearchSheet(
                  selectedTemples: _selectedTemples,
                  onTemplesSelected: (temples) {
                    setState(() {
                      for (var temple in temples) {
                        if (!_selectedTemples.any((t) => t.id == temple.id)) {
                          _selectedTemples.add(temple);
                          if (availablePositions.isNotEmpty) {
                            _imageTags[currentImage.path]?.add(ImageTag(
                              type: 'temple',
                              result: temple,
                              position: availablePositions.removeAt(0),
                            ));
                          }
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPersonSearch() async {
    final currentImage = widget.selectedImages[_currentImageIndex];
    final currentTags = _imageTags[currentImage.path] ?? [];
    final availablePositions = _tagPositions.where((position) {
      return !currentTags.any((tag) =>
          tag.position.dx == position.dx && tag.position.dy == position.dy);
    }).toList();

    if (availablePositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringConstant.maximumTagsReached)),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 50.h),
              Flexible(
                child: PersonSearchSheet(
                  selectedPeople: _selectedPeople,
                  onPeopleSelected: (people) {
                    if (people.isNotEmpty) {
                      setState(() {
                        for (var person in people) {
                          if (!_selectedPeople.any((p) => p.id == person.id)) {
                            _selectedPeople.add(person);
                            if (availablePositions.isNotEmpty) {
                              _imageTags[currentImage.path]!.add(
                                ImageTag(
                                  type: 'person',
                                  result: person,
                                  position: availablePositions.removeAt(0),
                                ),
                              );
                            }
                          }
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateCommentContent(String delta, String htmlContent) {
    setState(() {
      deltaJson = delta;
      html = htmlContent;
    });
  }

  void _sharePost() async {
     if(   _isPosting ){
      return;
     }
      
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isPosting = true);

    // Build post content and append tagged people so they show in caption
    String contentHtml = html ?? '';
    if (_selectedPeople.isNotEmpty) {
      final peopleLinks = _selectedPeople
          .map((p) =>
              '<a href="/user/${p.id}">${_escapeHtml(p.name ?? p.title ?? '')}</a>')
          .join(', ');
      contentHtml = contentHtml.trim().isEmpty
          ? '<p>With $peopleLinks</p>'
          : '$contentHtml<p>With $peopleLinks</p>';
    }
    final purposeOutput = {
      'delta': deltaJson,
      'html': contentHtml,
    };

    final List<XFile> imagesForTagging =
        widget.selectedImages.where((file) => !_isVideo(file.path)).toList();

    if ((imagesForTagging.isNotEmpty || _videoThumbnails.isNotEmpty) &&
        _feedHomeCubit.commentController.document
            .toPlainText()
            .trim()
            .isNotEmpty) {
      try {
        await _feedHomeCubit.feedCreatePost(
        file:  widget.selectedImages,
        title:  jsonEncode(purposeOutput),
        people:  _selectedPeople.map((person) => person.toJson()).toList(),
        location:    _selectedLocation ?? "",
        temples:  _selectedTemples.map((temple) => temple.toJson()).toList(),
        context: context
        );
        // Optionally: pop or show success
      } catch (e) {
        // Optionally: show error
      }
    } else {
      showBlurredDialoge(context,
          dialoge: BlurredDialogBox(
            showCancelButton: false,
            title: StringConstant.pleaseAddContentToPost,
            onAccept: () async {},
            cancelButtonName: StringConstant.ok,
            content: Text(StringConstant.pleaseAddContentToPost),
          ));
    }

    setState(() => _isPosting = false);
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  void _removeTag(String imagePath, ImageTag tag) {
    setState(() {
      _imageTags[imagePath]?.remove(tag);
      if (tag.type == 'temple') {
        _selectedTemples.remove(tag.result);
      } else {
        _selectedPeople.remove(tag.result);
      }
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
        return Scaffold(
  appBar: AppBar(

    automaticallyImplyLeading: false, // Disable default leading padding
    title: Row(
      children: [
        InkWell(
          child: const Icon(Icons.close),
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12), // 👈 Exactly 12 pixels of spacing
        Text(
          StringConstant.newPost,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ],
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
                    SizedBox(
                      height: 300.h,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: widget.selectedImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
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
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          '${index + 1}/${widget.selectedImages.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Tags for video
                                if (_imageTags[media.path]?.isNotEmpty ?? false)
                                  ..._imageTags[media.path]!.map((tag) =>
                                      Positioned(
                                        left: tag.position.dx *
                                            MediaQuery.of(context).size.width,
                                        top: tag.position.dy * 300.h,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeTag(media.path, tag),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  tag.type == 'temple'
                                                      ? Icons.church
                                                      : Icons.person,
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
                            return Stack(
                              children: [
                                ImageTagWidget(
                                  imagePath: media.path,
                                  tags: _imageTags[media.path] ?? [],
                                  onRemoveTag: (tag) =>
                                      _removeTag(media.path, tag),
                                  onTagMoved: (tag, newPosition) =>
                                      _handleTagMoved(
                                          media.path, tag, newPosition),
                                ),
                                // if( index == 1)
                                // Positioned(
                                //   top: 10,
                                //   right: 10,
                                //   child: Container(
                                //     padding:
                                //         const EdgeInsets.symmetric(vertical: 8),
                                //     child: Center(
                                //       child: Container(
                                //         padding: const EdgeInsets.symmetric(
                                //             horizontal: 12, vertical: 6),
                                //         decoration: BoxDecoration(
                                //           color: Colors.black.withOpacity(0.3),
                                //           borderRadius:
                                //               BorderRadius.circular(15),
                                //         ),
                                //         child: Text(
                                //           '${index + 1}/${widget.selectedImages.length}',
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .bodySmall!
                                //               .copyWith(
                                //                 color: Colors.white,
                                //                 fontSize: 12,
                                //               ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
       if(widget.selectedImages.length > 1)
  Positioned(
    top: 10,
    right: 10,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${index + 1}/${widget.selectedImages.length}',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    ),
  ),                       ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Quill Editor
                    CommentInputWidget(
                      onContentChanged: updateCommentContent,
                    ),

                    const Divider(),
                    // Add location

                    InkWell(
                        onTap: () {
                          _showLocationSearch();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/icon/loactaion.svg", width: 15,height: 15,),
                                  // Icon(Icons.location_on_outlined, size: 24.sp),
                                  SizedBox(width: 20.w),
                                  SizedBox(
                                    width: 200.h,
                                    child: Text(
                                      _selectedLocation ?? StringConstant.addLocationLabel,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight:
                                                _selectedLocation != null
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    Icon(Icons.chevron_right, size: 24.sp),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),

                    // Tag temple

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                           
                               _showTempleSearch();
                            },
                            child: Row(
                              children: [
                                  SvgPicture.asset("assets/icon/Group 7050.svg", width: 15,height: 15,),
                                // Icon(Icons.add_box_outlined, size: 24.sp),
                                SizedBox(width: 20.w),
                                Text(StringConstant.tagTemples,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          SizedBox(
                              child: InkWell(
                            onTap: () {
                                if (_selectedTemples.isNotEmpty)
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FeedTempleScreen(
                                          selectedImages: widget.selectedImages,
                                          selectedTemples: _selectedTemples)));
                            },
                            child: Row(
                              children: [
                                if (_selectedTemples.isNotEmpty)
                                  Text(
                                    "${_selectedTemples.length} ${_selectedTemples.length == 1 ? StringConstant.templeSingular : StringConstant.templesPlural}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                SizedBox(width: 4.w),
                                Icon(Icons.chevron_right, size: 24.sp),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              
                          _showPersonSearch(); 
                            },
                            child: Row(
                              children: [ 
                                  SvgPicture.asset("assets/icon/Vector.svg", width: 15,height: 15,),
                              //  Icon(Icons.person_outline, size: 24.sp),
                                SizedBox(width: 20.w),
                                Text(StringConstant.tagPeopleLabel,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: InkWell(
                              onTap: () {
                                  if (_selectedPeople.isNotEmpty)
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FeedPeopleScreen(
                                              selectedPeople: _selectedPeople,
                                              selectedImages:
                                                  widget.selectedImages,
                                            )));
                              },
                              child: Row(
                                children: [
                                  if (_selectedPeople.isNotEmpty)
                                    Text(
                                      "${_selectedPeople.length} ${_selectedPeople.length == 1 ? StringConstant.peopleSingular : StringConstant.peoplesPlural}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.chevron_right, size: 24.sp),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed:    _sharePost ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.appbarBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isPosting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  StringConstant.shareAction,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
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
