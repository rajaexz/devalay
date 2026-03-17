// To parse this JSON data, do
//
//     final avatarModel = avatarModelFromJson(jsonString);
import 'dart:convert';

List<AvatarModel> avatarModelFromJson(String str) => List<AvatarModel>.from(json.decode(str).map((x) => AvatarModel.fromJson(x)));

String avatarModelToJson(List<AvatarModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AvatarModel {
  int? id;
  String? title;
  String? subtitle;
  Images? images;
  bool? liked;
  int? likedCount;

  AvatarModel({
     this.id,
     this.title,
     this.subtitle,
     this.images,
     this.liked,
     this.likedCount,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) => AvatarModel(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    images: Images.fromJson(json["images"]),
    liked: json["liked"],
    likedCount: json["liked_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subtitle": subtitle,
    "images": images?.toJson(),
    "liked": liked,
    "liked_count": likedCount,
  };
}

class Images {
  List<Banner> banner;

  Images({
    required this.banner,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
    banner: List<Banner>.from(json["Banner"].map((x) => Banner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Banner": List<dynamic>.from(banner.map((x) => x.toJson())),
  };
}

class Banner {
  int? id;
  String? imageType;
  String? image;
  bool? approved;

  Banner({
     this.id,
     this.imageType,
     this.image,
     this.approved,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json["id"],
    imageType: json["image_type"],
    image: json["image"],
    approved: json["approved"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_type": imageType,
    "image": image,
    "approved": approved,
  };
}
