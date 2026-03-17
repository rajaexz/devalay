import 'package:devalay_app/src/data/model/feed/feed_home_model.dart';

class FeedComment {
  int? id;
  User? user;
  String? createdAt;
  String? updatedAt;
  String? comment;
  int? objectId;
  int? contentType;
  bool? liked;
  int? likedCount;
  int? commentsReplyCount;
  FeedComment(
      {this.id,
      this.user,
      this.createdAt,
      this.updatedAt,
      this.comment,
      this.objectId,
      this.contentType,
      this.liked,
      this.commentsReplyCount,
      this.likedCount});
FeedComment copyWith({
    bool? liked,
    int? likedCount,
       
      
  }) {
    return FeedComment(

     
      liked: liked ?? this.liked,

      likedCount: likedCount ?? this.likedCount,

    );
  }
  FeedComment.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["user"] is Map) {
      user = json["user"] == null ? null : User.fromJson(json["user"]);
    }
    if (json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if (json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
    if (json["comment"] is String) {
      comment = json["comment"];
    }
    if (json["object_id"] is int) {
      objectId = json["object_id"];
    }
    if (json["content_type"] is int) {
      contentType = json["content_type"];
    }
   
    if (json["liked"] is bool) {
      liked = json["liked"];
    }
    if (json["liked_count"] is int) {
      likedCount = json["liked_count"];
    }

  if (json["comments_reply_count"] is int) {
      commentsReplyCount = json["comments_reply_count"];
    }
  }

  
  
  

  static List<FeedComment> fromList(List<dynamic> list) {
    return list
        .map((e) => FeedComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    if (user != null) {
      data["user"] = user?.toJson();
    }
    data["created_at"] = createdAt;
    data["updated_at"] = updatedAt;
    data["comment"] = comment;
    data["object_id"] = objectId;
    data["content_type"] = contentType;
    data["liked"] = liked;
    data["liked_count"] = likedCount;
    data["comments_reply_count"] = commentsReplyCount;
    return data;
  }
}

class User {
  int? id;
  User1? user;
  String? dp;
  dynamic backgroundImage;
  String? name;
  String? state;
  dynamic country;

  User(
      {this.id,
      this.user,
      this.dp,
      this.backgroundImage,
      this.name,
      this.state,
      this.country});

  User.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["user"] is Map) {
      user = json["user"] == null ? null : User1.fromJson(json["user"]);
    }
    if (json["dp"] is String) {
      dp = json["dp"];
    }
    backgroundImage = json["background_image"];
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["state"] is String) {
      state = json["state"];
    }
    
    country = json["country"];
  }

  static List<User> fromList(List<Map<String, dynamic>> list) {
    return list.map(User.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    if (user != null) {
      data["user"] = user?.toJson();
    }
    data["dp"] = dp;
    data["background_image"] = backgroundImage;
    data["name"] = name;
    data["state"] = state;
    data["country"] = country;
   
    return data;
  }
}
