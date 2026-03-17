// To parse this JSON data, do
//
//     final contributionFestivalModel = contributionFestivalModelFromJson(jsonString);

import 'dart:convert';

List<ContributionFestivalModel> contributionFestivalModelFromJson(String str) =>
    List<ContributionFestivalModel>.from(
        json.decode(str).map((x) => ContributionFestivalModel.fromJson(x)));

String contributionFestivalModelToJson(List<ContributionFestivalModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContributionFestivalModel {
  int? id;
  Images? images;
  String? title;
  String? subtitle;
  String? description;
  String? whyWeCelebrate;
  String? history;
  String? dos;
  String? donts;
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
  int? savedCount;
  List<FestivalDate>? dates;

  ContributionFestivalModel(
      {this.id,
      this.images,
      this.title,
      this.subtitle,
      this.description,
      this.whyWeCelebrate,
      this.history,
      this.dos,
      this.donts,
      this.approved,
      this.rejected,
      this.rejectReasons,
      this.draft,
      this.createdAt,
      this.updatedAt,
      this.addedBy,
      this.devs,
      this.liked,
      this.likedCount,
      this.dates,
      this.saved,
      this.savedCount});

  factory ContributionFestivalModel.fromJson(Map<String, dynamic> json) =>
      ContributionFestivalModel(
        id: json["id"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        whyWeCelebrate: json["why_we_celebrate"],
        history: json["history"],
        dos: json["dos"],
        donts: json["donts"],
        approved: json["approved"],
        rejected: json["rejected"],
        rejectReasons: json["reject_reasons"] == null
            ? null
            : RejectReasons.fromJson(json["reject_reasons"]),
        draft: json["draft"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        addedBy: json["added_by"],
        devs: json["devs"] == null
            ? []
            : List<Dev>.from(json["devs"]!.map((x) => Dev.fromJson(x))),
        liked: json["liked"],
        likedCount: json["liked_count"],
        saved: json["saved"],
        savedCount: json["saved_count"],
        dates: json["dates"] == null
            ? []
            : List<FestivalDate>.from(
                json["dates"].map((x) => FestivalDate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "images": images?.toJson(),
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "why_we_celebrate": whyWeCelebrate,
        "history": history,
        "dos": dos,
        "donts": donts,
        "approved": approved,
        "rejected": rejected,
        "reject_reasons": rejectReasons?.toJson(),
        "draft": draft,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "added_by": addedBy,
        "devs": devs == null
            ? []
            : List<dynamic>.from(devs!.map((x) => x.toJson())),
        "liked": liked,
        "liked_count": likedCount,
        "saved": saved,
        "saved_count": savedCount,
        "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x)),
      };

  ContributionFestivalModel copyWith(
      {int? id,
      Images? images,
      String? title,
      String? subtitle,
      String? description,
      String? whyWeCelebrate,
      String? history,
      String? dos,
      String? donts,
      bool? approved,
      bool? rejected,
      RejectReasons? rejectReasons,
      bool? draft,
      String? createdAt,
      String? updatedAt,
      int? addedBy,
      List<Dev>? devs,
      bool? liked,
        bool? saved,
        int? likedCount,
        int? savedCount,
      List<FestivalDate>? dates}) {
    return ContributionFestivalModel(
        id: id ?? this.id,
        images: images ?? this.images,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        description: description ?? this.description,
        whyWeCelebrate: whyWeCelebrate ?? this.whyWeCelebrate,
        history: history ?? this.history,
        dos: dos ?? this.dos,
        donts: donts ?? this.donts,
        approved: approved ?? this.approved,
        rejected: rejected ?? this.rejected,
        rejectReasons: rejectReasons ?? this.rejectReasons,
        draft: draft ?? this.draft,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        addedBy: addedBy ?? this.addedBy,
        devs: devs ?? this.devs,
        liked: liked ?? this.liked,
        likedCount: likedCount ?? this.likedCount,
        saved: saved ?? this.saved,
        savedCount: savedCount ?? this.savedCount,
        dates: dates ?? this.dates);
  }
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

class FestivalDate {
  final int id;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  FestivalDate({
    required this.id,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });

  factory FestivalDate.fromJson(Map<String, dynamic> json) {
    return FestivalDate(
      id: json['id'],
      startDate: json['start_date'],
      startTime: json['start_time'],
      endDate: json['end_date'],
      endTime: json['end_time'],
    );
  }
}

class Images {
  List<Banner>? gallery;
  List<Banner>? banner;

  Images({
    this.gallery,
    this.banner,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        gallery: json["Gallery"] == null
            ? []
            : List<Banner>.from(
                json["Gallery"]!.map((x) => Banner.fromJson(x))),
        banner: json["Banner"] == null
            ? []
            : List<Banner>.from(json["Banner"]!.map((x) => Banner.fromJson(x))),
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

class RejectReasons {
  RejectReasons();

  factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons();

  Map<String, dynamic> toJson() => {};
}
