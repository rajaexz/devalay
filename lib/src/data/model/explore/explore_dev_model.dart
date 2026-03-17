    // To parse this JSON data, do
//
//     final exploreDevModel = exploreDevModelFromJson(jsonString);

import 'dart:convert';

List<ExploreDevModel> exploreDevModelFromJson(String str) => List<ExploreDevModel>.from(json.decode(str).map((x) => ExploreDevModel.fromJson(x)));

String exploreDevModelToJson(List<ExploreDevModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExploreDevModel {
    int? id;
    Images? images;
    Aarti? aarti;
    String? title;
    String? subtitle;
    String? description;
    String? newDescription;
    bool? pramukh;
    bool? approved;
    bool? rejected;
    Avatar? rejectReasons;
    bool? draft;
    String? createdAt;
    String? updatedAt;
    int? addedBy;
    bool? liked;
    bool? saved;
    List<dynamic>? avatar;
    int? likedCount;
    int? savedCount;
    int? viewedCount;
    List<Festival>? festival;

    ExploreDevModel({
        this.id,
        this.images,
        this.aarti,
        this.title,
        this.subtitle,
        this.description,
        this.newDescription,
        this.pramukh,
        this.approved,
        this.rejected,
        this.rejectReasons,
        this.draft,
        this.createdAt,
        this.updatedAt,
        this.addedBy,
        this.liked,
        this.saved,
        this.avatar,
        this.likedCount,
        this.savedCount,
        this.viewedCount,
        this.festival,
    });

    factory ExploreDevModel.fromJson(Map<String, dynamic> json) => ExploreDevModel(
        id: json["id"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        aarti: json["aarti"] == null ? null : Aarti.fromJson(json["aarti"]),
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        newDescription: json["new_description"],
        pramukh: json["pramukh"],
        approved: json["approved"],
        rejected: json["rejected"],
        rejectReasons: json["reject_reasons"] == null ? null : Avatar.fromJson(json["reject_reasons"]),
        draft: json["draft"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        addedBy: json["added_by"],
        liked: json["liked"],
        saved: json["saved"],
        avatar: json["avatar"] ,
        likedCount: json["liked_count"],
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
        festival: json["festival"] == null ? [] : List<Festival>.from(json["festival"]!.map((x) => Festival.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "images": images?.toJson(),
        "aarti": aarti?.toJson(),
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "new_description": newDescription,
        "pramukh": pramukh,
        "approved": approved,
        "rejected": rejected,
        "reject_reasons": rejectReasons?.toJson(),
        "draft": draft,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "added_by": addedBy,
        "liked": liked,
        "saved": saved,
        "avatar": avatar,
        "liked_count": likedCount,
        "saved_count": savedCount,
        "viewed_count": viewedCount,
        "festival": festival == null ? [] : List<dynamic>.from(festival!.map((x) => x.toJson())),
    };
    ExploreDevModel copyWith ({int? id,
    Images? images,
    Aarti? aarti,
    String? title,
    String? subtitle,
    String? description,
    String? newDescription,
    bool? pramukh,
    bool? approved,
    bool? rejected,
    Avatar? rejectReasons,
    bool? draft,
    String? createdAt,
    String? updatedAt,
    int? addedBy,
    bool? liked,
    bool? saved,
    List<dynamic>? avatar,
    int? likedCount,
    int? savedCount,
    int? viewedCount,
    List<Festival>? festival,}){
        return ExploreDevModel(
            id: id ?? this.id,
            images: images ?? this.images,
            aarti: aarti ?? this.aarti,
            title: title ?? this.title,
            subtitle: subtitle ?? this.subtitle,
            description: description ?? this.description,
            newDescription: newDescription ?? this.newDescription,
            pramukh: pramukh ?? this.pramukh,
            approved: approved ?? this.approved,
            rejected: rejected ?? this.rejected,
            rejectReasons: rejectReasons ?? this.rejectReasons,
            draft: draft ?? this.draft,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            addedBy: addedBy ?? this.addedBy,
            liked: liked ?? this.liked,
            saved: saved ?? this.saved,
            avatar: avatar ?? this.avatar,
            likedCount: likedCount ?? this.likedCount,
            savedCount: savedCount ?? this.savedCount,
            viewedCount: viewedCount ?? this.viewedCount,
            festival: festival ?? this.festival
        );
    }
}

class Aarti {
    String? delta;
    String? html;

    Aarti({
        this.delta,
        this.html,
    });

    factory Aarti.fromJson(Map<String, dynamic> json) => Aarti(
        delta: json["delta"],
        html: json["html"],
    );

    Map<String, dynamic> toJson() => {
        "delta": delta,
        "html": html,
    };
}

class Avatar {
    Avatar();

    factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Festival {
    int? id;
    String? title;

    Festival({
        this.id,
        this.title,
    });

    factory Festival.fromJson(Map<String, dynamic> json) => Festival(
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
