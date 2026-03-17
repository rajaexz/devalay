// To parse this JSON data, do
//
//     final singleDevalyModel = singleDevalyModelFromJson(jsonString);

import 'dart:convert';

SingleDevalyModel singleDevalyModelFromJson(String str) =>
    SingleDevalyModel.fromJson(json.decode(str));

String singleDevalyModelToJson(SingleDevalyModel data) =>
    json.encode(data.toJson());

class SingleDevalyModel {
  int? id;
  Images? images;
  List<DevElement>? devs;
  String? title;
  String? subtitle;
  String? description;
  String? address;
  String? city;
  String? state;
  String? country;
  String? nearestAirport;
  String? nearestRailway;
  String? landmark;
  String? googleMapLink;
  String? metatags;
  String? legend;
  String? architecture;
  String? etymology;
  String? templeHistory;
  dynamic website;
  bool? approved;
  bool? rejected;
  RejectReasons? rejectReasons;
  bool? draft;
  String? createdAt;
  String? updatedAt;
  GovernedBy? governedBy;
  AddedBy? addedBy;
  bool? liked;
  bool? saved;
  List<dynamic>? approvedBy;
  List<dynamic>? rejectedBy;
  int? likedCount;
  int? savedCount;
  int? viewedCount;

  SingleDevalyModel(
      {this.id,
      this.images,
      this.devs,
      this.title,
      this.subtitle,
      this.description,
      this.address,
      this.city,
      this.state,
      this.country,
      this.nearestAirport,
      this.nearestRailway,
      this.landmark,
      this.googleMapLink,
      this.metatags,
      this.legend,
      this.architecture,
      this.etymology,
      this.templeHistory,
      this.website,
      this.approved,
      this.rejected,
      this.rejectReasons,
      this.draft,
      this.createdAt,
      this.updatedAt,
      this.governedBy,
      this.addedBy,
      this.liked,
      this.saved,
      this.approvedBy,
      this.rejectedBy,
      this.likedCount,
      this.savedCount,
      this.viewedCount,
      });

  factory SingleDevalyModel.fromJson(Map<String, dynamic> json) =>
      SingleDevalyModel(
        id: json["id"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        devs: json["devs"] == null
            ? []
            : List<DevElement>.from(
                json["devs"]!.map((x) => DevElement.fromJson(x))),
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        nearestAirport: json["nearest_airport"],
        nearestRailway: json["nearest_railway"],
        landmark: json["landmark"],
        googleMapLink: json["google_map_link"],
        metatags: json["metatags"],
        legend: json["legend"],
        architecture: json["architecture"],
        etymology: json["etymology"],
        templeHistory: json["temple_history"],
        website: json["website"],
        approved: json["approved"],
        rejected: json["rejected"],
        rejectReasons: json["reject_reasons"] == null
            ? null
            : RejectReasons.fromJson(json["reject_reasons"]),
        draft: json["draft"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        governedBy: json["governed_by"] == null
            ? null
            : GovernedBy.fromJson(json["governed_by"]),
        addedBy: json["added_by"] == null
            ? null
            : AddedBy.fromJson(json["added_by"]),
        liked: json["liked"],
        saved: json["saved"],
        approvedBy: json["approved_by"] == null
            ? []
            : List<dynamic>.from(json["approved_by"]!.map((x) => x)),
        rejectedBy: json["rejected_by"] == null
            ? []
            : List<dynamic>.from(json["rejected_by"]!.map((x) => x)),
        likedCount: json["liked_count"],
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "images": images?.toJson(),
        "devs": devs == null
            ? []
            : List<dynamic>.from(devs!.map((x) => x.toJson())),
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "nearest_airport": nearestAirport,
        "nearest_railway": nearestRailway,
        "landmark": landmark,
        "google_map_link": googleMapLink,
        "metatags": metatags,
        "legend": legend,
        "architecture": architecture,
        "etymology": etymology,
        "temple_history": templeHistory,
        "website": website,
        "approved": approved,
        "rejected": rejected,
        "reject_reasons": rejectReasons?.toJson(),
        "draft": draft,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "governed_by": governedBy?.toJson(),
        "added_by": addedBy?.toJson(),
        "liked": liked,
        "saved": saved,
        "approved_by": approvedBy == null
            ? []
            : List<dynamic>.from(approvedBy!.map((x) => x)),
        "rejected_by": rejectedBy == null
            ? []
            : List<dynamic>.from(rejectedBy!.map((x) => x)),
        "liked_count": likedCount,
        "saved_count": savedCount,
        "viewed_count": viewedCount,
      };
}

class AddedBy {
  int? id;
  String? name;
  String? username;
  String? email;
  String? profilePic;
  dynamic bio;

  AddedBy({
    this.id,
    this.name,
    this.username,
    this.email,
    this.profilePic,
    this.bio,
  });

  factory AddedBy.fromJson(Map<String, dynamic> json) => AddedBy(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        profilePic: json["profile_pic"],
        bio: json["bio"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "email": email,
        "profile_pic": profilePic,
        "bio": bio,
      };
}

class DevElement {
  int? id;
  DevDev? dev;
  String? image;

  bool? approved;
  String? imageType;

  DevElement({
    this.id,
    this.dev,
    this.image,
    this.approved,
    this.imageType,
  });

  factory DevElement.fromJson(Map<String, dynamic> json) => DevElement(
        id: json["id"],
        dev: json["dev"] == null ? null : DevDev.fromJson(json["dev"]),
        image: json["image"],
        approved: json["approved"],
        imageType: json["image_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dev": dev?.toJson(),
        "image": image,
        "approved": approved,
        "image_type": imageType,
      };
}

class DevDev {
  int? id;
  String? title;
  String? count;
  DevDev({
    this.id,
    this.title,
    this.count,
  });

  factory DevDev.fromJson(Map<String, dynamic> json) => DevDev(
        id: json["id"],
        count: json["count"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "count": count,
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

class Images {
  List<DevElement>? gallery;
  List<DevElement>? banner;

  Images({
    this.gallery,
    this.banner,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        gallery: json["Gallery"] == null
            ? []
            : List<DevElement>.from(
                json["Gallery"]!.map((x) => DevElement.fromJson(x))),
        banner: json["Banner"] == null
            ? []
            : List<DevElement>.from(
                json["Banner"]!.map((x) => DevElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Gallery": gallery == null
            ? []
            : List<dynamic>.from(gallery!.map((x) => x.toJson())),
        "Banner": banner == null
            ? []
            : List<dynamic>.from(banner!.map((x) => x.toJson())),
      };
}

class RejectReasons {
  RejectReasons();

  factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons();

  Map<String, dynamic> toJson() => {};
}
