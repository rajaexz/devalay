// To parse this JSON data, do
//
//     final singleGodModel = singleGodModelFromJson(jsonString);

import 'dart:convert';

SingleGodModel singleGodModelFromJson(String str) => SingleGodModel.fromJson(json.decode(str));

String singleGodModelToJson(SingleGodModel data) => json.encode(data.toJson());

class SingleGodModel {
    int? id;
    SingleGodModelImages? images;
    Aarti? aarti;
    String? title;
    String? subtitle;
    String? description;
    String? newDescription;
    bool? pramukh;
    bool? approved;
    bool? rejected;
    RejectReasons? rejectReasons;
    bool? draft;
    String? createdAt;
    String? updatedAt;
    int? addedBy;
    bool? liked;
    bool? saved;
    List<Avatar>? avatar;
    int? likedCount;
    int? savedCount;
    int? viewedCount;
    AvatarOf? avatarOf;
    List<dynamic>? festival;

    SingleGodModel({
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
        this.avatarOf,
        this.festival,
    });

    factory SingleGodModel.fromJson(Map<String, dynamic> json) => SingleGodModel(
        id: json["id"],
        images: json["images"] == null ? null : SingleGodModelImages.fromJson(json["images"]),
        aarti: json["aarti"] == null ? null : Aarti.fromJson(json["aarti"]),
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        newDescription: json["new_description"],
        pramukh: json["pramukh"],
        approved: json["approved"],
        rejected: json["rejected"],
        rejectReasons: json["reject_reasons"] == null ? null : RejectReasons.fromJson(json["reject_reasons"]),
        draft: json["draft"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        addedBy: json["added_by"],
        liked: json["liked"],
        saved: json["saved"],
        avatar: json["avatar"] == null ? [] : List<Avatar>.from(json["avatar"]!.map((x) => Avatar.fromJson(x))),
        likedCount: json["liked_count"],
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
        avatarOf: json["avatar_of"] == null ? null : AvatarOf.fromJson(json["avatar_of"]),
        festival: json["festival"] == null ? [] : List<dynamic>.from(json["festival"]!.map((x) => x)),
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
        "avatar": avatar == null ? [] : List<dynamic>.from(avatar!.map((x) => x.toJson())),
        "liked_count": likedCount,
        "saved_count": savedCount,
        "viewed_count": viewedCount,
        "avatar_of": avatarOf?.toJson(),
        "festival": festival == null ? [] : List<dynamic>.from(festival!.map((x) => x)),
    };
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
    int? id;
    String? title;
    String? subtitle;
    AvatarImages? images;
    bool? liked;
    int? likedCount;

    Avatar({
        this.id,
        this.title,
        this.subtitle,
        this.images,
        this.liked,
        this.likedCount,
    });

    factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        id: json["id"],
        title: json["title"],
        subtitle: json["subtitle"],
        images: json["images"] == null ? null : AvatarImages.fromJson(json["images"]),
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

class AvatarImages {
    List<dynamic>? banner;

    AvatarImages({
        this.banner,
    });

    factory AvatarImages.fromJson(Map<String, dynamic> json) => AvatarImages(
        banner: json["Banner"] == null ? [] : List<dynamic>.from(json["Banner"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x)),
    };
}

class AvatarOf {
    int? id;
    String? title;

    AvatarOf({
        this.id,
        this.title,
    });

    factory AvatarOf.fromJson(Map<String, dynamic> json) => AvatarOf(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}

class SingleGodModelImages {
    List<Banner>? gallery;
    List<Banner>? banner;

    SingleGodModelImages({
        this.gallery,
        this.banner,
    });

    factory SingleGodModelImages.fromJson(Map<String, dynamic> json) => SingleGodModelImages(
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
