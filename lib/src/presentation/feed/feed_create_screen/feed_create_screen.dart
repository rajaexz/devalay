import 'dart:convert';
import 'dart:io';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_profile/profile_profile_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/helper/show_blurred_dialoge.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/blurred_dialoge_box.dart';
import 'package:devalay_app/src/presentation/core/widget/feed_appBar.dart';
import 'package:devalay_app/src/presentation/feed/widget/comment_Input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_gallery_screen.dart';

class FeedEditScreen extends StatefulWidget {
  final FeedGetData existingPost; // Made required since this is edit-only

  const FeedEditScreen({super.key, required this.existingPost});

  @override
  State<FeedEditScreen> createState() => _FeedEditScreenState();
}

class _FeedEditScreenState extends State<FeedEditScreen> {
  late FeedHomeCubit feedHomeCubit;
  late ProfileCubit profileCubit;
  late GobelSearchCubit gobelSearchCubit;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  String? userName;
  String? userImg;
  String? userId;
  String? deltaJson;
  String? html;

  @override
  void initState() {
    super.initState();

    feedHomeCubit = context.read<FeedHomeCubit>();
    gobelSearchCubit = context.read<GobelSearchCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      getUserData();
      _setupEditorWithExistingPost();
    });
  }

  /// Pick additional images from gallery while editing a post
  Future<void> _pickImagesFromGallery() async {
    // Navigate to InstagramGalleryPicker which uses PhotoManager
    // This ensures the same permission system is used for both create post and gallery tab
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstagramGalleryPicker(
          onMediaSelected: (List<XFile> media) {
            // This callback will be handled when user selects media
          },
        ),
      ),
    );

    // Handle the result if images were selected
    if (result != null && result is List<XFile> && result.isNotEmpty) {
        setState(() {
        feedHomeCubit.selectedMedia.addAll(result);
        });
    }
  }

  void _setupEditorWithExistingPost() {
    try {
      // Setup existing post content
      if (widget.existingPost.textDelta != null) {
        final textData = widget.existingPost.textDelta;
        final deltaJsonRaw = textData ?? "{}";

        var deltaJson;
        try {
          deltaJson = jsonDecode(deltaJsonRaw);
        } catch (e) {
          print("Failed to parse delta JSON: $e");
          deltaJson = {"ops": []};
        }

        Document doc;
        if (deltaJson is Map && deltaJson.containsKey("ops")) {
          doc = Document.fromJson(deltaJson["ops"]);
        } else if (deltaJson is List) {
          doc = Document.fromJson(deltaJson);
        } else {
          doc = Document();
        }

        feedHomeCubit.commentController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );

        final currentDelta = jsonEncode({"ops": doc.toDelta().toJson()});
        final currentHtml = convertToHtml(doc);

        setState(() {
          deltaJson = currentDelta;
          html = currentHtml;
        });
      } else {
        feedHomeCubit.commentController = QuillController.basic();
      }
    } catch (e) {
      print("Error setting up editor with existing post: $e");
      feedHomeCubit.commentController = QuillController.basic();
    }

    // Setup existing media
    feedHomeCubit.selectedMedia =
        widget.existingPost.media?.map((e) => XFile(e.file!)).toList() ?? [];
    feedHomeCubit.commentController.addListener(feedHomeCubit.updateCharCount);
  }

  getUserData() async {
    userName = await PrefManager.getUserName();
    userImg = await PrefManager.getUserProfileImage();
    userId = await PrefManager.getUserDevalayId();
    context.read<ProfileCubit>().init(userId.toString());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    feedHomeCubit.commentController
        .removeListener(feedHomeCubit.updateCharCount);
    super.dispose();
  }

  void updateCommentContent(String delta, String htmlContent) {
    setState(() {
      deltaJson = delta;
      html = htmlContent;
    });
  }

  void updatePost() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    bool isMediaSelected = feedHomeCubit.selectedMedia.isNotEmpty;
    String? commentText =
        feedHomeCubit.commentController.document.toPlainText().trim();

    // Validation for empty content
    if (commentText.isEmpty && !isMediaSelected) {
      showBlurredDialoge(
        context,
        dialoge: BlurredDialogBox(
          title: StringConstant.warningTitle,
          svgImagePath: "assets/icon/warning.svg",
          svgImageColor: Colors.redAccent,
          divider: true,
          acceptButtonName: StringConstant.proceedBtn,
          cancelButtonName: StringConstant.cancel,
          acceptButtonColor: Colors.redAccent,
          acceptTextColor: Colors.white,
          cancelButtonColor: Colors.grey.shade300,
          cancelTextColor: Colors.black,
          showCancelButton: false,
          content: Text(
            StringConstant.oopsCommentOrMedia,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          barrierDismissible: false,
          isAcceptContainerPush: false,
          onAccept: () async {},
        ),
      );
      return;
    }

    final currentDelta =
        jsonEncode(feedHomeCubit.commentController.document.toDelta().toJson());
    final currentHtml = convertToHtml(feedHomeCubit.commentController.document);

    final purposeOutput = {
      'delta': currentDelta,
      'html': "<p>${currentHtml.isEmpty ? '' : currentHtml}</p>",
    };

    final onlyFileImage = feedHomeCubit.selectedMedia
        .where((image) => !image.path.startsWith("http"))
        .toList();

    feedHomeCubit.feedUpdatePost(
      id: widget.existingPost.id!,
      file: onlyFileImage,
      title: jsonEncode(purposeOutput),
      deletedNetworkImage: feedHomeCubit.deletePost,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedHomeCubit, FeedHomeState>(
      builder: (context, state) {
        final feedCubit = context.read<FeedHomeCubit>();
        context.read<ProfileInfoCubit>();
        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: SimpleAppBar(
              onTap: updatePost,
              brandName: StringConstant.editPost,
              calledFrom: "createPost",
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                                builder: (context, profileState) {
                                  if (profileState is ProfileLoaded) {
                                    return const Center(
                                        child: CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/logo/app_logo.png'),
                                      radius: 20,
                                    ));
                                  }

                                  if (profileState is ProfileInfoLoaded) {
                                    if (profileState.loadingState) {
                                      return const Center(
                                          child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/logo/app_logo.png'),
                                        radius: 20,
                                      ));
                                    }

                                    return CircleAvatar(
                                      backgroundImage: userImg != null &&
                                              userImg!.isNotEmpty
                                          ? NetworkImage(userImg.toString())
                                          : profileState.profileInfoModel !=
                                                      null &&
                                                  profileState.profileInfoModel!
                                                      .dp!.isNotEmpty
                                              ? NetworkImage(profileState
                                                  .profileInfoModel!.dp
                                                  .toString())
                                              : const AssetImage(
                                                      'assets/logo/app_logo.png')
                                                  as ImageProvider,
                                      radius: 20,
                                    );
                                  }

                                  return const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/logo/app_logo.png'),
                                    radius: 20,
                                  );
                                },
                              ),
                              Gap(10.w),
                              Expanded(
                                child: Text(
                                  userName ?? StringConstant.noName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          Gap(10.h),
                          CommentInputWidget(
                            onContentChanged: updateCommentContent,
                          ),
                          Gap(8.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Spacer(),
                                if (feedHomeCubit.charCount < 10)
                                  Text(
                                    "${feedHomeCubit.charCount}/10 - ${StringConstant.typing}",
                                    style: TextStyle(
                                        color: feedHomeCubit.charCount < 10
                                            ? Colors.grey.shade400
                                            : Colors.red,
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (feedCubit.selectedMedia.isNotEmpty)
                            SizedBox(
                              height: 80.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: feedCubit.selectedMedia.length,
                                itemBuilder: (context, index) {
                                  String mediaPath =
                                      feedCubit.selectedMedia[index].path;

                                  bool isVideo = mediaPath.endsWith(".mp4");
                                  bool isNetworkImage =
                                      mediaPath.startsWith("http");

                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(4),
                                        width: 80.w,
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: isVideo
                                              ? const DecorationImage(
                                                  image: AssetImage(
                                                      'assets/icon/video-player.jpg'),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: isNetworkImage
                                                      ? NetworkImage(mediaPath)
                                                          as ImageProvider
                                                      : FileImage(
                                                              File(mediaPath))
                                                          as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      // Allow deleting even when there is only a single media item
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isNetworkImage) {
                                                feedCubit.storeDeletePost(
                                                  deleteId: widget.existingPost
                                                      .media![index].id
                                                      .toString(),
                                                  id: widget.existingPost.id!,
                                                  index: index,
                                                );
                                              } else {
                                                feedCubit.removeMedia(index);
                                              }
                                            },
                                            child: feedCubit.deletePostLoader
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CustomLottieLoader(),
                                                  )
                                                : const CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    radius: 12,
                                                    child: Icon(Icons.close,
                                                        size: 16,
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.lightTextColor
                      : AppColor.whiteColor,
                  margin:
                      const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 11),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Image.asset(
                            "assets/icon/gallery.png",
                            fit: BoxFit.fill,
                          ),
                          onTap: _pickImagesFromGallery,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
