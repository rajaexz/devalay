import 'package:cached_network_image/cached_network_image.dart';
import 'package:devalay_app/src/data/model/feed/feed_home_model.dart'
    as feed_model;
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'dart:async';
import 'dart:io';
// import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/data/model/feed/image_tag.dart';

class ImageHelper {
  static ImageProvider<Object> getProfileImage(String? myImage) {
    if (myImage == null || myImage.isEmpty) {
      return const AssetImage('assets/logo/app_logo.png');
    } else {
      return NetworkImage(myImage);
    }
  }
static void showImagePreview(BuildContext context, String? imagePath) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.7,
                  maxScale: 5.0,
                  child: imagePath != null && imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          imagePath ?? 'assets/logo/app_logo.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}}

class InstagramVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final String postId;
  final bool isLiked;
  final Function(String, bool) onLikeToggle;

  const InstagramVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.postId,
    required this.isLiked,
    required this.onLikeToggle,
    this.autoPlay = false,
  });

  @override
  State<InstagramVideoPlayer> createState() => _InstagramVideoPlayerState();
}

class _InstagramVideoPlayerState extends State<InstagramVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isMuted = true;
  double _progress = 0.0;
  Timer? _controlsTimer;
  Timer? _progressTimer;
  bool _isVisible = true;

  late AnimationController _likeAnimationController;
  bool _showLikeAnimation = false;
  Timer? _likeTimer;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
        _likeAnimationController.reset();
      }
    });
  }

  @override
  void didUpdateWidget(covariant InstagramVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeVideo();
      return;
    }

    if (oldWidget.autoPlay != widget.autoPlay && _isInitialized && !_hasError) {
      if (widget.autoPlay && _isVisible) {
        _playIfReady();
      } else {
        _pauseVideo();
      }
    }
  }

  void _disposeController() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    
    final isNetworkUrl = widget.videoUrl.startsWith('http://') || 
                        widget.videoUrl.startsWith('https://');
    
    // For network URLs, try network first (better for iOS videos)
    if (isNetworkUrl) {
      await _tryNetworkVideo();
      if (_isInitialized) return;
      // Fallback to cache if network fails
      await _tryCacheVideo();
      if (_isInitialized) return;
    } else {
      // For local files, try file first
      await _tryFileVideo();
      if (_isInitialized || _hasError) return;
    }
    
    // If all methods failed, set error state
    if (!_isInitialized && mounted) {
      setState(() {
        _hasError = true;
        _isInitialized = false;
      });
    }
  }

  Future<void> _tryNetworkVideo() async {
    if (!mounted) return;
    
    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      // Add timeout for initialization
      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );
      
      _controller!.setLooping(false);
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      _controller!.addListener(() {
        if (mounted && _controller != null && _controller!.value.position >= _controller!.value.duration) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          if (widget.autoPlay) {
            _controller!.play();
            _isPlaying = true;
          }
        });
      }

      _controller!.addListener(_videoListener);
      _startProgressTimer();
    } catch (e) {
      debugPrint('Network video initialization error: $e');
      _controller?.dispose();
      _controller = null;
    }
  }

  Future<void> _tryCacheVideo() async {
    if (!mounted) return;
    
    try {
      final file = await DefaultCacheManager()
          .getSingleFile(widget.videoUrl)
          .timeout(const Duration(seconds: 15));
      
      _controller?.dispose();
      _controller = VideoPlayerController.file(file);
      
      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );
      
      _controller!.setLooping(false);
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      _controller!.addListener(() {
        if (mounted && _controller != null && _controller!.value.position >= _controller!.value.duration) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          if (widget.autoPlay) {
            _controller!.play();
            _isPlaying = true;
          }
        });
      }

      _controller!.addListener(_videoListener);
      _startProgressTimer();
    } catch (e) {
      debugPrint('Cache video initialization error: $e');
      _controller?.dispose();
      _controller = null;
      // Don't set error here, let _initializeVideo handle it
    }
  }

  Future<void> _tryFileVideo() async {
    if (!mounted) return;
    
    try {
      final file = File(widget.videoUrl);
      if (!await file.exists()) {
        throw Exception('Video file does not exist');
      }
      
      _controller?.dispose();
      _controller = VideoPlayerController.file(file);
      
      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );
      
      _controller!.setLooping(false);
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      _controller!.addListener(() {
        if (mounted && _controller != null && _controller!.value.position >= _controller!.value.duration) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          if (widget.autoPlay) {
            _controller!.play();
            _isPlaying = true;
          }
        });
      }

      _controller!.addListener(_videoListener);
      _startProgressTimer();
    } catch (e) {
      debugPrint('File video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
      _controller?.dispose();
      _controller = null;
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _hasError || _controller == null) return;
    
    final nextVisible = info.visibleFraction > 0.35;
    if (_isVisible == nextVisible || !_isInitialized) return;

    _isVisible = nextVisible;

    if (_isVisible && widget.autoPlay) {
      _playIfReady();
    } else if (!_isVisible) {
      _pauseVideo();
    }
  }

  void _playIfReady() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
    try {
      _controller!.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _showControls = false;
        });
      }
      _startControlsTimer();
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  void _pauseVideo() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
    try {
      _controller!.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      debugPrint('Error pausing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    final duration = _controller!.value.duration;
    final position = _controller!.value.position;

    if (duration.inMilliseconds > 0) {
      setState(() {
        _progress = position.inMilliseconds / duration.inMilliseconds;
      });
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted && _controller != null && _controller!.value.isInitialized && _controller!.value.isPlaying) {
        _videoListener();
      }
    });
  }

  void _togglePlay() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() {
        _isPlaying = !_isPlaying;
        _isPlaying ? _controller!.play() : _controller!.pause();
        _showControls = true;
        _startControlsTimer();
      });
    } catch (e) {
      debugPrint('Error toggling play: $e');
    }
  }

  void _toggleMute() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
        _showControls = true;
        _startControlsTimer();
      });
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleDoubleTapLike(TapDownDetails details) {
    setState(() {
      _doubleTapPosition = details.localPosition;
      _showLikeAnimation = true;
    });

    if (!widget.isLiked) {
      widget.onLikeToggle(widget.postId, true);
    }

    _likeAnimationController.forward();

    _likeTimer?.cancel();
    _likeTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _progressTimer?.cancel();
    _likeTimer?.cancel();
    _likeAnimationController.dispose();
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        _controller!.removeListener(_videoListener);
      }
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Video format not supported',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'This video cannot be played',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CustomLottieLoader());
    }

    return VisibilityDetector(
      key: Key('video-${widget.postId}-${widget.videoUrl.hashCode}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
            if (_showControls) {
              _startControlsTimer();
            }
          });
        },
        onDoubleTapDown: _handleDoubleTapLike,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            if (_showLikeAnimation)
              Positioned(
                left: _doubleTapPosition.dx - 50,
                top: _doubleTapPosition.dy - 50,
                child: AnimatedBuilder(
                  animation: _likeAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 1.0 - (_likeAnimationController.value * 0.5).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _likeAnimationController.value * 1.2,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset("assets/icon/like.svg", width: 40, height: 40,)
                        ),
                      ),
                    );
                  },
                  ),
                ),
              
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[800]!.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            if (_showControls)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            if (_showControls)
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MyMediaViewer extends StatelessWidget {
  final List<feed_model.Media> mediaList;
  final String postId;
  final bool isLiked;
  final Function(String, bool) onLikeToggle;
  final List<ImageTag>? tags;
  final void Function(int mediaId)? onBlockMedia;

  const MyMediaViewer({
    super.key,
    required this.mediaList,
    required this.postId,
    required this.isLiked,
    required this.onLikeToggle,
    this.tags,
    this.onBlockMedia,
  });

  @override
  Widget build(BuildContext context) {
    return buildFullWidthMediaList(
                        mediaList, context, postId, isLiked, onLikeToggle, tags, onBlockMedia);
  }

  static Widget buildFullWidthMediaList(
    List<feed_model.Media> mediaList,
    BuildContext context,
    String postId,
    bool isLiked,
    Function(String, bool) onLikeToggle,
    List<ImageTag>? tags,
    void Function(int mediaId)? onBlockMedia,
  ) {
    if (mediaList.isEmpty) return const SizedBox();

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        children: [
          MediaCarousel(
            mediaList: mediaList,
            postId: postId,
            isLiked: isLiked,
            onLikeToggle: onLikeToggle,
            onBlockMedia: onBlockMedia,
          ),
        ],
      ),
    );
  }
}

/// Instagram-style heart animation widget for double tap
class _DoubleTapHeartAnimation extends StatefulWidget {
  const _DoubleTapHeartAnimation();

  @override
  State<_DoubleTapHeartAnimation> createState() => _DoubleTapHeartAnimationState();
}

class _DoubleTapHeartAnimationState extends State<_DoubleTapHeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 80,
                  shadows: [
                    Shadow(
                      color: Colors.pink,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MediaCarousel extends StatefulWidget {
  final List<feed_model.Media> mediaList;
  final String postId;
  final bool isLiked;
  final Function(String, bool) onLikeToggle;
  final void Function(int mediaId)? onBlockMedia;

  const MediaCarousel({
    super.key,
    required this.mediaList,
    required this.postId,
    required this.isLiked,
    required this.onLikeToggle,
    this.onBlockMedia,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Offset? _heartPosition;
  bool _showHeart = false;

  @override
  bool get wantKeepAlive => true;

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _showHeartAnimation(Offset position) {
    setState(() {
      _heartPosition = position;
      _showHeart = true;
    });
    
    // Hide heart after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  void _openImageGallery(int tappedIndex) {
    final images = widget.mediaList
        .where((m) => (m.fileType ?? '').toLowerCase() != 'video')
        .toList();
    if (images.isEmpty) return;

    // Map the tapped index in mixed media list to its index in images-only list
    final tappedMedia = widget.mediaList[tappedIndex];
    final startIndex = images.indexWhere((m) => m.id == tappedMedia.id);

    if (startIndex < 0) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => _FullScreenImageGallery(
        images: images,
        startIndex: startIndex,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _handlePageChange,
            itemCount: widget.mediaList.length,
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];

              if (media.fileType == 'Video') {
                return InstagramVideoPlayer(
                  videoUrl: media.file ?? '',
                  postId: widget.postId,
                  isLiked: widget.isLiked,
                  onLikeToggle: widget.onLikeToggle,
                  autoPlay: index == _currentPage,
                );
              } else {
                return GestureDetector(
                  onDoubleTapDown: (details) async {
                    final isGuest = await PrefManager.getIsGuest();
                    if (isGuest == true) return;
                    
                    // Show heart animation at tap position
                    _showHeartAnimation(details.localPosition);
                    widget.onLikeToggle(widget.postId, !widget.isLiked);
                  },
                  onTap: () => _openImageGallery(index),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildImage(media.file ?? ''),
                      // Heart animation overlay
                      if (_showHeart && _heartPosition != null)
                        Positioned(
                          left: _heartPosition!.dx - 50,
                          top: _heartPosition!.dy - 50,
                          child: const _DoubleTapHeartAnimation(),
                        ),
                      if (widget.mediaList.length > 1)
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
                                  '${_currentPage + 1}/${widget.mediaList.length}',
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
                        )
                    ],
                  ),
                );    }
            },
          ),
        ),
        if (widget.mediaList.length > 1   && widget.mediaList.length <= 5)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaList.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColor.appbarBgColor
                        : AppColor.greyColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Check for video file extensions
    if (lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.wmv') ||
        lowerUrl.contains('.webm') ||
        lowerUrl.contains('.mkv')) {
      return true;
    }
    // Check for video content URIs (Android MediaStore)
    if (lowerUrl.contains('content://media/external/video/') ||
        lowerUrl.contains('content://media/internal/video/') ||
        lowerUrl.contains('content://media/video/')) {
      return true;
    }
    // Check for video-related paths
    if (lowerUrl.contains('video') && 
        (lowerUrl.contains('media/') || lowerUrl.contains('video/'))) {
      return true;
    }
    return false;
  }

  Widget _buildImage(String imageUrl) {
    // Don't try to load video URLs as images - this causes Glide errors on Android
    if (_isVideoUrl(imageUrl)) {
      return Container(
        width: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.videocam, color: Colors.white, size: 48),
        ),
      );
    }
    
    return CachedNetworkImage(
      width: double.infinity,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: SizedBox()),
      errorWidget: (context, url, error) {
        // Silently handle errors to prevent Glide exceptions from propagating
        return const Center(
          child: Icon(Icons.error, color: Colors.red),
        );
      },
      httpHeaders: const {
        'Accept': 'image/*',
      },
    );
  }
}

class InstagramStyleImageViewer extends StatelessWidget {
  final String imageUrl;
  final int currentIndex;
  final int totalImages;

  const InstagramStyleImageViewer({
    super.key,
    required this.imageUrl,
    required this.currentIndex,
    required this.totalImages,
  });

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Check for video file extensions
    if (lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.wmv') ||
        lowerUrl.contains('.webm') ||
        lowerUrl.contains('.mkv')) {
      return true;
    }
    // Check for video content URIs (Android MediaStore)
    if (lowerUrl.contains('content://media/external/video/') ||
        lowerUrl.contains('content://media/internal/video/') ||
        lowerUrl.contains('content://media/video/')) {
      return true;
    }
    // Check for video-related paths
    if (lowerUrl.contains('video') && 
        (lowerUrl.contains('media/') || lowerUrl.contains('video/'))) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideoUrl(imageUrl);
    return GestureDetector(
        onDoubleTap: () => showFullScreenImage(context),
        child: Stack(children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: isVideo
                ? const Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 48),
                  )
                : imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error_outline,
                              color: Colors.white, size: 48),
                        ),
                        httpHeaders: const {
                          'Accept': 'image/*',
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/logo/app_logo.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
          ),
        ]));
  }

  void showFullScreenImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black,
                child: Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: _isVideoUrl(imageUrl)
                        ? const Center(
                            child: Icon(Icons.videocam, color: Colors.white, size: 48),
                          )
                        : imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                httpHeaders: const {
                                  'Accept': 'image/*',
                                },
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.error_outline, color: Colors.white, size: 48),
                                ),
                              )
                            : Image.asset(
                                imageUrl,
                                fit: BoxFit.contain,
                              ),
                  ),
                ),
              ),
            ),
            // Position indicator
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${currentIndex + 1}/$totalImages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FullScreenImageGallery extends StatefulWidget {
  final List<feed_model.Media> images;
  final int startIndex;

  const _FullScreenImageGallery({
    required this.images,
    required this.startIndex,
  });

  @override
  State<_FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<_FullScreenImageGallery> {
  late final PageController _controller;
  late int _index;

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Check for video file extensions
    if (lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.wmv') ||
        lowerUrl.contains('.webm') ||
        lowerUrl.contains('.mkv')) {
      return true;
    }
    // Check for video content URIs (Android MediaStore)
    if (lowerUrl.contains('content://media/external/video/') ||
        lowerUrl.contains('content://media/internal/video/') ||
        lowerUrl.contains('content://media/video/')) {
      return true;
    }
    // Check for video-related paths
    if (lowerUrl.contains('video') && 
        (lowerUrl.contains('media/') || lowerUrl.contains('video/'))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) {
              final url = widget.images[i].file ?? '';
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.7,
                    maxScale: 5.0,
                    child: _isVideoUrl(url)
                        ? const Center(
                            child: Icon(Icons.videocam, color: Colors.white, size: 48),
                          )
                        : url.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.contain,
                                placeholder: (c, u) =>
                                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (c, u, e) =>
                                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                                httpHeaders: const {
                                  'Accept': 'image/*',
                                },
                              )
                            : Image.asset(
                                url,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_index + 1}/${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
