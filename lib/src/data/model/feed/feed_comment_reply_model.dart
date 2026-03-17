

import 'dart:convert';

List<FeedCommentReply> feedCommentReplyFromJson(String str) => List<FeedCommentReply>.from(json.decode(str).map((x) => FeedCommentReply.fromJson(x)));

String feedCommentReplyToJson(List<FeedCommentReply> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FeedCommentReply {
  int? id;
  FeedCommentReplyUser? user;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? comment;
  int? objectId;
  int? contentType;
  bool? liked;
  int? likedCount;
  int? commentsReplyCount;

  FeedCommentReply({
    this.id,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.comment,
    this.objectId,
    this.contentType,
    this.liked,
    this.likedCount,
    this.commentsReplyCount,
  });

  FeedCommentReply copyWith({
    int? id,
    FeedCommentReplyUser? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? comment,
    int? objectId,
    int? contentType,
    bool? liked,
    int? likedCount,
    int? commentsReplyCount,
  }) =>
      FeedCommentReply(
        id: id ?? this.id,
        user: user ?? this.user,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        comment: comment ?? this.comment,
        objectId: objectId ?? this.objectId,
        contentType: contentType ?? this.contentType,
        liked: liked ?? this.liked,
        likedCount: likedCount ?? this.likedCount,
        commentsReplyCount: commentsReplyCount ?? this.commentsReplyCount,
      );

  factory FeedCommentReply.fromJson(Map<String, dynamic> json) => FeedCommentReply(
        id: json["id"],
        user: json["user"] == null ? null : FeedCommentReplyUser.fromJson(json["user"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        comment: json["comment"],
        objectId: json["object_id"],
        contentType: json["content_type"],
        liked: json["liked"],
        likedCount: json["liked_count"],
        commentsReplyCount: json["comments_reply_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "comment": comment,
        "object_id": objectId,
        "content_type": contentType,
        "liked": liked,
        "liked_count": likedCount,
        "comments_reply_count": commentsReplyCount,
      };

  /// ✅ This is the method you need
  static List<FeedCommentReply> fromList(List<dynamic> list) {
    return list.map((e) => FeedCommentReply.fromJson(e)).toList();
  }
}

class FeedCommentReplyUser {
    int? id;
    FollowersRequestUser? user;
    String? dp;
    dynamic backgroundImage;
    String? name;
    dynamic state;
    String? country;
    dynamic followingRequests;
    dynamic following;
    dynamic dob;
    dynamic phone;
    String? gender;
    dynamic biography;
    dynamic city;
    List<dynamic>? blockList;
    List<dynamic>? hideSuggestionList;
    List<dynamic>? groups;
    List<dynamic>? userPermissions;
    List<dynamic>? followers;
    List<FollowRequest>? followersRequests;

    FeedCommentReplyUser({
        this.id,
        this.user,
        this.dp,
        this.backgroundImage,
        this.name,
        this.state,
        this.country,
        this.followingRequests,
        this.following,
        this.dob,
        this.phone,
        this.gender,
        this.biography,
        this.city,
        this.blockList,
        this.hideSuggestionList,
        this.groups,
        this.userPermissions,
        this.followers,
        this.followersRequests,
    });

    FeedCommentReplyUser copyWith({
        int? id,
        FollowersRequestUser? user,
        String? dp,
        dynamic backgroundImage,
        String? name,
        dynamic state,
        String? country,
        dynamic followingRequests,
        dynamic following,
        dynamic dob,
        dynamic phone,
        String? gender,
        dynamic biography,
        dynamic city,
        List<dynamic>? blockList,
        List<dynamic>? hideSuggestionList,
        List<dynamic>? groups,
        List<dynamic>? userPermissions,
        List<dynamic>? followers,
        List<FollowRequest>? followersRequests,
    }) => 
        FeedCommentReplyUser(
            id: id ?? this.id,
            user: user ?? this.user,
            dp: dp ?? this.dp,
            backgroundImage: backgroundImage ?? this.backgroundImage,
            name: name ?? this.name,
            state: state ?? this.state,
            country: country ?? this.country,
            followingRequests: followingRequests ?? this.followingRequests,
            following: following ?? this.following,
            dob: dob ?? this.dob,
            phone: phone ?? this.phone,
            gender: gender ?? this.gender,
            biography: biography ?? this.biography,
            city: city ?? this.city,
            blockList: blockList ?? this.blockList,
            hideSuggestionList: hideSuggestionList ?? this.hideSuggestionList,
            groups: groups ?? this.groups,
            userPermissions: userPermissions ?? this.userPermissions,
            followers: followers ?? this.followers,
            followersRequests: followersRequests ?? this.followersRequests,
        );

    factory FeedCommentReplyUser.fromJson(Map<String, dynamic> json) => FeedCommentReplyUser(
        id: json["id"],
        user: json["user"] == null ? null : FollowersRequestUser.fromJson(json["user"]),
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        state: json["state"],
        country: json["country"],
        followingRequests: json["following_requests"],
        following: json["following"],
        dob: json["dob"],
        phone: json["phone"],
        gender: json["gender"],
        biography: json["biography"],
        city: json["city"],
        blockList: json["block_list"] == null ? [] : List<dynamic>.from(json["block_list"]!.map((x) => x)),
        hideSuggestionList: json["hide_suggestion_list"] == null ? [] : List<dynamic>.from(json["hide_suggestion_list"]!.map((x) => x)),
        groups: json["groups"] == null ? [] : List<dynamic>.from(json["groups"]!.map((x) => x)),
        userPermissions: json["user_permissions"] == null ? [] : List<dynamic>.from(json["user_permissions"]!.map((x) => x)),
        followers: json["followers"] == null ? [] : List<dynamic>.from(json["followers"]!.map((x) => x)),
        followersRequests: json["followers_requests"] == null ? [] : List<FollowRequest>.from(json["followers_requests"]!.map((x) => FollowRequest.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
        "state": state,
        "country": country,
        "following_requests": followingRequests,
        "following": following,
        "dob": dob,
        "phone": phone,
        "gender": gender,
        "biography": biography,
        "city": city,
        "block_list": blockList == null ? [] : List<dynamic>.from(blockList!.map((x) => x)),
        "hide_suggestion_list": hideSuggestionList == null ? [] : List<dynamic>.from(hideSuggestionList!.map((x) => x)),
        "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
        "user_permissions": userPermissions == null ? [] : List<dynamic>.from(userPermissions!.map((x) => x)),
        "followers": followers == null ? [] : List<dynamic>.from(followers!.map((x) => x)),
        "followers_requests": followersRequests == null ? [] : List<dynamic>.from(followersRequests!.map((x) => x.toJson())),
    };
}

class FollowRequest {
    int? id;
    FollowersRequestUser? user;
    String? dp;
    String? backgroundImage;
    String? name;
    dynamic state;
    String? country;
    bool? followingRequests;
    bool? following;

    FollowRequest({
        this.id,
        this.user,
        this.dp,
        this.backgroundImage,
        this.name,
        this.state,
        this.country,
        this.followingRequests,
        this.following,
    });

    FollowRequest copyWith({
        int? id,
        FollowersRequestUser? user,
        String? dp,
        String? backgroundImage,
        String? name,
        dynamic state,
        String? country,
        bool? followingRequests,
        bool? following,
    }) => 
        FollowRequest(
            id: id ?? this.id,
            user: user ?? this.user,
            dp: dp ?? this.dp,
            backgroundImage: backgroundImage ?? this.backgroundImage,
            name: name ?? this.name,
            state: state ?? this.state,
            country: country ?? this.country,
            followingRequests: followingRequests ?? this.followingRequests,
            following: following ?? this.following,
        );

    factory FollowRequest.fromJson(Map<String, dynamic> json) => FollowRequest(
        id: json["id"],
        user: json["user"] == null ? null : FollowersRequestUser.fromJson(json["user"]),
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        state: json["state"],
        country: json["country"],
        followingRequests: json["following_requests"],
        following: json["following"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
        "state": state,
        "country": country,
        "following_requests": followingRequests,
        "following": following,
    };
}

class FollowersRequestUser {
    int? id;
    String? username;
    String? firstName;
    String? lastName;
    String? email;

    FollowersRequestUser({
        this.id,
        this.username,
        this.firstName,
        this.lastName,
        this.email,
    });

    FollowersRequestUser copyWith({
        int? id,
        String? username,
        String? firstName,
        String? lastName,
        String? email,
    }) => 
        FollowersRequestUser(
            id: id ?? this.id,
            username: username ?? this.username,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            email: email ?? this.email,
        );

    factory FollowersRequestUser.fromJson(Map<String, dynamic> json) => FollowersRequestUser(
        id: json["id"],
        username: json["username"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
    };
}
