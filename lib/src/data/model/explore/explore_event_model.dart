// To parse this JSON data, do
//
//     final exploreEventModel = exploreEventModelFromJson(jsonString);

import 'dart:convert';

List<ExploreEventModel> exploreEventModelFromJson(String str) => List<ExploreEventModel>.from(json.decode(str).map((x) => ExploreEventModel.fromJson(x)));

String exploreEventModelToJson(List<ExploreEventModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExploreEventModel {
    int? id;
    Images? images;
    String? title;
    String? subtitle;
    String? description;
    String? howToCelebrate;
    String? dos;
    String? donts;
    String? location;
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

    Dev? devalay;
    int? addedBy;
    List<Dev>? devs;
    bool? liked;
    bool? saved;
    int? likedCount;
    List<Date>? dates;
    int? savedCount;
    int? viewedCount;

    ExploreEventModel({
        this.id,
        this.images,
        this.title,
        this.subtitle,
        this.description,
        this.howToCelebrate,
        this.savedCount,
        this.viewedCount,
        this.dos,
        this.donts,
        this.address,
        this.location,
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
        this.liked,
        this.saved,

        this.likedCount,
        this.dates,
    });

    factory ExploreEventModel.fromJson(Map<String, dynamic> json) => ExploreEventModel(
        id: json["id"],
        images: json["images"] == null ? null : Images.fromJson(json["images"]),
        title: json["title"],
        subtitle: json["subtitle"],
        savedCount: json["saved_count"],
        viewedCount: json["viewed_count"],
        description: json["description"],
        howToCelebrate: json["how_to_celebrate"],
        dos: json["dos"],
        donts: json["donts"],
        location: json["location"],
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
        devalay: json["devalay"] == null ? null : Dev.fromJson(json["devalay"]),
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
        // "saved_count": savedCount,
        "city": city,
        "state": state,
        "location": location,
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
        "saved_count": savedCount,
        "viewed_count": viewedCount,
    };

    ExploreEventModel copyWith({
        int? id,
        Images? images,
        String? title,
        String? subtitle,
        String? description,
        String? howToCelebrate,
        String? dos,
        String? donts,
        String? location,
        String? address,
        String? city,
        String? state,
        String? country,
        String? landmark,
        String? nearestAirport,
        String? nearestRailway,
        String? googleMapLink,
        bool? approved,
        bool? rejected,
        RejectReasons? rejectReasons,
        bool? draft,
        String? createdAt,
        String? updatedAt,
        Dev? devalay,
        int? addedBy,
        List<Dev>? devs,
        bool? liked,
        bool? saved,
        int? likedCount,
        int? savedCount,
        int? viewedCount,
        List<Date>? dates,
    }) {
        return ExploreEventModel(
            id: id ?? this.id,
            images: images ?? this.images,
            title: title ?? this.title,
            subtitle: subtitle ?? this.subtitle,
            description: description ?? this.description,
            howToCelebrate: howToCelebrate ?? this.howToCelebrate,
            dos: dos ?? this.dos,
            donts: donts ?? this.donts,
            location: location ?? this.location,
            address: address ?? this.address,
            city: city ?? this.city,
            state: state ?? this.state,
            country: country ?? this.country,
            landmark: landmark ?? this.landmark,
            nearestAirport: nearestAirport ?? this.nearestAirport,
            nearestRailway: nearestRailway ?? this.nearestRailway,
            googleMapLink: googleMapLink ?? this.googleMapLink,
            approved: approved ?? this.approved,
            rejected: rejected ?? this.rejected,
            rejectReasons: rejectReasons ?? this.rejectReasons,
            draft: draft ?? this.draft,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            devalay: devalay ?? this.devalay,
            addedBy: addedBy ?? this.addedBy,
            devs: devs ?? this.devs,
            liked: liked ?? this.liked,
            saved: saved ?? this.saved,
            likedCount: likedCount ?? this.likedCount,
            savedCount: savedCount ?? this.savedCount,
            viewedCount: viewedCount ?? this.viewedCount,
            dates: dates ?? this.dates,
        );
    }
}

class Date {
    int? id;
    DateTime? startDate;
    String? startTime;
    DateTime? endDate;
    String? endTime;

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
