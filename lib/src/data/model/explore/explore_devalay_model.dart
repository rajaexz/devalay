// To parse this JSON data, do
//
//     final exploreDevalayModel = exploreDevalayModelFromJson(jsonString);

import 'dart:convert';

List<ExploreDevalayModel> exploreDevalayModelFromJson(String str) => List<ExploreDevalayModel>.from(json.decode(str).map((x) => ExploreDevalayModel.fromJson(x)));

String exploreDevalayModelToJson(List<ExploreDevalayModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExploreDevalayModel {
    int? id;
    String? title;
    String? subtitle;
    Images? images;
    bool? liked;
    bool? saved;
    int? likedCount;
    int? savedCount;
    int? viewedCount;
    String? city;
    String? address;
    String? description;
    String? legend;
    String? etymology;
    String? templeHistory;
    String? architecture;
    GovernedBy? governedBy;

    ExploreDevalayModel({
        this.id,
        this.title,
        this.subtitle,
        this.images,
        this.liked,
        this.saved,
        this.likedCount,
        this.savedCount,
        this.viewedCount,
        this.city,
        this.address,
        this.description,
        this.legend,
        this.etymology,
        this.templeHistory,
        this.architecture,
        this.governedBy
    });

    factory ExploreDevalayModel.fromJson(Map<String, dynamic> json) => ExploreDevalayModel(
        id: json["id"],
        title: json["title"],
        subtitle: json["subtitle"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        liked: json["liked"],
        saved: json["saved"],
        likedCount: json["liked_count"],
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
        city: json['city'],
        address: json['address'],
        description: json['description'],
        legend: json['legend'],
        etymology: json['etymology'],
        templeHistory: json['templeHistory'],
        architecture: json['architecture'],
        governedBy: json["governed_by"] == null
            ? null
            : GovernedBy.fromJson(json["governed_by"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "subtitle": subtitle,
        "images": images?.toJson(),
        "liked": liked,
        "saved": saved,
        "liked_count": likedCount,
        "saved_count": savedCount,
        "viewed_count": viewedCount,
        "city": city,
        "address": address,
        "description": description,
        "legend": legend,
        "etymology": etymology,
        "templeHistory": templeHistory,
        "architecture": architecture,
        "governed_by": governedBy?.toJson(),
    };
    ExploreDevalayModel copyWith({
  int? id,
  String? title,
  bool? liked,
  int? likedCount,
  // Add other fields you might need to copy
  Images? images,
}) {
  return ExploreDevalayModel(
    id: id ?? this.id,
    title: title ?? this.title,
    liked: liked ?? this.liked,
    likedCount: likedCount ?? this.likedCount,
    images: images ?? this.images,
    // Copy other fields as needed
  );
}
}

class Images {
    List<Banner>? banner;

    Images({
        this.banner,
    });

    factory Images.fromJson(Map<String, dynamic> json) => Images(
        banner: json["Banner"] == null ? [] : List<Banner>.from(json["Banner"]!.map((x) => Banner.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
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

class GovernedBy {
    int? id;
    String? description;
    bool? approved;
    bool? verified;
    bool? superpower;

    List<int>? governer;

    GovernedBy({
        this.id,
        this.description,
        this.approved,
        this.verified,
        this.superpower,
        this.governer,
    });

    factory GovernedBy.fromJson(Map<String, dynamic> json) => GovernedBy(
        id: json["id"],
        description: json["description"],
        approved: json["approved"],
        verified: json["verified"],
        superpower: json["superpower"],
        governer: json["governer"] == null
            ? []
            : List<int>.from(json["governer"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "approved": approved,
        "verified": verified,
        "superpower": superpower,
        "governer":
        governer == null ? [] : List<dynamic>.from(governer!.map((x) => x)),
    };
}