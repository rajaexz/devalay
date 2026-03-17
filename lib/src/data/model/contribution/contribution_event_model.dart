// To parse this JSON data, do
//
//     final contributionEventModel = contributionEventModelFromJson(jsonString);

import 'dart:convert';

List<ContributionEventModel> contributionEventModelFromJson(String str) => List<ContributionEventModel>.from(json.decode(str).map((x) => ContributionEventModel.fromJson(x)));

String contributionEventModelToJson(List<ContributionEventModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContributionEventModel {
  int? id;
  ContributionEventModelImages? images;
  String? title;
    String? steps;
  String? subtitle;
  String? description;
  String? howToCelebrate;
  String? dos;
  String? donts;
  String? address;
  String? city;
  String? state;
  String? country;
  String? landmark;
  String? nearestAirport;
  String? nearestRailway;
  String? googleMapLink;
  bool? approved;
  bool? rejected;
  RejectReasons? rejectReasons;
  bool? draft;
  String? createdAt;
  String? updatedAt;
  Devalay? devalay;
  int? addedBy;
  List<Dev>? devs;
  bool? liked;
  bool? saved;
  int? likedCount;
  List<Date>? dates;

  ContributionEventModel({
    this.id,
    this.images,
    this.title,
    this.subtitle,
    this.description,
    this.howToCelebrate,
    this.dos,
    this.donts,
    this.address,
    this.city,
    this.state,
    this.country,
    this.landmark,
    this.nearestAirport,
    this.nearestRailway,
    this.googleMapLink,
    this.approved,
    this.rejected,
    this.rejectReasons,
    this.draft,
    this.createdAt,
    this.updatedAt,
    this.devalay,
    this.addedBy,
    this.devs,
    this.steps,
    this.liked,
    this.saved,
    this.likedCount,
    this.dates,
  });

  factory ContributionEventModel.fromJson(Map<String, dynamic> json) => ContributionEventModel(
    id: json["id"],
    images: json["images"] == null ? null : ContributionEventModelImages.fromJson(json["images"]),
    title: json["title"],
    subtitle: json["subtitle"],
    description: json["description"],
    howToCelebrate: json["how_to_celebrate"],
    dos: json["dos"],
    steps:json["steps"] ?? " ",
    donts: json["donts"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    landmark: json["landmark"],
    nearestAirport: json["nearest_airport"],
    nearestRailway: json["nearest_railway"],
    googleMapLink: json["google_map_link"],
    approved: json["approved"],
    rejected: json["rejected"],
    rejectReasons: json["reject_reasons"] == null ? null : RejectReasons.fromJson(json["reject_reasons"]),
    draft: json["draft"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    devalay: json["devalay"] == null ? null : Devalay.fromJson(json["devalay"]),
    addedBy: json["added_by"],
    devs: json["devs"] == null ? [] : List<Dev>.from(json["devs"]!.map((x) => Dev.fromJson(x))),
    liked: json["liked"],
    saved: json["saved"],
    likedCount: json["liked_count"],
    dates: json["dates"] == null ? [] : List<Date>.from(json["dates"]!.map((x) => Date.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "images": images?.toJson(),
    "title": title,
    "subtitle": subtitle,
    "description": description,
    "how_to_celebrate": howToCelebrate,
    "dos": dos,
    "donts": donts,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "landmark": landmark,
    "nearest_airport": nearestAirport,
    "nearest_railway": nearestRailway,
    "google_map_link": googleMapLink,
    "approved": approved,
    "rejected": rejected,
    "reject_reasons": rejectReasons?.toJson(),
    "draft": draft,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "devalay": devalay?.toJson(),
    "added_by": addedBy,
    "devs": devs == null ? [] : List<dynamic>.from(devs!.map((x) => x.toJson())),
    "liked": liked,
    "saved": saved,
    "liked_count": likedCount,
    "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x.toJson())),
  };
}

class Date {
  int? id;
  DateTime? startDate;
  String? startTime;
  DateTime? endDate;
  dynamic endTime;

  Date({
    this.id,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });

  factory Date.fromJson(Map<String, dynamic> json) => Date(
    id: json["id"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    startTime: json["start_time"],
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    endTime: json["end_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "end_time": endTime,
  };
}

class Devalay {
  int? id;
  String? title;

  Devalay({
    this.id,
    this.title,
  });

  factory Devalay.fromJson(Map<String, dynamic> json) => Devalay(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}

class Dev {
  int? id;
  String? title;
  String? subtitle;
  DevImages? images;
  bool? liked;
  int? likedCount;

  Dev({
    this.id,
    this.title,
    this.subtitle,
    this.images,
    this.liked,
    this.likedCount,
  });

  factory Dev.fromJson(Map<String, dynamic> json) => Dev(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    images: json["images"] == null ? null : DevImages.fromJson(json["images"]),
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

class DevImages {
  List<Banner>? banner;

  DevImages({
    this.banner,
  });

  factory DevImages.fromJson(Map<String, dynamic> json) => DevImages(
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

class ContributionEventModelImages {
  List<Banner>? gallery;
  List<Banner>? banner;

  ContributionEventModelImages({
    this.gallery,
    this.banner,
  });

  factory ContributionEventModelImages.fromJson(Map<String, dynamic> json) => ContributionEventModelImages(
    gallery: json["Gallery"] == null ? [] : List<Banner>.from(json["Gallery"]!.map((x) => Banner.fromJson(x))),
    banner: json["Banner"] == null ? [] : List<Banner>.from(json["Banner"]!.map((x) => Banner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x.toJson())),
    "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x.toJson())),
  };
}

class RejectReasons {
  RejectReasons();

  factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons(
  );

  Map<String, dynamic> toJson() => {
  };
}
