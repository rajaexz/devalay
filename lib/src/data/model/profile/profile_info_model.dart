// To parse this JSON data, do
//
//     final profileInfoModel = profileInfoModelFromJson(jsonString);

import 'dart:convert';

import '../feed/feed_home_model.dart';

ProfileInfoModel profileInfoModelFromJson(String str) =>
    ProfileInfoModel.fromJson(json.decode(str));

String profileInfoModelToJson(ProfileInfoModel data) =>
    json.encode(data.toJson());

class ProfileInfoModel {
  int? id;
  String? dp;
  dynamic dob;
  dynamic phone;
  String? gender;
  String? biography;
  dynamic backgroundImage;
  dynamic city;
  dynamic state;
  List<ProfileSkill>? skills;
  bool? isPandit;
  dynamic country;
  int? postCount;
  User? user;
  bool? followingRequestsStatus;
  bool? followingStatus;
  List<FollowersRequestElement>? following;
  List<FollowersRequestElement>? followingRequests;
  List<FollowersRequestElement>? blockList;
  List<dynamic>? hideSuggestionList;
  List<dynamic>? groups;
  List<dynamic>? userPermissions;
  String? name;
  String? email;
  bool? admin;
  List<dynamic>? followers;
  List<FollowersRequestElement>? followersRequests;
  bool? isPrivate;

  ProfileInfoModel({
    this.id,
    this.dp,
    this.isPandit,
    this.dob,
    this.phone,
    this.gender,
    this.postCount,
    this.email,
    this.biography,
    this.backgroundImage,
    this.city,
    this.state,
    this.country,
    this.user,
    this.following,
    this.followingStatus,
    this.followingRequestsStatus,
    this.followingRequests,
    this.blockList,
    this.skills,
    this.hideSuggestionList,
    this.groups,
    this.userPermissions,
    this.name,
    this.admin,
    this.followers,
    this.followersRequests,
      this.isPrivate
  });

factory ProfileInfoModel.fromJson(Map<String, dynamic> json) =>
    ProfileInfoModel(
      id: json["id"],
      dp: json["dp"],
      dob: json["dob"],
      phone: json["phone"],
      gender: json["gender"],
      biography: json["biography"],
      backgroundImage: json["background_image"],
      city: json["city"],
      state: json["state"],
      postCount: json["post_count"],
      email: json["email"],
      followingRequestsStatus: json["following_requests_status"],
      followingStatus: json["following_status"],
      country: json["country"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      
    isPandit:   json["is_pandit"],
      skills: (() {
        final raw = json["skills"];
        final List<ProfileSkill> result = [];

        if (raw == null) return result;

        try {
          // Case 1: simple list: ["Pandit", "Purohit"]
          if (raw is List) {
            for (final item in raw) {
              if (item == null) continue;
              if (item is Map<String, dynamic>) {
                result.add(
                  ProfileSkill(
                    id: item["id"],
                    name: item["name"]?.toString(),
                    status: item["status"]?.toString(),
                  ),
                );
              } else {
                result.add(ProfileSkill(name: item.toString()));
              }
            }
            return result;
          }

          // Case 2: nested structure:
          // "skills": { "expertise": [ { "id": 1, "name": "Pandit", "status": "Pending" }, ... ] }
          if (raw is Map<String, dynamic>) {
            final expertise = raw["expertise"];
            if (expertise is List) {
              for (final item in expertise) {
                if (item is Map<String, dynamic>) {
                  result.add(
                    ProfileSkill(
                      id: item["id"],
                      name: item["name"]?.toString(),
                      status: item["status"]?.toString(),
                    ),
                  );
                }
              }
              return result;
            }
          }

          return result;
        } catch (e) {
          print('Error parsing skills: $e');
          return <ProfileSkill>[];
        }
      })(),
      
      following: json["following"] == null
          ? []
          : List<FollowersRequestElement>.from(
              json["following"].map((x) => FollowersRequestElement.fromJson(x))),
      followingRequests: json["following_requests"] == null
          ? []
          : List<FollowersRequestElement>.from(json["following_requests"]
              .map((x) => FollowersRequestElement.fromJson(x))),
      blockList: json["block_list"] == null
          ? []
          : List<FollowersRequestElement>.from(json["block_list"]
              .map((x) => FollowersRequestElement.fromJson(x))),
      hideSuggestionList: json["hide_suggestion_list"] == null
          ? []
          : List<dynamic>.from(json["hide_suggestion_list"]),
      groups: json["groups"] == null
          ? []
          : List<dynamic>.from(json["groups"]),
      userPermissions: json["user_permissions"] == null
          ? []
          : List<dynamic>.from(json["user_permissions"]),
      name: json["name"],
      admin: json["admin"],
      isPrivate: json["is_private"] ?? json["isPrivate"],
      followers: json["followers"] == null
          ? []
          : List<dynamic>.from(json["followers"]),
      followersRequests: json["followers_requests"] == null
          ? []
          : List<FollowersRequestElement>.from(json["followers_requests"]
              .map((x) => FollowersRequestElement.fromJson(x))),
    );


  Map<String, dynamic> toJson() => {
        "id": id,
        "dp": dp,
        "dob": dob,
        "phone": phone,
        "email": email,
        "gender": gender,
        "biography": biography,
        "background_image": backgroundImage,
        "city": city,
        "state": state,
        "country": country,
        "user": user?.toJson(),
        "skills": skills == null
            ? null
            : {
                "expertise": List<dynamic>.from(skills!.map((x) => x.toJson())),
              },
        "following": following == null
            ? []
            : List<dynamic>.from(following!.map((x) => x.toJson())),
        "following_requests": followingRequests == null
            ? []
            : List<dynamic>.from(followingRequests!.map((x) => x.toJson())),
        "block_list": blockList == null
            ? []
            : List<dynamic>.from(blockList!.map((x) => x)),
        "hide_suggestion_list": hideSuggestionList == null
            ? []
            : List<dynamic>.from(hideSuggestionList!.map((x) => x)),
        "groups":
            groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
        "user_permissions": userPermissions == null
            ? []
            : List<dynamic>.from(userPermissions!.map((x) => x)),
        "name": name,
        "admin": admin,
        "is_private": isPrivate,
        "followers": followers == null
            ? []
            : List<dynamic>.from(followers!.map((x) => x)),
        "followers_requests": followersRequests == null
            ? []
            : List<dynamic>.from(followersRequests!.map((x) => x.toJson())),
      };
}

class FollowersRequestElement {
  int? id;
  User? user;
  String? dp;
  String? backgroundImage;
  String? name;
  dynamic state;
  String? country;
  List<FollowerElement>? following;
  List<FollowerElement>? followers;
  int? postCount;

  FollowersRequestElement({
    this.id,
    this.user,
    this.dp,
    this.backgroundImage,
    this.name,
    this.state,
    this.country,
    this.following,
    this.followers,
    this.postCount,
  });

  factory FollowersRequestElement.fromJson(Map<String, dynamic> json) =>
      FollowersRequestElement(
        id: json["id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        state: json["state"],
        country: json["country"],
        following: json["following"] == null
            ? []
            : List<FollowerElement>.from(
                json["following"]!.map((x) => FollowerElement.fromJson(x))),
        followers: json["followers"] == null
            ? []
            : List<FollowerElement>.from(
                json["followers"]!.map((x) => FollowerElement.fromJson(x))),
        postCount: json['post_count'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_count": postCount,
        "user": user?.toJson(),
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
        "state": state,
        "country": country,
        "following": following == null
            ? []
            : List<dynamic>.from(following!.map((x) => x.toJson())),
        "followers": followers == null
            ? []
            : List<dynamic>.from(followers!.map((x) => x.toJson())),
      };
}

class FollowerElement {
  int? id;
  User? user;
  String? dp;
  String? backgroundImage;
  String? name;

  FollowerElement({
    this.id,
    this.user,
    this.dp,
    this.backgroundImage,
    this.name,
  });

  factory FollowerElement.fromJson(Map<String, dynamic> json) =>
      FollowerElement(
        id: json["id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
      };
}

class ProfileSkill {
  final int? id;
  final String? name;
  final String? status;
  ProfileSkill({this.id, this.name, this.status});

  factory ProfileSkill.fromJson(Map<String, dynamic> json) => ProfileSkill(
    id: json["id"],
    name: json["name"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status ?? "Pending", 
  };
}
