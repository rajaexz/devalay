import 'package:flutter/material.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';

class ImageTag {
  final String type;
  final Result result;
  final Offset position;

  ImageTag({
    required this.type,
    required this.result,
    required this.position,
  });
} 