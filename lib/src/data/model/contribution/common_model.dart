// To parse this JSON data, do
//
//     final commonModel = commonModelFromJson(jsonString);

import 'dart:convert';

CommonModel commonModelFromJson(String str) =>
    CommonModel.fromJson(json.decode(str));

String commonModelToJson(CommonModel data) => json.encode(data.toJson());

class CommonModel {
  int? id;
  Dev? dev;
  dynamic image;
  bool? approved;

  CommonModel({
    this.id,
    this.dev,
    this.image,
    this.approved,
  });

  factory CommonModel.fromJson(Map<String, dynamic> json) => CommonModel(
        id: json["id"],
        dev: json["dev"] == null ? null : Dev.fromJson(json["dev"]),
        image: json["image"],
        approved: json["approved"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dev": dev?.toJson(),
        "image": image,
        "approved": approved,
      };
}

class Dev {
  int? id;
  String? title;

  Dev({
    this.id,
    this.title,
  });

  factory Dev.fromJson(Map<String, dynamic> json) => Dev(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
