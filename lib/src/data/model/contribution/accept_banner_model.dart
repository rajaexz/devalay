// To parse this JSON data, do
//
//     final acceptBannerModel = acceptBannerModelFromJson(jsonString);

import 'dart:convert';

AcceptBannerModel acceptBannerModelFromJson(String str) => AcceptBannerModel.fromJson(json.decode(str));

String acceptBannerModelToJson(AcceptBannerModel data) => json.encode(data.toJson());

class AcceptBannerModel {
  int? id;
  String? imageType;
  String? image;
  bool? approved;
  String? createdAt;
  String? updatedAt;
  int? addedBy;
  int? devalay;

  AcceptBannerModel({
    this.id,
    this.imageType,
    this.image,
    this.approved,
    this.createdAt,
    this.updatedAt,
    this.addedBy,
    this.devalay,
  });

  factory AcceptBannerModel.fromJson(Map<String, dynamic> json) => AcceptBannerModel(
    id: json["id"],
    imageType: json["image_type"],
    image: json["image"],
    approved: json["approved"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    addedBy: json["added_by"],
    devalay: json["devalay"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_type": imageType,
    "image": image,
    "approved": approved,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "added_by": addedBy,
    "devalay": devalay,
  };
}
