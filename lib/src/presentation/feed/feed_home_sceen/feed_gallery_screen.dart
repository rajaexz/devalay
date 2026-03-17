import 'dart:typed_data';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/feed/crop_screen/multipul_crop.dart';
import 'package:devalay_app/src/presentation/feed/crop_screen/multiple_video_trim_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/selected_gallery.dart';

import '../widget/customDropdown_appBar.dart';

enum MediaFilter { all, photos, videos, recents }

class InstagramGalleryPicker extends StatefulWidget {
  final Function(List<XFile>)? onMediaSelected;
  final bool autoCheckPermission; // Flag to control automatic permission check

  const InstagramGalleryPicker({
    super.key, 
    this.onMediaSelected,
    this.autoCheckPermission = true, // Default to true for backward compatibility
  });

  @override
  State createState() => _InstagramGalleryPickerState();
}

class _InstagramGalleryPickerState extends State<InstagramGalleryPicker> with WidgetsBindingObserver {
  List<AssetEntity> mediaList = [];
  Set<AssetEntity> selectedAssets = {};
  late FeedHomeCubit feedHomeCubit;
  bool _isLoading = true;
  bool permissionDenied = false;
  bool _hasCheckedPermission = false; // Track if permission has been checked
  MediaFilter _currentFilter = MediaFilter.all;
  String _currentFilter2 = "Create Post";
  final Map<String, Uint8List> _thumbnailCache = {};
  final Map<String, XFile> _croppedFiles = {};
  final Map<String, int> _videoDurations = {};

  bool _isMenuOpen = false;
  bool _isMultiSelectionMode = false;
  AssetEntity? _singleSelectedAsset;
  bool _isLimitedAccess = false; // True when user has selected "Limited" (select photos only)

  @override
  void initState() {
    super.initState();
    feedHomeCubit = context.read<FeedHomeCubit>();
    // Register lifecycle observer to detect when app resumes
    WidgetsBinding.instance.addObserver(this);
    // Automatically request permission when widget is initialized (only if autoCheckPermission is true)
    if (widget.autoCheckPermission) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkPermissionAndLoadMedia();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    selectedAssets = {};
    mediaList = [];

    super.dispose();
  }

  // Public method to manually trigger permission check (used when autoCheckPermission is false)
  void triggerPermissionCheck() {
    if (!_hasCheckedPermission) {
      _checkPermissionAndLoadMedia();
    }
  }

  /// Called from landing when permission is already granted – loads media without showing permission UI.
  void loadMediaWithPermissionAlreadyGranted(PermissionState ps) {
    if (!ps.isAuth && !ps.hasAccess) return;
    _hasCheckedPermission = true;
    setState(() {
      permissionDenied = false;
      _isLimitedAccess = ps.hasAccess && !ps.isAuth;
    });
    loadAllMedia(knownPermissionState: ps);
  }

  Future<void> _checkPermissionAndLoadMedia() async {
    if (_hasCheckedPermission) return; // Prevent multiple requests
    _hasCheckedPermission = true;

    // Automatically request permission - this will show the system permission dialog
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
      if (ps.isAuth || ps.hasAccess) {
      // Permission granted (full or limited), load media automatically
      setState(() {
        permissionDenied = false;
        _isLimitedAccess = ps.hasAccess && !ps.isAuth; // Limited = hasAccess but not full auth
      });
        loadMedia(_currentFilter);
      } else {
      // Permission denied - show dialog to guide user
        setState(() {
          _isLoading = false;
          permissionDenied = true;
        });
        _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'To view your photos and videos you can choose:\n\n'
            '• Select photos (Limited) – allow access to selected photos only\n'
            '• Allow all photos (Full) – allow access to entire library\n\n'
            'When the system dialog appears, pick the option you prefer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Open settings for full access
                PhotoManager.openSetting().then((_) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _hasCheckedPermission = false;
                      _checkPermissionAndLoadMedia();
                    }
                  });
                });
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'When prompted, choose "Select Photos" for limited access or "Allow" for full access.',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
                _hasCheckedPermission = false;
                _checkPermissionAndLoadMedia();
              },
              child: const Text('Select photos (Limited)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _hasCheckedPermission = false;
                _checkPermissionAndLoadMedia();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    });
  }

  /// Lets user add more photos when they have limited access.
  /// iOS: presentLimited() opens system picker to select more photos.
  /// Android: try presentLimited first; if not supported, show dialog with Open Settings.
  Future<void> _addMorePhotos() async {
    if (!_isLimitedAccess) return;
    try {
      // Try presentLimited on both platforms – iOS shows photo selection; some Android may support it
      await PhotoManager.presentLimited(type: RequestType.all);
      if (!mounted) return;
      _hasCheckedPermission = false;
      await _checkPermissionAndLoadMedia();
    } catch (e) {
      // presentLimited not supported (e.g. Android) or failed – show dialog with options
      if (!mounted) return;
      await _showAddMorePhotosDialog();
    }
  }

  /// Shows dialog: Choose from gallery (image picker) or Open Settings.
  /// In limited access, "Choose from gallery" lets user add more photos/videos to use in the app.
  Future<void> _showAddMorePhotosDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add more media'),
        content: const Text(
          'In limited access you can:\n\n'
          '• Choose from gallery – pick more photos & videos to use for posts\n'
          '• Open Settings – allow the app to see more of your library',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openGalleryAndSelectMedia();
            },
            child: const Text('Choose from gallery'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PhotoManager.openSetting();
              if (!mounted) return;
              _hasCheckedPermission = false;
              await _checkPermissionAndLoadMedia();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Opens system gallery via image_picker; user selects photos/videos, then navigates to SelectedGallery.
  /// On return, refreshes gallery so limited-access users see updated state.
  Future<void> _openGalleryAndSelectMedia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> picked = await picker.pickMultipleMedia(
        limit: 50,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (picked.isEmpty) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedGallery(selectedImages: picked),
        ),
      );
      // Refresh gallery when user returns (e.g. after adding more in limited access)
      if (!mounted) return;
      _hasCheckedPermission = false;
      await _checkPermissionAndLoadMedia();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> loadMedia(MediaFilter filter) async {
    if (_isLoading == false) {
      setState(() {
        _isLoading = true;
      });
    }

    setState(() {
      _currentFilter = filter;
    });

    // For "All Media", use pagination to load all items
    if (filter == MediaFilter.all) {
      await loadAllMedia();
      return;
    }

    try {
      RequestType requestType;

      switch (filter) {
        case MediaFilter.photos:
          requestType = RequestType.image;
          break;
        case MediaFilter.videos:
          requestType = RequestType.video;
          break;
        case MediaFilter.recents:
          requestType = RequestType.common;
          break;
        case MediaFilter.all:
          requestType = RequestType.all;
          break;
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: requestType,
      );

      if (albums.isNotEmpty) {
        // Use pagination for photos and videos too if they exceed limit
        List<AssetEntity> media = [];
        int page = 0;
        const int pageSize = 1000;

        // Load all pages until we get all media or hit a reasonable limit
        while (true) {
          List<AssetEntity> pageMedia =
              await albums.first.getAssetListPaged(page: page, size: pageSize);

          if (pageMedia.isEmpty) break;

          media.addAll(pageMedia);
          page++;

          // For photos/videos, load up to 5000 items
          // For recents, only load first page (500 items)
          if (filter == MediaFilter.recents || media.length >= 5000) {
            break;
          }
        }

        if (filter == MediaFilter.recents) {
          media.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
        }

        for (var asset in media) {
          if (asset.type == AssetType.video) {
            _loadVideoDuration(asset);
          }
        }

        // Update selected assets based on current mode
        if (_isMultiSelectionMode) {
          final Set<AssetEntity> newSelectedAssets = {};
          for (final asset in selectedAssets) {
            if (media.contains(asset)) {
              newSelectedAssets.add(asset);
            }
          }
          selectedAssets = newSelectedAssets;
        } else {
          // In single selection mode, update single selected asset
          if (_singleSelectedAsset != null &&
              !media.contains(_singleSelectedAsset)) {
            _singleSelectedAsset = null;
          }
        }

        setState(() {
          mediaList = media;
          _isLoading = false;
          permissionDenied = false;
        });

        // Auto-select first item - always ensure something is selected
        if (media.isNotEmpty &&
            _singleSelectedAsset == null &&
            selectedAssets.isEmpty) {
          setState(() {
            if (_isMultiSelectionMode) {
              selectedAssets.add(media.first);
            } else {
              _singleSelectedAsset = media.first;
            }
          });
        }
      } else {
        setState(() {
          mediaList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading media: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideoDuration(AssetEntity asset) async {
    try {
      final duration = asset.duration;
      setState(() {
        _videoDurations[asset.id] = duration;
      });
    } catch (e) {
      print("Error loading video duration: $e");
    }
  }

  void toggleSelection(AssetEntity asset) {
    if (_isMultiSelectionMode) {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
        _croppedFiles.remove(asset.id);
      } else {
        selectedAssets.add(asset);
      }
    } else {
      setState(() {
        _singleSelectedAsset = asset;
      });
    }
    setState(() {});
  }

  // New method to handle long press
  void _onLongPress(AssetEntity asset) {
    if (!_isMultiSelectionMode) {
      setState(() {
        _isMultiSelectionMode = true;
        // Transfer single selection to multi-selection
        if (_singleSelectedAsset != null) {
          selectedAssets.add(_singleSelectedAsset!);
        }
        // Add the long-pressed asset if not already selected
        if (!selectedAssets.contains(asset)) {
          selectedAssets.add(asset);
        }
        _singleSelectedAsset = null;
      });

      // Show a feedback (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Multi-selection mode enabled'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Method to get currently selected assets for display and processing
  Set<AssetEntity> get _getCurrentlySelected {
    if (_isMultiSelectionMode) {
      return selectedAssets;
    } else {
      return _singleSelectedAsset != null
          ? {_singleSelectedAsset!}
          : <AssetEntity>{};
    }
  }

  void _onPostPressed() async {
    final selected = _getCurrentlySelected;
    if (selected.isEmpty) return;

    final images = <AssetEntity>[];
    final videos = <AssetEntity>[];
    for (final asset in selected) {
      if (asset.type == AssetType.image) images.add(asset);
      if (asset.type == AssetType.video) videos.add(asset);
    }

    // Only images
    if (images.isNotEmpty && videos.isEmpty) {
      final cropped = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultipleCropScreen(assets: images),
          ));
      if (cropped is List<XFile> && cropped.isNotEmpty) {
        // If onMediaSelected callback exists, return images directly (for edit screen)
        // Otherwise navigate to SelectedGallery (for create post)
        if (widget.onMediaSelected != null) {
          widget.onMediaSelected!(cropped);
          Navigator.pop(context, cropped);
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectedGallery(selectedImages: cropped),
            ));
      }
      return;
    }

    // Only videos
    if (videos.isNotEmpty && images.isEmpty) {
      final trimmed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultipleVideoTrimScreen(videos: videos),
          ));
      if (trimmed is Map && trimmed['trimmedVideos'] is List<XFile>) {
        final trimmedVideos = trimmed['trimmedVideos'] as List<XFile>;
        // If no videos were produced (e.g. all skipped), stay on gallery
        if (trimmedVideos.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No video selected after trimming'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // If onMediaSelected callback exists, return videos directly (for edit screen)
          if (widget.onMediaSelected != null) {
            widget.onMediaSelected!(trimmedVideos);
            Navigator.pop(context, trimmedVideos);
            return;
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SelectedGallery(selectedImages: trimmedVideos),
              ));
        }
      }
      return;
    }

    // Both images and videos
    if (images.isNotEmpty && videos.isNotEmpty) {
      final cropped = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MultipleCropScreen(assets: images, videosToKeep: videos),
          ));
      final croppedImages = (cropped is List<XFile>) ? cropped : <XFile>[];
      final trimmed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultipleVideoTrimScreen(
                videos: videos, croppedImages: croppedImages),
          ));
      List<XFile> allMedia = [];
      if (trimmed is Map) {
        final trimmedVideos = trimmed['trimmedVideos'] as List<XFile>? ?? [];
        final croppedAgain =
            trimmed['croppedImages'] as List<XFile>? ?? croppedImages;
        allMedia = [...croppedAgain, ...trimmedVideos];
      }
      if (allMedia.isNotEmpty) {
        // If onMediaSelected callback exists, return media directly (for edit screen)
        if (widget.onMediaSelected != null) {
          widget.onMediaSelected!(allMedia);
          Navigator.pop(context, allMedia);
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectedGallery(selectedImages: allMedia),
            ));
      }
      return;
    }
  }

  Future<Uint8List?> _getThumbnail(AssetEntity asset) async {
    final String assetId = asset.id;
    if (_thumbnailCache.containsKey(assetId)) {
      return _thumbnailCache[assetId];
    }

    try {
      // For videos, use thumbnailData with proper size to avoid Glide errors
      if (asset.type == AssetType.video) {
        try {
          // Use a reasonable thumbnail size for videos to prevent Glide from trying to decode the video file
          // Use smaller size and shorter timeout to reduce Glide errors
          final Uint8List? thumbnail = await asset
              .thumbnailDataWithSize(
            const ThumbnailSize(
                200, 200), // Reduced size to minimize Glide processing
          )
              .timeout(
            const Duration(seconds: 3), // Shorter timeout
            onTimeout: () {
              // Silently handle timeout - these are expected for corrupted/inaccessible videos
              return null;
            },
          );
          if (thumbnail != null && thumbnail.isNotEmpty) {
            _thumbnailCache[assetId] = thumbnail;
            return thumbnail;
          }
        } on PlatformException catch (e) {
          // Silently catch PlatformException from photo_manager's internal Glide usage
          // This happens when MediaMetadataRetriever fails to decode the video
          // These errors are expected for some video files and are handled gracefully
          // Only log in debug mode to reduce console noise
          assert(() {
            debugPrint(
                'Video thumbnail load failed for ${asset.id}: ${e.message}');
            return true;
          }());
          // Return null to show placeholder instead of crashing
          return null;
        } catch (e) {
          // Silently catch any other exceptions
          assert(() {
            debugPrint('Exception loading video thumbnail for ${asset.id}: $e');
            return true;
          }());
          return null;
        }
        // If thumbnail fails, return null to show placeholder instead of trying content URI
        return null;
      } else {
        // For images, use the default thumbnail
        try {
          final Uint8List? thumbnail = await asset.thumbnailData.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Silently handle timeout
              return null;
            },
          );
          if (thumbnail != null && thumbnail.isNotEmpty) {
            _thumbnailCache[assetId] = thumbnail;
          }
          return thumbnail;
        } on PlatformException catch (e) {
          // Silently catch PlatformException for images
          assert(() {
            debugPrint(
                'Image thumbnail load failed for ${asset.id}: ${e.message}');
            return true;
          }());
          return null;
        } catch (e) {
          // Silently catch other exceptions
          assert(() {
            debugPrint('Exception loading image thumbnail for ${asset.id}: $e');
            return true;
          }());
          return null;
        }
      }
    } catch (e) {
      // Silently handle outer catch
      assert(() {
        debugPrint('Error loading thumbnail for asset ${asset.id}: $e');
        return true;
      }());
      // Return null instead of trying alternative methods that might use content URIs
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentlySelected = _getCurrentlySelected;
    final asset = mediaList.isNotEmpty ? mediaList[0] : null;
    return SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomDropdownAppBar(
            isSelectMultiple: currentlySelected,
            currentFilter: _currentFilter2,
            onFilterChanged: (value) {
              setState(() {
                _currentFilter2 = value ?? "Create Post";
              });
            },
            onPostPressed: _onPostPressed,
          ),
          body: Column(
            children: [
              // Show selection mode indicator
              Container(
                height: 220,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: currentlySelected.isEmpty
                    ? asset != null
                        ? FutureBuilder<Uint8List?>(
                            future: _getThumbnail(asset),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const Center(
                                    child: Icon(Icons.image,
                                        size: 60, color: Colors.grey));
                              }
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 220,
                              );
                            },
                          )
                        : const Center(
                            child:
                                Icon(Icons.image, size: 60, color: Colors.grey))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: currentlySelected.length,
                        itemBuilder: (context, index) {
                          final asset = currentlySelected.elementAt(index);
                          return Container(
                            width: MediaQuery.of(context).size.width - 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: FutureBuilder<Uint8List?>(
                                future: _getThumbnail(asset),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return const Center(
                                        child: Icon(Icons.image,
                                            size: 60, color: Colors.grey));
                                  }
                                  return Stack(
                                    children: [
                                      Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 220,
                                      ),
                                      if (asset.type == AssetType.video)
                                        Positioned(
                                          right: 10,
                                          bottom: 10,
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
                                                const Icon(Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 16),
                                                Gap(4.w),
                                                Text(
                                                  _formatDuration(
                                                      asset.duration),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Row(
                children: [
                  DropdownButton2<MediaFilter>(
                    customButton: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Shrinks to fit content
                        children: [
                          Text(
                            // ignore: unnecessary_null_comparison
                            _currentFilter == null
                                ? "Select Media"
                                : _currentFilter == MediaFilter.recents
                                    ? "Recent"
                                    : _currentFilter == MediaFilter.all
                                        ? "All Media"
                                        : _currentFilter == MediaFilter.photos
                                            ? "Photos Only"
                                            : "Videos Only",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(
                              width:
                                  8), // 👈 Exact spacing between text and icon
                          Icon(
                            _isMenuOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    value: _currentFilter,
                    underline: const SizedBox(),
                    dropdownStyleData: const DropdownStyleData(
                      offset: Offset(10, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MediaFilter.recents,
                        child: Text("Recent"),
                      ),
                      DropdownMenuItem(
                        value: MediaFilter.all,
                        child: Text("All Media"),
                      ),
                      DropdownMenuItem(
                        value: MediaFilter.photos,
                        child: Text("Photos Only"),
                      ),
                      DropdownMenuItem(
                        value: MediaFilter.videos,
                        child: Text("Videos Only"),
                      ),
                    ],
                    onChanged: (MediaFilter? value) {
                      if (value != null) {
                        if (value == MediaFilter.all) {
                          loadAllMedia();
                        } else {
                          loadMedia(value);
                        }
                      }
                    },
                    onMenuStateChange: (isOpen) {
                      setState(() {
                        _isMenuOpen = isOpen;
                      });
                    },
                  ),

                  if (_isLimitedAccess) ...[
                    const SizedBox(width: 8),
                    Material(
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _addMorePhotos,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 20,
                                color: AppColor.orangeColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Add more media',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.orangeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ignore: prefer_const_constructors
                  const Spacer(),
                  if (_isMultiSelectionMode)
                    Padding(
                      padding: EdgeInsets.only(left: 12.sp, right: 12.sp),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColor.whiteColor,
                          foregroundColor: AppColor.blackColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        label: Text(
                          'Selected (${currentlySelected.length})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () {
                          setState(() {
                            _isMultiSelectionMode = false;
                            _singleSelectedAsset = selectedAssets.isNotEmpty
                                ? selectedAssets.first
                                : null;
                            selectedAssets.clear();
                          });
                        },
                      ),
                    ),
                ],
              ),

              Expanded(
                child: mediaList.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(StringConstant.noDataAvailable),
                          const Gap(10),
                   
                        ],
                      )
                    : _buildMediaGrid(),
              ),
            ],
        ),
      ),
    );
  }

  // Override didChangeAppLifecycleState to check permission when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && permissionDenied) {
      // When app resumes, check permission again if it was previously denied
      _hasCheckedPermission = false;
      _checkPermissionAndLoadMedia();
    }
  }

  Widget _buildMediaGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(2.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final asset = mediaList[index];
                return _buildMediaTile(asset);
              },
              childCount: mediaList.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTile(AssetEntity asset) {
    final currentlySelected = _getCurrentlySelected;
    final isSelected = currentlySelected.contains(asset);
    final isVideo = asset.type == AssetType.video;
    final videoDuration = _videoDurations[asset.id];

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<Uint8List?>(
              key: ValueKey(asset.id),
              future: _getThumbnail(asset),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: .2)),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        isVideo ? Icons.videocam : Icons.image,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          if (isVideo)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 16.sp),
                    if (videoDuration != null)
                      Text(
                        _formatDuration(videoDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          StatefulBuilder(
            builder: (context, setInnerState) {
              return Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      toggleSelection(asset);
                      setInnerState(() {});
                    },
                    onLongPress: () {
                      _onLongPress(asset);
                      setInnerState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black.withOpacity(0.3)
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(color: AppColor.blackColor, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: _isMultiSelectionMode
                                    ? Text(
                                        '${currentlySelected.toList().indexOf(asset) + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits((seconds ~/ 60).remainder(60));
    final remainingSeconds = twoDigits(seconds.remainder(60));
    return "$minutes:$remainingSeconds";
  }

  Future<void> loadAllMedia({PermissionState? knownPermissionState}) async {
    if (_isLoading == false) {
      setState(() {
        _isLoading = true;
      });
    }

    setState(() {
      _currentFilter = MediaFilter.all;
    });

    final PermissionState ps = knownPermissionState ??
        await PhotoManager.requestPermissionExtend();
    // Accept both full (isAuth) and limited (hasAccess) permission
    if (!ps.isAuth && !ps.hasAccess) {
      setState(() {
        _isLoading = false;
        permissionDenied = true;
      });
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isLimitedAccess = ps.hasAccess && !ps.isAuth;
    });

    try {
      // Use RequestType.all to get all media types (images + videos)
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.all,
      );

      if (albums.isNotEmpty) {
        List<AssetEntity> allMedia = [];
        int page = 0;
        const int pageSize = 1000;

        // Load all pages until we get all media
        while (true) {
          List<AssetEntity> pageMedia =
              await albums.first.getAssetListPaged(page: page, size: pageSize);

          if (pageMedia.isEmpty) break;

          allMedia.addAll(pageMedia);
          page++;

          // Remove the 10000 limit to load all media
          // But add a safety check to prevent infinite loops
          if (pageMedia.length < pageSize) {
            // Last page, no more media to load
            break;
          }
        }

        // Sort by creation date (newest first) for better UX
        allMedia.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

        for (var asset in allMedia) {
          if (asset.type == AssetType.video) {
            _loadVideoDuration(asset);
          }
        }

        // Update selected assets based on current mode
        if (_isMultiSelectionMode) {
          final Set<AssetEntity> newSelectedAssets = {};
          for (final asset in selectedAssets) {
            if (allMedia.contains(asset)) {
              newSelectedAssets.add(asset);
            }
          }
          selectedAssets = newSelectedAssets;
        } else {
          if (_singleSelectedAsset != null &&
              !allMedia.contains(_singleSelectedAsset)) {
            _singleSelectedAsset = null;
          }
        }

        setState(() {
          mediaList = allMedia;
          _isLoading = false;
          permissionDenied = false;
        });

        // Auto-select first item - always ensure something is selected
        if (allMedia.isNotEmpty &&
            _singleSelectedAsset == null &&
            selectedAssets.isEmpty) {
          setState(() {
            if (_isMultiSelectionMode) {
              selectedAssets.add(allMedia.first);
            } else {
              _singleSelectedAsset = allMedia.first;
            }
          });
        }
      } else {
        setState(() {
          mediaList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading all media: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }
}
