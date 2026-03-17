import 'package:devalay_app/src/data/model/explore/explore_devotees_model.dart';

class FeedGetData {
  int? id;
  List<Media>? media;
  User? user;
  String? createdAt;
  bool? isPandit;
  String? updatedAt;
  String? textDelta; 
  String? textHtml;  
      String? eyes;
  List<Tags>? tags;
  String? location;
  bool? liked;
  bool? saved;
  bool? report;
  int? likedCount;
  int? commentsCount;
    List<ExploreUser>? likedUsers;
  FeedGetData({
    this.id,
    this.media,
    this.location,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.textDelta,
    this.eyes,
    this.textHtml,
    this.liked,
    this.saved,
    this.tags,
    this.report,
    this.likedCount,
    this.commentsCount,
        this.likedUsers,
  });


FeedGetData.fromJson(Map<String, dynamic> json) {
  id = json["id"];
  media = json["media"] == null
      ? null
      : (json["media"] as List).map((e) => Media.fromJson(e)).toList();
  user = json["user"] == null ? null : User.fromJson(json["user"]);
  createdAt = json["created_at"];
  updatedAt = json["updated_at"];
  isPandit = json["is_pandit"];
  if (json["text"] is String) {
    textHtml = json["text"];
    textDelta = null;
  } else {
    textDelta = json["text"]?["delta"]?.toString();
    textHtml = json["text"]?["html"]?.toString();
  }
  eyes = json["viewed"].toString();
  liked = json["liked"];
  location =json["location"] ??'';
  saved = json["saved"];
  tags = json["tags"] == null ? [] : List<Tags>.from(json["tags"]!.map((x) => Tags.fromJson(x)));
  report = json["report"];
  likedCount = json["liked_count"];
  commentsCount = json["comments_count"];
  likedUsers= json["liked_users"] == null ? [] : List<ExploreUser>.from(json["liked_users"]!.map((x) => ExploreUser.fromJson(x)));
 
}

  static List<FeedGetData> fromList(List<dynamic> list) {
    return list
        .map((e) => FeedGetData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data["id"] = id;
  if (media != null) {
    data["media"] = media?.map((e) => e.toJson()).toList();
  }
  if (user != null) {
    data["user"] = user?.toJson();
  }
  data["created_at"] = createdAt;
  data["updated_at"] = updatedAt;
  
  if (textDelta != null || textHtml != null) {
    data["text"] = {
      "delta": textDelta,
      "html": textHtml,
    };
  }
   data["viewed"] = eyes;
  data["liked"] = liked;
  data["saved"] = saved;
  data["report"] = report;
  data["liked_count"] = likedCount;
  data["comments_count"] = commentsCount;
  return data;
}
FeedGetData copyWith({
  bool? liked,
  int? likedCount,
  int? commentsCount,
  bool? saved,
   String? eyes,
  bool? isPandit,
  bool? report,
  User? user,
  String? textDelta,
  String? textHtml,
}) {
  return FeedGetData(
    id: id,
    media: media,
    user: user ?? this.user,
    createdAt: createdAt,
    updatedAt: updatedAt,
    eyes: eyes,
    textDelta: textDelta ?? this.textDelta,
    textHtml: textHtml ?? this.textHtml,
    liked: liked ?? this.liked,
    saved: saved ?? this.saved,
    report: report ?? this.report,
    likedCount: likedCount ?? this.likedCount,
    commentsCount: commentsCount ?? this.commentsCount,
  );
}
}

class Tags {
  int? id;
  String? name;
  String? type;
  String? objectId;
   Tags({this.id, this.name, this.type, this.objectId});

  Tags.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    objectId = json["object_id"]?.toString();
    type = json["content_type"];
  }   
}

class User {
  int? id;
  dynamic dob;
  dynamic phone;
  String? gender;
  dynamic biography;
  String? dp;
  dynamic backgroundImage;
  dynamic city;
  dynamic state;
  dynamic country;
    String? username;

  String? firstName;
  String? lastName;
  String? email;
  // User1? user;
  bool? following;
  bool? followingRequests;
  List<dynamic>? blockList;
  List<dynamic>? hideSuggestionList;
  List<dynamic>? groups;
  List<dynamic>? userPermissions;
  String? name;

  User(
      {this.id,
      this.dob,
      this.phone,
      this.gender,
      this.biography,
      this.dp,
      this.backgroundImage,
      this.city,
      this.state,
      this.country,
      // this.user,
        this.username,
  this.firstName,
  this.lastName,
  this.email,

      this.following,
      this.followingRequests,
      this.blockList,
      this.hideSuggestionList,
      this.groups,
      this.userPermissions,
      this.name});

  User.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    dob = json["dob"];
    phone = json["phone"];
    if (json["gender"] is String) {
      gender = json["gender"];
    }
    biography = json["biography"];
    if (json["dp"] is String) {
      dp = json["dp"];
    }
    backgroundImage = json["background_image"];
    city = json["city"];
    
    state = json["state"];
    country = json["country"];
    username = json["username"];
    firstName = json["first_name"];
    lastName = json["last_name"];
    email = json["email"];
    // if (json["user"] is Map) {
    //   user = json["user"] == null ? null : User1.fromJson(json["user"]);
    // }
    if (json["following_status"] is bool) {
      following = json["following_status"];
    }
    if (json["following_requests_status"] is bool) {
      followingRequests = json["following_requests_status"];
    }
    if (json["block_list"] is List) {
      blockList = json["block_list"] ?? [];
    }
    if (json["hide_suggestion_list"] is List) {
      hideSuggestionList = json["hide_suggestion_list"] ?? [];
    }
    if (json["groups"] is List) {
      groups = json["groups"] ?? [];
    }
    if (json["user_permissions"] is List) {
      userPermissions = json["user_permissions"] ?? [];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
  }

  static List<User> fromList(List<Map<String, dynamic>> list) {
    return list.map(User.fromJson).toList();
  }

  User copyWith({
    int? id,
    dynamic dob,
    dynamic phone,
    String? gender,
    dynamic biography,
    String? eyes,
   
    String? dp,
    dynamic backgroundImage,
    dynamic city,
    dynamic state,
    dynamic country,
    // User1? user,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? following,
    bool? followingRequests,
    List<dynamic>? blockList,
    List<dynamic>? hideSuggestionList,
    List<dynamic>? groups,
    List<dynamic>? userPermissions,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      biography: biography ?? this.biography,
      dp: dp ?? this.dp,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName, 
      email: email ?? this.email,

      // user: user ?? this.user,
      following: following ?? this.following,
      followingRequests: followingRequests ?? this.followingRequests,
      blockList: blockList ?? this.blockList,
      hideSuggestionList: hideSuggestionList ?? this.hideSuggestionList,
      groups: groups ?? this.groups,
      userPermissions: userPermissions ?? this.userPermissions,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["dob"] = dob;
    data["phone"] = phone;
    data["gender"] = gender;
 
    data["biography"] = biography;
    data["dp"] = dp;
    data["background_image"] = backgroundImage;
    data["city"] = city;
    data["state"] = state;
    data["country"] = country;
    // if (user != null) {
    //   _data["user"] = user?.toJson();
    // }
    data["username"] = username;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["email"] = email;
    if (following != null) {
      data["following"] = following;
    }
    if (followingRequests != null) {
      data["following_requests"] = followingRequests;
    }
    if (blockList != null) {
      data["block_list"] = blockList;
    }
    if (hideSuggestionList != null) {
      data["hide_suggestion_list"] = hideSuggestionList;
    }
    if (groups != null) {
      data["groups"] = groups;
    }
    if (userPermissions != null) {
      data["user_permissions"] = userPermissions;
    }
    data["name"] = name;

    return data;
  }
}

class User2 {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;

  User2({this.id, this.username, this.firstName, this.lastName, this.email});

  User2.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["username"] is String) {
      username = json["username"];
    }
    if (json["first_name"] is String) {
      firstName = json["first_name"];
    }
    if (json["last_name"] is String) {
      lastName = json["last_name"];
    }
    if (json["email"] is String) {
      email = json["email"];
    }
  }

  static List<User2> fromList(List<Map<String, dynamic>> list) {
    return list.map(User2.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["username"] = username;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["email"] = email;
    return data;
  }
}

class User1 {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;

  User1({this.id, this.username, this.firstName, this.lastName, this.email});

  User1.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["username"] is String) {
      username = json["username"];
    }
    if (json["first_name"] is String) {
      firstName = json["first_name"];
    }
    if (json["last_name"] is String) {
      lastName = json["last_name"];
    }
    if (json["email"] is String) {
      email = json["email"];
    }
  }

  static List<User1> fromList(List<Map<String, dynamic>> list) {
    return list.map(User1.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["username"] = username;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["email"] = email;
    return data;
  }
}

class Media {
  int? id;
  String? file;
  String? fileType;
  int? user;

  Media({this.id, this.file, this.fileType, this.user});

  Media.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    file = json["file"];
    fileType = json["file_type"];
    user = json["user"];
  }

  static List<Media> fromList(List<Map<String, dynamic>> list) {
    return list.map(Media.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["file"] = file;
    data["file_type"] = fileType;
    data["user"] = user;
    return data;
  }
}
