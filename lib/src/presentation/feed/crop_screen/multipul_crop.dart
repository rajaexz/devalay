import 'dart:io';
import 'dart:typed_data';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devalay_app/src/presentation/core/widget/feed_appBar.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pro_image_editor/pro_image_editor.dart';

class MultipleCropScreen extends StatefulWidget {
  final List<AssetEntity> assets;
  final List<AssetEntity> videosToKeep;

  const MultipleCropScreen({
    super.key,
    required this.assets,
    this.videosToKeep = const [],
  });

  @override
  _MultipleCropScreenState createState() => _MultipleCropScreenState();
}

class _MultipleCropScreenState extends State<MultipleCropScreen> {
  int _currentIndex = 0;
  final Map<String, XFile> _croppedImages = {};
  final Map<String, File> _imageFiles = {};
  bool _isLoading = false;

  final String _selectedAspectRatio = "Original";

  @override
  void initState() {
    super.initState();
    _loadFirstImage();
  }

  Future<void> _loadFirstImage() async {
    if (widget.assets.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _preloadImage(0);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print("Error loading first image: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _preloadImage(int index) async {
    if (index >= 0 && index < widget.assets.length) {
      final asset = widget.assets[index];
      if (!_imageFiles.containsKey(asset.id)) {
        final file = await asset.file;
        if (file != null) {
          _imageFiles[asset.id] = file;
        }
      }
    }
  }

  Future<void> _cropCurrentImage() async {
    if (_currentIndex < 0 || _currentIndex >= widget.assets.length) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final asset = widget.assets[_currentIndex];
      final file = _imageFiles[asset.id];

      if (file != null) {
        // Navigate to ProImageEditor
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProImageEditor.file(
              file,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (Uint8List bytes) async {
                  Navigator.pop(context, bytes);
                },
              ),
              configs: const ProImageEditorConfigs(
                cropRotateEditorConfigs: CropRotateEditorConfigs(),
                designMode: ImageEditorDesignModeE.material,
                helperLines: HelperLines(
                  showVerticalLine: true,
                  showHorizontalLine: true,
                  showRotateLine: true,
                ),
                           ),
            ),
          ),
        );

        if (result != null) {
          // Save the edited image
          final editedFile = await _saveEditedImage(result);
          if (editedFile != null) {
            _croppedImages[asset.id] = XFile(editedFile.path);

            if (widget.assets.length == 1) {
              _finishCropping();
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Image ${_currentIndex + 1} cropped")),
            );

            if (_currentIndex < widget.assets.length - 1) {
              await _moveToNext();
            } else {
              _finishCropping();
            }
          }
        } else {
          if (widget.assets.length == 1) {
            Navigator.pop(context);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cropping canceled")),
          );
        }
      }
    } catch (e) {
      print("Error cropping image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cropping image: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File?> _saveEditedImage(Uint8List imageData) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName =
          'edited_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(imageData);
      return file;
    } catch (e) {
      print("Error saving edited image: $e");
      return null;
    }
  }

  Future<void> _skipCurrentImage() async {
    if (_currentIndex < widget.assets.length - 1) {
      await _moveToNext();
    } else {
      _finishCropping();
    }
  }

  Future<void> _moveToNext() async {
    if (_currentIndex < widget.assets.length - 1) {
      final nextIndex = _currentIndex + 1;

      await _preloadImage(nextIndex);

      setState(() {
        _currentIndex = nextIndex;
      });
    }
  }

  Future<void> _moveToPrevious() async {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex = _currentIndex - 1;
      });
    }
  }

  void _finishCropping() async {
    List<XFile> finalFiles = [];
    for (final asset in widget.assets) {
      if (_croppedImages.containsKey(asset.id)) {
        finalFiles.add(_croppedImages[asset.id]!);
      } else {
        final file = await asset.file;
        if (file != null) finalFiles.add(XFile(file.path));
      }
    }
    if (!mounted) return;
    Navigator.pop(context, finalFiles); // <-- Return only cropped images
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No images to crop")),
      );
    }

    final asset = widget.assets[_currentIndex];
    final hasFile = _imageFiles.containsKey(asset.id);

    return Scaffold(
      appBar: SimpleAppBar(
        brandName:
            "${StringConstant.cropImage} ${_currentIndex + 1}/${widget.assets.length}",
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _finishCropping,
            tooltip: "Finish",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CustomLottieLoader())
          : Column(
              children: [
                Expanded(
                  child: hasFile
                      ? Center(
                          child: Image.file(
                            _imageFiles[asset.id]!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(child: CustomLottieLoader()),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _currentIndex > 0 ? _moveToPrevious : null,
                        tooltip: StringConstant.previous,
                      ),
                      CustomButton(
                        mypadding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        btnColor: AppColor.appbarBgColor2,
                        onTap: _cropCurrentImage,
                        buttonAssets: '',
                        textButton: 'Edit Image',
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _skipCurrentImage,
                        tooltip: StringConstant.skip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
