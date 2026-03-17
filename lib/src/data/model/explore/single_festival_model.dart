// To parse this JSON data, do
//
//     final singleFestivalModel = singleFestivalModelFromJson(jsonString);

import 'dart:convert';

SingleFestivalModel singleFestivalModelFromJson(String str) => SingleFestivalModel.fromJson(json.decode(str));

String singleFestivalModelToJson(SingleFestivalModel data) => json.encode(data.toJson());

class SingleFestivalModel {
    int? id;
    Images? images;
    String? title;
    String? subtitle;
    String? description;
    String? newDescription;
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
    int? viewedCount;
    List<dynamic>? dates;

    SingleFestivalModel({
        this.id,
        this.images,
        this.title,
        this.subtitle,
        this.description,
        this.newDescription,
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
        this.saved,
        this.likedCount,
        this.savedCount,
        this.viewedCount,
        this.dates,
    });

    factory SingleFestivalModel.fromJson(Map<String, dynamic> json) => SingleFestivalModel(
        id: json["id"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        newDescription: json["new_description"],
        whyWeCelebrate: json["why_we_celebrate"],
        history: json["history"],
        dos: json["dos"],
        donts: json["donts"],
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
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
        dates: json["dates"] == null ? [] : List<dynamic>.from(json["dates"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "images": images?.toJson(),
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "new_description": newDescription,
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
        "devs": devs == null ? [] : List<dynamic>.from(devs!.map((x) => x.toJson())),
        "liked": liked,
        "saved": saved,
        "liked_count": likedCount,
        "saved_count": savedCount,
        "viewed_count": viewedCount,
        "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x)),
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

class RejectReasons {
    RejectReasons();

    factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons(
    );

    Map<String, dynamic> toJson() => {
    };
}
