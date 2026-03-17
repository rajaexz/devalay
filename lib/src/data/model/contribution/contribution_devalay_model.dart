// To parse this JSON data, do
//
//     final contributionDevalayModel = contributionDevalayModelFromJson(jsonString);

import 'dart:convert';

List<ContributionDevalayModel> contributionDevalayModelFromJson(String str) => List<ContributionDevalayModel>.from(json.decode(str).map((x) => ContributionDevalayModel.fromJson(x)));

String contributionDevalayModelToJson(List<ContributionDevalayModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContributionDevalayModel {
    int? id;
    int? likedCount;
    Images? images;
    List<DevElement>? devs;
    int? steps;
    String? title;
    String? subtitle;
    int? savedCount;
    String? description;
    String? address;
    String? city;
    String? state;
    String? country;
    String? pincode;
    String? nearestAirport;
    String? nearestRailway;
    String? landmark;
    String? location;
    String? googleMapLink;
    String? metatags;
    String? legend;
    String? architecture;
    String? etymology;
    String? templeHistory;
    String? website;
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
    
    ContributionDevalayModel({
        this.id,
        this.images,
        this.devs,
        this.title,
        this.subtitle,
        this.description,
          this.steps,
        this.address,
        this.likedCount,
        this.city,
        this.state,
        this.country,
        this.pincode,
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
        this.location,
        this.createdAt,
        this.updatedAt,
        this.governedBy,
        this.addedBy,
        this.liked,
        this.saved,
        this.savedCount,
        this.approvedBy,
        this.rejectedBy,
    });

    factory ContributionDevalayModel.fromJson(Map<String, dynamic> json){
       return ContributionDevalayModel(
            id: json["id"],
            savedCount: json["saved_count"],
            images: json["images"] == null ? null : Images.fromJson(json["images"]),
            devs: json["devs"] == null ? [] : List<DevElement>.from(json["devs"]!.map((x) => DevElement.fromJson(x))),
            title: json["title"],
            subtitle: json["subtitle"],
            steps: json["steps"]?? 0,
            description: json["description"],
            address: json["address"],
            city: json["city"],
           pincode: json["pincode"],
            location: json["location"],
            likedCount: json["liked_count"],
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
            rejectReasons: json["reject_reasons"] == null ? null : RejectReasons.fromJson(json["reject_reasons"]),
            draft: json["draft"],
            createdAt: json["created_at"],
            updatedAt: json["updated_at"],
            governedBy: json["governed_by"] == null ? null : GovernedBy.fromJson(json["governed_by"]),
            addedBy: json["added_by"] == null ? null : AddedBy.fromJson(json["added_by"]),
            liked: json["liked"],
            saved: json["saved"],
            approvedBy: json["approved_by"] == null ? [] : List<dynamic>.from(json["approved_by"]!.map((x) => x)),
            rejectedBy: json["rejected_by"] == null ? [] : List<dynamic>.from(json["rejected_by"]!.map((x) => x)),
          
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "images": images?.toJson(),
        "devs": devs == null ? [] : List<dynamic>.from(devs!.map((x) => x.toJson())),
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "address": address,
        "city": city,
        "state": state,
        "pincode": pincode,
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
        "approved_by": approvedBy == null ? [] : List<dynamic>.from(approvedBy!.map((x) => x)),
        "rejected_by": rejectedBy == null ? [] : List<dynamic>.from(rejectedBy!.map((x) => x)),
        "liked_count": likedCount,
    };

    ContributionDevalayModel copyWith({
        int? id,
        int? likedCount,
        Images? images,
        List<DevElement>? devs,
        String? title,
        String? subtitle,
        int? savedCount,
        String? description,
        String? address,
        String? city,
        String? state,
        String? country,
        String? pincode,
        String? nearestAirport,
        String? nearestRailway,
        String? landmark,
        String? location,
        String? googleMapLink,
        String? metatags,
        String? legend,
        String? architecture,
        String? etymology,
        String? templeHistory,
        String? website,
        bool? approved,
        bool? rejected,
        RejectReasons? rejectReasons,
        bool? draft,
        String? createdAt,
        String? updatedAt,
        GovernedBy? governedBy,
        AddedBy? addedBy,
        bool? liked,
        bool? saved,
        List<dynamic>? approvedBy,
        List<dynamic>? rejectedBy,
    }) {
        return ContributionDevalayModel(
            id: id ?? this.id,
            likedCount: likedCount ?? this.likedCount,
            images: images ?? this.images,
            devs: devs ?? this.devs,
            title: title ?? this.title,
            subtitle: subtitle ?? this.subtitle,
            savedCount: savedCount ?? this.savedCount,
            description: description ?? this.description,
            address: address ?? this.address,
            city: city ?? this.city,
            pincode: pincode ?? this.pincode,
            state: state ?? this.state,
            country: country ?? this.country,
            nearestAirport: nearestAirport ?? this.nearestAirport,
            nearestRailway: nearestRailway ?? this.nearestRailway,
            landmark: landmark ?? this.landmark,
            location: location ?? this.location,
            googleMapLink: googleMapLink ?? this.googleMapLink,
            metatags: metatags ?? this.metatags,
            legend: legend ?? this.legend,
            architecture: architecture ?? this.architecture,
            etymology: etymology ?? this.etymology,
            templeHistory: templeHistory ?? this.templeHistory,
            website: website ?? this.website,
            approved: approved ?? this.approved,
            rejected: rejected ?? this.rejected,
            rejectReasons: rejectReasons ?? this.rejectReasons,
            draft: draft ?? this.draft,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            governedBy: governedBy ?? this.governedBy,
            addedBy: addedBy ?? this.addedBy,
            liked: liked ?? this.liked,
            saved: saved ?? this.saved,
            approvedBy: approvedBy ?? this.approvedBy,
            rejectedBy: rejectedBy ?? this.rejectedBy,
        );
    }
}

class AddedBy {
    int? id;
    String? name;
    String? username;
    String? email;
    dynamic bio;

    AddedBy({
        this.id,
        this.name,
        this.username,
        this.email,
        this.bio,
    });

    factory AddedBy.fromJson(Map<String, dynamic> json) => AddedBy(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        bio: json["bio"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "email": email,
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

    DevDev({
        this.id,
        this.title,
    });

    factory DevDev.fromJson(Map<String, dynamic> json) => DevDev(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}

class GovernedBy {
    int? id;
    bool? approved;
    bool? verified;
    bool? superpower;
    List<int>? governer;

    GovernedBy({
        this.id,
        this.approved,
        this.verified,
        this.superpower,
        this.governer,
    });

    factory GovernedBy.fromJson(Map<String, dynamic> json) => GovernedBy(
        id: json["id"],
        approved: json["approved"],
        verified: json["verified"],
        superpower: json["superpower"],
        governer: json["governer"] == null ? [] : List<int>.from(json["governer"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "approved": approved,
        "verified": verified,
        "superpower": superpower,
        "governer": governer == null ? [] : List<dynamic>.from(governer!.map((x) => x)),
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
        gallery: json["Gallery"] == null ? [] : List<DevElement>.from(json["Gallery"]!.map((x) => DevElement.fromJson(x))),
        banner: json["Banner"] == null ? [] : List<DevElement>.from(json["Banner"]!.map((x) => DevElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x.toJson())),
        "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x.toJson())),
    };
}

class RejectReasons {
    Map<String, dynamic>? reasons;

    RejectReasons({
        this.reasons,
    });

    factory RejectReasons.fromJson(Map<String, dynamic> json) => RejectReasons(
        reasons: json,
    );

    Map<String, dynamic> toJson() => reasons ?? {};
}
