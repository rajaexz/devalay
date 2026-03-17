// To parse this JSON data, do
//
//     final singlePujaModel = singlePujaModelFromJson(jsonString);

import 'dart:convert';

SinglePujaModel singlePujaModelFromJson(String str) => SinglePujaModel.fromJson(json.decode(str));

String singlePujaModelToJson(SinglePujaModel data) => json.encode(data.toJson());

class SinglePujaModel {
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
    dynamic addedBy;
    List<dynamic>? devs;
    bool? liked;
    bool? saved;
    int? likedCount;

    SinglePujaModel({
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

    factory SinglePujaModel.fromJson(Map<String, dynamic> json) => SinglePujaModel(
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
        devs: json["devs"] == null ? [] : List<dynamic>.from(json["devs"]!.map((x) => x)),
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
        "devs": devs == null ? [] : List<dynamic>.from(devs!.map((x) => x)),
        "liked": liked,
        "saved": saved,
        "liked_count": likedCount,
    };

  static from(map) {}
}

class Images {
    List<dynamic>? gallery;
    List<dynamic>? banner;

    Images({
        this.gallery,
        this.banner,
    });

    factory Images.fromJson(Map<String, dynamic> json) => Images(
        gallery: json["Gallery"] == null ? [] : List<dynamic>.from(json["Gallery"]!.map((x) => x)),
        banner: json["Banner"] == null ? [] : List<dynamic>.from(json["Banner"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x)),
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
