// To parse this JSON data, do
//
//     final contributionPujaModel = contributionPujaModelFromJson(jsonString);

import 'dart:convert';

List<ContributionPujaModel> contributionPujaModelFromJson(String str) => List<ContributionPujaModel>.from(json.decode(str).map((x) => ContributionPujaModel.fromJson(x)));

String contributionPujaModelToJson(List<ContributionPujaModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Dev {
  final int? id;
  final String? title;
  final String? image;

  Dev({
    this.id,
    this.title,
    this.image,
  });

  factory Dev.fromJson(Map<String, dynamic> json) => Dev(
    id: json["id"],
    title: json["title"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
  };
}

class ContributionPujaModel {
  int? id;
  Images? images;
  Procedure? purpose;
  Procedure? procedure;
  String? title;
  String? subtitle;
  String? description;
  bool? approved;
  bool? rejected;
  RejectReasons? rejectReasons;
  bool? draft;
  String? createdAt;
  String? updatedAt;
  int? addedBy;
  List<Dev>? devs;
  bool? liked;
  bool? saved;
  int? likedCount;

  ContributionPujaModel({
    this.id,
    this.images,
    this.purpose,
    this.procedure,
    this.title,
    this.subtitle,
    this.description,
    this.approved,
    this.rejected,
    this.rejectReasons,
    this.draft,
    this.createdAt,
    this.updatedAt,
    this.addedBy,
    this.devs,
    this.liked,
    this.saved,
    this.likedCount,
  });

  factory ContributionPujaModel.fromJson(Map<String, dynamic> json) => ContributionPujaModel(
    id: json["id"],
    images: json["images"] == null ? null : Images.fromJson(json["images"]),
    purpose: json["purpose"] == null ? null : Procedure.fromJson(json["purpose"]),
    procedure: json["procedure"] == null ? null : Procedure.fromJson(json["procedure"]),
    title: json["title"],
    subtitle: json["subtitle"],
    description: json["description"],
    approved: json["approved"],
    rejected: json["rejected"],
    rejectReasons: json["reject_reasons"] == null ? null : RejectReasons.fromJson(json["reject_reasons"]),
    draft: json["draft"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    addedBy: json["added_by"],
    devs: json["devs"] == null ? [] : List<Dev>.from(json["devs"]!.map((x) => Dev.fromJson(x))),
    liked: json["liked"],
    saved: json["saved"],
    likedCount: json["liked_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "images": images?.toJson(),
    "purpose": purpose?.toJson(),
    "procedure": procedure?.toJson(),
    "title": title,
    "subtitle": subtitle,
    "description": description,
    "approved": approved,
    "rejected": rejected,
    "reject_reasons": rejectReasons?.toJson(),
    "draft": draft,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "added_by": addedBy,
    "devs": devs == null ? [] : List<dynamic>.from(devs!.map((x) => x.toJson())),
    "liked": liked,
    "saved": saved,
    "liked_count": likedCount,
  };
}

class Images {
  List<Banner>? gallery;
  List<Banner>? banner;

  Images({
    this.gallery,
    this.banner,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
    gallery: json["Gallery"] == null ? [] : List<Banner>.from(json["Gallery"]!.map((x) => Banner.fromJson(x))),
    banner: json["Banner"] == null ? [] : List<Banner>.from(json["Banner"]!.map((x) => Banner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x.toJson())),
    "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x.toJson())),
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

class Procedure {
  String? delta;
  String? html;

  Procedure({
    this.delta,
    this.html,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) => Procedure(
    delta: json["delta"],
    html: json["html"],
  );

  Map<String, dynamic> toJson() => {
    "delta": delta,
    "html": html,
  };
}

class RejectReasons {
  RejectReasons();

  factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons(
  );

  Map<String, dynamic> toJson() => {
  };
}
