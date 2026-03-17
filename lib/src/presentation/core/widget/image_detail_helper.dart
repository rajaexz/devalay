import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ImageHelpers {
  static ImageProvider<Object> getProfileImage(String? myImage) {
    if (myImage == null || myImage.isEmpty) {
      return const AssetImage('assets/logo/app_logo.png');
    } else {
      return NetworkImage(myImage);
    }
  }

  static Widget buildFullWidthMediaList(
      List<Media> mediaList, BuildContext context) {
    if (mediaList.isEmpty) {
      return const SizedBox();
    }

    final videoCount =
        mediaList.where((element) => element.fileType == "Video").length;
    final imageCount =
        mediaList.where((element) => element.fileType == "Image").length;

    return SizedBox(
      height: 280.h, 
      child: PageView.builder(
        itemCount: mediaList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final media = mediaList[index];

          if (media.fileType == 'Video') {
            return FullWidthVideoPlayer(
              videoUrl: media.file ?? '',
              mediaList: mediaList,
              index: index,
            );
          } else {
            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: media.file != null && media.file!.startsWith('http')
                        ? Image.network(
                            media.file!,
                            height: 280.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Image(
                              image: AssetImage('assets/logo/app_logo.png'),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            media.file ?? 'assets/logo/app_logo.png',
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                mediaList.length == 1
                    ? const SizedBox()
                    : Positioned(
                        top: 10.h,
                        right: 24.h,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColor.blackColor.withOpacity(.5),
                          ),
                          child: Text(
                            "${index + 1}/${videoCount + imageCount}",
                            style:  TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 10.h,
                            ),
                          ),
                        ),
                      ),
              ],
            );
          }
        },
      ),
    );
  }
}
// ignore: must_be_immutable
class FullWidthVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final List<Media>? mediaList;
  int index;

  FullWidthVideoPlayer(
      {super.key, required this.videoUrl, this.mediaList, required this.index});

  @override
  State<FullWidthVideoPlayer> createState() => _FullWidthVideoPlayerState();
}

class _FullWidthVideoPlayerState extends State<FullWidthVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false; // Remove final keyword
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.pause();
        }
      }).catchError((error) {
        debugPrint("Video Load Error: $error");
      });

    // Listen to video player state changes
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    if (!_isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    // Add video controls overlay
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Center(child: CustomLottieLoader());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    widget.controller.play();

    _chewieController = ChewieController(
      videoPlayerController: widget.controller,
      autoPlay: true,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.black26,
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Listen to controller state changes
    widget.controller.addListener(_videoListener);
    
    // Auto-hide controls after 3 seconds
    _startHideControlsTimer();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
      _showControls = true;
      _startHideControlsTimer();
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    _chewieController.dispose();
    _animationController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _showControlsTemporarily,
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Chewie(controller: _chewieController),
                    
                    // Custom play/pause overlay
                    if (_showControls)
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: !_isPlaying ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Close button
                    if (_showControls)
                      Positioned(
                        top: 40,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}