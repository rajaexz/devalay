// To parse this JSON data, do
//
//     final followingRequestModel = followingRequestModelFromJson(jsonString);

// To parse this JSON data, do
//
//     final followingRequestModel = followingRequestModelFromJson(jsonString);

import 'dart:convert';

FollowingRequestModel followingRequestModelFromJson(String str) => FollowingRequestModel.fromJson(json.decode(str));

String followingRequestModelToJson(FollowingRequestModel data) => json.encode(data.toJson());

class FollowingRequestModel {
    int? id;
    String? dp;
    String? backgroundImage;
    String? name;
    dynamic state;
    dynamic country;
    List<Following>? following;
    List<dynamic>? followers;
    bool? followingRequestsStatus;
    bool? followingStatus;

    FollowingRequestModel({
        this.id,
        this.dp,
        this.backgroundImage,
        this.name,
        this.state,
        this.country,
        this.following,
        this.followers,
        this.followingRequestsStatus,
        this.followingStatus,
    });

    factory FollowingRequestModel.fromJson(Map<String, dynamic> json) => FollowingRequestModel(
        id: json["id"],
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        state: json["state"],
        country: json["country"],
        following: json["following"] == null ? [] : List<Following>.from(json["following"]!.map((x) => Following.fromJson(x))),
        followers: json["followers"] == null ? [] : List<dynamic>.from(json["followers"]!.map((x) => x)),
        followingRequestsStatus: json["following_requests_status"],
        followingStatus: json["following_status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
        "state": state,
        "country": country,
        "following": following == null ? [] : List<dynamic>.from(following!.map((x) => x.toJson())),
        "followers": followers == null ? [] : List<dynamic>.from(followers!.map((x) => x)),
        "following_requests_status": followingRequestsStatus,
        "following_status": followingStatus,
    };
}

class Following {
    int? id;
    String? dp;
    String? backgroundImage;
    String? name;

    Following({
        this.id,
        this.dp,
        this.backgroundImage,
        this.name,
    });

    factory Following.fromJson(Map<String, dynamic> json) => Following(
        id: json["id"],
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
    };
}
