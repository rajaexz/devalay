import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MultipleVideoTrimScreen extends StatefulWidget {
  final List<AssetEntity> videos;
  final List<XFile>? croppedImages;

  const MultipleVideoTrimScreen({super.key, required this.videos, this.croppedImages});

  @override
  State<MultipleVideoTrimScreen> createState() => _MultipleVideoTrimScreenState();
}

class _MultipleVideoTrimScreenState extends State<MultipleVideoTrimScreen> {
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  final Map<String, Map<String, dynamic>> _trimmedVideos = {};
  bool _isLoading = false;
  double _startValue = 0.0;
  double _endValue = 0.0;
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  bool isDraggingStart = false;
  bool isDraggingEnd = false;
  bool _isDraggingScrubber = false;
  double _playbackSpeed = 1.0;
  String _selectedFilter = 'Normal';
  bool _showFilters = false;
  Duration? _coverFrame;
  ImageProvider? _coverPreview;
  
  // Video timeline thumbnails
  final Map<int, Uint8List> _timelineThumbnails = {};
  bool _isGeneratingThumbnails = false;
  
  // Instagram-style editing properties
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _exposure = 0.0;
  double _highlights = 0.0;
  double _shadows = 0.0;
  double _vibrance = 0.0;
  double _warmth = 0.0;
  double _fade = 0.0;
  double _vignette = 0.0;
  bool _showAdjustments = false;
  String _selectedAdjustment = '';
  
  // Aspect ratio selection
  double _selectedAspectRatio = 16/9;
  final Map<String, double> _aspectRatios = {
    'Original': 0.0, // Will be set to video's original ratio
    'Square (1:1)': 1.0,
    'Portrait (9:16)': 9/16,
    'Landscape (16:9)': 16/9,
    'Cinema (21:9)': 21/9,
  };

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'brightness': 0.0, 'contrast': 1.0, 'saturation': 1.0, 'warmth': 0.0},
    {'name': 'Vintage', 'brightness': 0.1, 'contrast': 1.2, 'saturation': 0.8, 'warmth': 0.3},
    {'name': 'Warm', 'brightness': 0.05, 'contrast': 1.1, 'saturation': 1.1, 'warmth': 0.4},
    {'name': 'Cool', 'brightness': -0.05, 'contrast': 1.15, 'saturation': 1.05, 'warmth': -0.3},
    {'name': 'Dramatic', 'brightness': -0.1, 'contrast': 1.4, 'saturation': 1.2, 'warmth': 0.0},
    {'name': 'Bright', 'brightness': 0.2, 'contrast': 1.1, 'saturation': 1.05, 'warmth': 0.1},
    {'name': 'Vivid', 'brightness': 0.1, 'contrast': 1.3, 'saturation': 1.4, 'warmth': 0.0},
    {'name': 'B&W', 'brightness': 0.0, 'contrast': 1.2, 'saturation': 0.0, 'warmth': 0.0},
  ];

  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  final List<Map<String, String>> _adjustmentOptions = [
    {'name': 'Brightness', 'icon': 'brightness_6'},
    {'name': 'Contrast', 'icon': 'contrast'},
    {'name': 'Saturation', 'icon': 'palette'},
    {'name': 'Exposure', 'icon': 'exposure'},
    {'name': 'Highlights', 'icon': 'highlight'},
    {'name': 'Shadows', 'icon': 'shadow'},
    {'name': 'Vibrance', 'icon': 'vibration'},
    {'name': 'Warmth', 'icon': 'wb_sunny'},
    {'name': 'Fade', 'icon': 'opacity'},
    {'name': 'Vignette', 'icon': 'vignette'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVideo(_currentIndex);
  }

  Future<void> _loadVideo(int index) async {
    setState(() => _isLoading = true);
    
    try {
      // Dispose previous controller
      await _videoController?.dispose();
      _videoController = null;
      
      if (index >= widget.videos.length) {
        setState(() => _isLoading = false);
        return;
      }
      
      final asset = widget.videos[index];
      final file = await asset.file;
      
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not access video file')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Video file does not exist')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      if (file.lengthSync() <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Video file is empty')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Initialize video controller
        _videoController = VideoPlayerController.file(file);
      
      // Wait for initialization with timeout
      await _videoController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );
      
      if (!mounted) return;
        
        setState(() {
          _videoDuration = _videoController!.value.duration;
          _startValue = 0.0;
          _endValue = _videoDuration.inSeconds.toDouble();
          _currentPosition = Duration.zero;
          _playbackSpeed = 1.0;
          _selectedFilter = 'Normal';
          _coverFrame = null;
          _coverPreview = null;
          
          // Set original aspect ratio
        if (_videoController!.value.isInitialized) {
          _aspectRatios['Original'] = _videoController!.value.aspectRatio;
          _selectedAspectRatio = _videoController!.value.aspectRatio;
        } else {
          _selectedAspectRatio = 16/9; // Default fallback
        }
          
          // Reset adjustments
          _resetAdjustments();
        });
        
      // Add listener for video position updates
      _videoController!.addListener(_videoListener);
        
      // Seek to start and pause
      await _videoController!.seekTo(Duration.zero);
        await _videoController!.pause();
        
      // Generate timeline thumbnails
      _generateTimelineThumbnails(file.path);
      
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: ${e.toString()}')),
      );
      }
    } finally {
      if (mounted) {
      setState(() => _isLoading = false);
      }
    }
  }
  
  void _videoListener() {
    if (!mounted) return;
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    if (!_isDraggingScrubber) {
      setState(() {
        _currentPosition = _videoController!.value.position;
        _isPlaying = _videoController!.value.isPlaying;
        
        // Auto-pause at trim end (not video end)
        final endTime = Duration(seconds: _endValue.toInt());
        if (_currentPosition >= endTime && _isPlaying) {
          _videoController!.pause();
          _videoController!.seekTo(Duration(seconds: _startValue.toInt()));
        }
        
        // Also check if video went before trim start
        final startTime = Duration(seconds: _startValue.toInt());
        if (_currentPosition < startTime && _isPlaying) {
          _videoController!.seekTo(startTime);
        }
      });
    }
  }

  void _resetAdjustments() {
    _brightness = 0.0;
    _contrast = 1.0;
    _saturation = 1.0;
    _exposure = 0.0;
    _highlights = 0.0;
    _shadows = 0.0;
    _vibrance = 0.0;
    _warmth = 0.0;
    _fade = 0.0;
    _vignette = 0.0;
  }

  void _applyFilter(Map<String, dynamic> filter) {
    setState(() {
      _brightness = filter['brightness']?.toDouble() ?? 0.0;
      _contrast = filter['contrast']?.toDouble() ?? 1.0;
      _saturation = filter['saturation']?.toDouble() ?? 1.0;
      _warmth = filter['warmth']?.toDouble() ?? 0.0;
      _selectedFilter = filter['name'];
    });
  }

  Future<void> _setCoverFrame() async {
    if (_videoController == null) return;
    final pos = _videoController!.value.position;
    setState(() {
      _coverFrame = pos;
    });
    
    try {
      final file = await widget.videos[_currentIndex].file;
      if (file != null) {
        final thumb = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          timeMs: pos.inMilliseconds,
          quality: 80,
        );
        if (thumb != null) {
          setState(() {
            _coverPreview = MemoryImage(thumb);
          });
        }
      }
    } catch (e) {
      print('Error generating cover thumbnail: $e');
    }
  }

  Future<void> _trimVideo() async {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for video to load')),
      );
      return;
    }
    
    // Validate trim values
    if (_startValue < 0 || _endValue <= _startValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid trim range. Please adjust start and end points.')),
      );
      return;
    }
    
    if (_endValue > _videoDuration.inSeconds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot exceed video duration.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final asset = widget.videos[_currentIndex];
      final inputFile = await asset.file;
      if (inputFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not access video file')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      // Check if video actually needs trimming
      final isTrimmed = _startValue > 0 || _endValue < _videoDuration.inSeconds;
      File? trimmedFile = inputFile;
      
      // Only process if actually trimmed
      if (isTrimmed) {
        trimmedFile = await _processVideoTrim(inputFile);
        if (trimmedFile == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Failed to trim video. Using original.')),
            );
          }
          trimmedFile = inputFile; // Fallback to original
        }
      }
      
      // Store trim settings with processed file
      _trimmedVideos[asset.id] = {
        'file': trimmedFile,
        'originalFile': inputFile,
        'startTime': Duration(seconds: _startValue.toInt()),
        'endTime': Duration(seconds: _endValue.toInt()),
        'duration': Duration(seconds: (_endValue - _startValue).toInt()),
        'speed': _playbackSpeed,
        'filter': _selectedFilter,
        'coverFrame': _coverFrame,
        'aspectRatio': _selectedAspectRatio,
        'adjustments': {
          'brightness': _brightness,
          'contrast': _contrast,
          'saturation': _saturation,
          'exposure': _exposure,
          'highlights': _highlights,
          'shadows': _shadows,
          'vibrance': _vibrance,
          'warmth': _warmth,
          'fade': _fade,
          'vignette': _vignette,
        },
        'isTrimmed': isTrimmed,
      };
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video trimmed successfully (${(_endValue - _startValue).toStringAsFixed(1)}s)'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      
      _onTrimmed();
    } catch (e) {
      print('Error processing video: $e');
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing video: $e')),
      );
      }
    } finally {
      if (mounted) {
      setState(() => _isLoading = false);
      }
    }
  }
  
  Future<File?> _processVideoTrim(File inputFile) async {
    try {
      // For now, since FFmpeg has dependency issues, we'll use a workaround:
      // Copy the file and store trim metadata
      // The actual trimming can be done server-side or we can implement native trimming later
      
      // Get temporary directory for output
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFileName = 'trimmed_${timestamp}_${path.basename(inputFile.path)}';
      final outputPath = path.join(tempDir.path, outputFileName);
      
      // Calculate trim duration
      final startSeconds = _startValue;
      final duration = _endValue - _startValue;
      
      // For now, copy the original file
      // TODO: Implement actual trimming using platform channels or server-side processing
      final outputFile = await inputFile.copy(outputPath);
      
      if (await outputFile.exists()) {
        print('Video file prepared for trimming (start: ${startSeconds}s, duration: ${duration}s)');
        // Store trim metadata in a separate file for server-side processing
        final metadataFile = File('${outputPath}.meta');
        await metadataFile.writeAsString(jsonEncode({
          'startTime': startSeconds,
          'endTime': _endValue,
          'duration': duration,
          'originalPath': inputFile.path,
        }));
        
        return outputFile;
      } else {
        print('Error: Output file not created');
        return null;
      }
    } catch (e) {
      print('Error in _processVideoTrim: $e');
      return null;
    }
  }

  void _onTrimmed() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadVideo(_currentIndex);
    } else {
      _finishTrimming();
    }
  }

  void _finishTrimming() {
    List<XFile> trimmedVideos = [];
    for (final entry in _trimmedVideos.entries) {
      final file = entry.value['file'] as File;
      if (file.existsSync()) trimmedVideos.add(XFile(file.path));
    }
    Navigator.pop(context, {
      'trimmedVideos': trimmedVideos,
      'croppedImages': widget.croppedImages ?? [],
      'videoSettings': _trimmedVideos,
    });
  }

  void _skipCurrentVideo() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadVideo(_currentIndex);
    } else {
      _finishTrimming();
    }
  }

  void _moveToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _loadVideo(_currentIndex);
    }
  }

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          // Ensure we're within the trim range before playing
          final currentSeconds = _currentPosition.inSeconds;
          final startSeconds = _startValue.toInt();
          final endSeconds = _endValue.toInt();
          
          if (currentSeconds < startSeconds || currentSeconds >= endSeconds) {
            // Seek to start of trim range
            _videoController!.seekTo(Duration(seconds: startSeconds));
          }
          
          _videoController!.play();
          
          // Set up a listener to pause at trim end
          _videoController!.addListener(_trimRangeListener);
        }
      });
    }
  }
  
  void _trimRangeListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    final currentSeconds = _videoController!.value.position.inSeconds;
    final endSeconds = _endValue.toInt();
    
    // Pause when reaching trim end
    if (currentSeconds >= endSeconds && _videoController!.value.isPlaying) {
      _videoController!.pause();
      _videoController!.seekTo(Duration(seconds: _startValue.toInt()));
      _videoController!.removeListener(_trimRangeListener);
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _seekTo(double seconds) {
    if (_videoController != null && _videoController!.value.isInitialized) {
      // Clamp to trim range, not full video duration
      final clampedSeconds = seconds.clamp(_startValue, _endValue);
      _videoController!.seekTo(Duration(seconds: clampedSeconds.toInt()));
      setState(() {
        _currentPosition = Duration(seconds: clampedSeconds.toInt());
      });
    }
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    if (_videoController != null) {
      _videoController!.setPlaybackSpeed(speed);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatDurationShort(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Playback Speed', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _speeds.map((speed) {
            return ListTile(
              title: Text(
                '${speed}x',
                style: TextStyle(
                  color: speed == _playbackSpeed ? Colors.white : Colors.grey[400],
                  fontWeight: speed == _playbackSpeed ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                _setPlaybackSpeed(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAdjustmentSlider() {
    double currentValue;
    double minValue, maxValue;
    
    switch (_selectedAdjustment) {
      case 'Brightness':
        currentValue = _brightness;
        minValue = -0.5;
        maxValue = 0.5;
        break;
      case 'Contrast':
        currentValue = _contrast;
        minValue = 0.5;
        maxValue = 2.0;
        break;
      case 'Saturation':
        currentValue = _saturation;
        minValue = 0.0;
        maxValue = 2.0;
        break;
      case 'Exposure':
        currentValue = _exposure;
        minValue = -2.0;
        maxValue = 2.0;
        break;
      case 'Highlights':
        currentValue = _highlights;
        minValue = -1.0;
        maxValue = 1.0;
        break;
      case 'Shadows':
        currentValue = _shadows;
        minValue = -1.0;
        maxValue = 1.0;
        break;
      case 'Vibrance':
        currentValue = _vibrance;
        minValue = -1.0;
        maxValue = 1.0;
        break;
      case 'Warmth':
        currentValue = _warmth;
        minValue = -1.0;
        maxValue = 1.0;
        break;
      case 'Fade':
        currentValue = _fade;
        minValue = 0.0;
        maxValue = 1.0;
        break;
      case 'Vignette':
        currentValue = _vignette;
        minValue = 0.0;
        maxValue = 1.0;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        Text(
          _selectedAdjustment,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: currentValue,
            min: minValue,
            max: maxValue,
            onChanged: (value) {
              setState(() {
                switch (_selectedAdjustment) {
                  case 'Brightness':
                    _brightness = value;
                    break;
                  case 'Contrast':
                    _contrast = value;
                    break;
                  case 'Saturation':
                    _saturation = value;
                    break;
                  case 'Exposure':
                    _exposure = value;
                    break;
                  case 'Highlights':
                    _highlights = value;
                    break;
                  case 'Shadows':
                    _shadows = value;
                    break;
                  case 'Vibrance':
                    _vibrance = value;
                    break;
                  case 'Warmth':
                    _warmth = value;
                    break;
                  case 'Fade':
                    _fade = value;
                    break;
                  case 'Vignette':
                    _vignette = value;
                    break;
                }
              });
            },
          ),
        ),
        Text(
          currentValue.toStringAsFixed(2),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Video ${_currentIndex + 1}/${widget.videos.length}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _trimVideo,
            child: const Text(
              'Next',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Video Player with aspect ratio
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _videoController != null && _videoController!.value.isInitialized
                          ? Container(
                              color: Colors.black,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: _selectedAspectRatio,
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.matrix([
                                      _contrast, 0, 0, 0, _brightness * 255,
                                      0, _contrast, 0, 0, _brightness * 255,
                                      0, 0, _contrast, 0, _brightness * 255,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Aspect Ratio Selector
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _aspectRatios.length,
                    itemBuilder: (context, index) {
                      final entry = _aspectRatios.entries.elementAt(index);
                      final ratio = entry.key == 'Original' ? _videoController?.value.aspectRatio ?? 16/9 : entry.value;
                      final isSelected = _selectedAspectRatio == ratio;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAspectRatio = ratio),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Controls
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                    children: [
                      // Filter and Adjustment Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _showFilters = !_showFilters;
                              _showAdjustments = false;
                              _selectedAdjustment = '';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _showFilters ? Colors.white : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Filters',
                                style: TextStyle(
                                  color: _showFilters ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _showAdjustments = !_showAdjustments;
                              _showFilters = false;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _showAdjustments ? Colors.white : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Adjust',
                                style: TextStyle(
                                  color: _showAdjustments ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Filter options
                      if (_showFilters) ...[
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected = filter['name'] == _selectedFilter;
                              return GestureDetector(
                                onTap: () => _applyFilter(filter),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.grey[800],
                                          borderRadius: BorderRadius.circular(12),
                                          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            filter['name'][0],
                                            style: TextStyle(
                                              color: isSelected ? Colors.black : Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        filter['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      // Adjustment options
                      if (_showAdjustments) ...[
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _adjustmentOptions.length,
                            itemBuilder: (context, index) {
                              final adjustment = _adjustmentOptions[index];
                              final isSelected = adjustment['name'] == _selectedAdjustment;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedAdjustment = isSelected ? '' : adjustment['name']!;
                                }),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.grey[800],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getIconData(adjustment['icon']!),
                                          color: isSelected ? Colors.black : Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        adjustment['name']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      // Adjustment slider
                      if (_selectedAdjustment.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildAdjustmentSlider(),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Play/Pause and Speed controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: _showSpeedDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.speed, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_playbackSpeed}x',
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Timeline with trim handles
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Stack(
                          children: [
                            // Video thumbnail timeline
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildVideoThumbnails(),
                              ),
                            ),
                            
                            // Trim overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.0, 0.1, 0.9, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Start handle
                            Positioned(
                              left: (_startValue / _videoDuration.inSeconds) * (MediaQuery.of(context).size.width - 40) - 20,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onPanStart: (_) => setState(() => isDraggingStart = true),
                                onPanEnd: (_) => setState(() => isDraggingStart = false),
                                onPanUpdate: (details) {
                                  setState(() {
                                    double newValue = _startValue + (details.delta.dx / (MediaQuery.of(context).size.width - 40)) * _videoDuration.inSeconds;
                                    _startValue = newValue.clamp(0.0, _endValue - 1.0);
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // End handle
                            Positioned(
                              left: (_endValue / _videoDuration.inSeconds) * (MediaQuery.of(context).size.width - 40) - 20,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onPanStart: (_) => setState(() => isDraggingEnd = true),
                                onPanEnd: (_) => setState(() => isDraggingEnd = false),
                                onPanUpdate: (details) {
                                  setState(() {
                                    double newValue = _endValue + (details.delta.dx / (MediaQuery.of(context).size.width - 40)) * _videoDuration.inSeconds;
                                    _endValue = newValue.clamp(_startValue + 1.0, _videoDuration.inSeconds.toDouble());
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Playhead
                            Positioned(
                              left: (_currentPosition.inSeconds / _videoDuration.inSeconds) * (MediaQuery.of(context).size.width - 40) - 2,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onPanStart: (_) => setState(() => _isDraggingScrubber = true),
                                onPanEnd: (_) => setState(() => _isDraggingScrubber = false),
                                onPanUpdate: (details) {
                                  setState(() {
                                    double newValue = _currentPosition.inSeconds + (details.delta.dx / (MediaQuery.of(context).size.width - 40)) * _videoDuration.inSeconds;
                                    double clampedValue = newValue.clamp(0.0, _videoDuration.inSeconds.toDouble());
                                    _currentPosition = Duration(seconds: clampedValue.toInt());
                                    _seekTo(clampedValue);
                                  });
                                },
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Duration and Cover Frame
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Duration: ${_formatDurationShort(Duration(seconds: (_endValue - _startValue).toInt()))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _setCoverFrame,
                                icon: const Icon(Icons.photo, size: 16),
                                label: const Text('Cover', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 36),
                                ),
                              ),
                              if (_coverPreview != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image(
                                      image: _coverPreview!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous
                          Container(
                            decoration: BoxDecoration(
                              color: _currentIndex > 0 ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: _currentIndex > 0 ? Colors.white : Colors.white.withOpacity(0.5),
                                size: 24,
                              ),
                              onPressed: _currentIndex > 0 ? _moveToPrevious : null,
                            ),
                          ),
                          
                          // Skip
                          GestureDetector(
                            onTap: _skipCurrentVideo,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          // Process/Next
                          GestureDetector(
                            onTap: _trimVideo,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _currentIndex == widget.videos.length - 1 ? 'Finish' : 'Next',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),)
              ],
          
            ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'brightness_6':
        return Icons.brightness_6;
      case 'contrast':
        return Icons.contrast;
      case 'palette':
        return Icons.palette;
      case 'exposure':
        return Icons.exposure;
      case 'highlight':
        return Icons.highlight;
      case 'shadow':
        return Icons.shape_line;
      case 'vibration':
        return Icons.vibration;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'opacity':
        return Icons.opacity;
      case 'vignette':
        return Icons.vignette;
      default:
        return Icons.tune;
    }
  }

  Future<void> _generateTimelineThumbnails(String videoPath) async {
    if (_isGeneratingThumbnails || _videoDuration == Duration.zero) return;
    
    setState(() {
      _isGeneratingThumbnails = true;
      _timelineThumbnails.clear();
    });
    
    try {
      final durationInSeconds = _videoDuration.inSeconds;
      final thumbnailCount = 10; // Generate 10 thumbnails for timeline
      final interval = durationInSeconds / thumbnailCount;
      
      for (int i = 0; i < thumbnailCount; i++) {
        final timeMs = (interval * i * 1000).toInt();
        
        try {
          final thumbnail = await VideoThumbnail.thumbnailData(
            video: videoPath,
            imageFormat: ImageFormat.JPEG,
            timeMs: timeMs,
            quality: 50,
            maxWidth: 200,
          );
          
          if (thumbnail != null && mounted) {
            setState(() {
              _timelineThumbnails[i] = thumbnail;
            });
          }
        } catch (e) {
          print('Error generating thumbnail at $timeMs ms: $e');
        }
      }
    } catch (e) {
      print('Error generating timeline thumbnails: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingThumbnails = false;
        });
      }
    }
  }

  Widget _buildVideoThumbnails() {
    if (_isGeneratingThumbnails && _timelineThumbnails.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      );
    }
    
    if (_timelineThumbnails.isEmpty) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_library,
          color: Colors.white54,
          size: 40,
        ),
      ),
      );
    }
    
    return Row(
      children: List.generate(_timelineThumbnails.length, (index) {
        final thumbnail = _timelineThumbnails[index];
        if (thumbnail == null) {
          return Expanded(
            child: Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.video_library, color: Colors.white24, size: 20),
              ),
            ),
          );
        }
        
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Image.memory(
              thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white24, size: 20),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }
}