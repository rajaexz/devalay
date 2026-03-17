class NotificationModel {
  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final String? notificationMsge;
  final int? objectId;
  final bool? isRead;
  final String? type;
  final ActionUser? actionUser;
  final int? targetUser;
  final int? contentType;
  final PostModel? post;
  final dynamic postcomment;
  final dynamic extraPayload;

  NotificationModel({
    this.id,
    this.createdAt,
    this.type,
    this.updatedAt,
    this.notificationMsge,
    this.objectId,
    this.isRead,
    this.actionUser,
    this.targetUser,
    this.contentType,
    this.post,
    this.postcomment,
    this.extraPayload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      notificationMsge: json['notification_msge'],
      objectId: json['object_id'],
      isRead: json['is_read'],
      actionUser: json['action_user'] != null
          ? ActionUser.fromJson(json['action_user'])
          : null,
      targetUser: json['target_user'],
      contentType: json['content_type'],
      type: json['type'],
      post: (json['post'] != null && json['post'] is Map<String, dynamic>)
          ? PostModel.fromJson(json['post'])
          : null,
      postcomment: json['postcomment'],
      extraPayload: json['extra_payload'],
    );
  }

  NotificationModel copyWith({
    int? id,
    String? createdAt,
    String? updatedAt,
    String? notificationMsge,
    int? objectId,
    bool? isRead,
    ActionUser? actionUser,
    String? type,
    int? targetUser,
    int? contentType,
    PostModel? post,
    dynamic postcomment,
    dynamic extraPayload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationMsge: notificationMsge ?? this.notificationMsge,
      objectId: objectId ?? this.objectId,
      isRead: isRead ?? this.isRead,
      actionUser: actionUser ?? this.actionUser,
      targetUser: targetUser ?? this.targetUser,
      contentType: contentType ?? this.contentType,
      type: type ?? this.type,
      post: post ?? this.post,
      postcomment: postcomment ?? this.postcomment,
      extraPayload: extraPayload ?? this.extraPayload,
    );
  }

  static List<NotificationModel> fromList(List<dynamic> jsonList) {
    return jsonList.map((e) => NotificationModel.fromJson(e)).toList();
  }
}

class ActionUser {
  final int? id;
  final String? dp;
  final String? backgroundImage;
  final String? name;
  final String? email;
  final String? state;
  final String? country;
  final bool? followingRequestsStatus;
  final bool? followingStatus;
  final String? biography;
  final String? tableName;
  final int? postCount;
  final List<UserModel>? following;
  final List<UserModel>? followers;

  ActionUser({
    this.id,
    this.dp,
    this.backgroundImage,
    this.name,
    this.email,
    this.state,
    this.country,
    this.followingRequestsStatus,
    this.followingStatus,
    this.biography,
    this.tableName,
    this.postCount,
    this.following,
    this.followers,
  });

  factory ActionUser.fromJson(Map<String, dynamic> json) {
    return ActionUser(
      id: json['id'],
      dp: json['dp'],
      backgroundImage: json['background_image'],
      name: json['name'],
      email: json['email'],
      state: json['state'],
      country: json['country'],
      followingRequestsStatus: json['following_requests_status'],
      followingStatus: json['following_status'],
      biography: json['biography'],
      tableName: json['table_name'],
      postCount: json['post_count'],
      following: json['following'] != null
          ? (json['following'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList()
          : null,
      followers: json['followers'] != null
          ? (json['followers'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList()
          : null,
    );
  }

  ActionUser copyWith({
    int? id,
    String? dp,
    String? backgroundImage,
    String? name,
    String? email,
    String? state,
    String? country,
    bool? followingRequestsStatus,
    bool? followingStatus,
    String? biography,
    String? tableName,
    int? postCount,
    List<UserModel>? following,
    List<UserModel>? followers,
  }) {
    return ActionUser(
      id: id ?? this.id,
      dp: dp ?? this.dp,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      name: name ?? this.name,
      email: email ?? this.email,
      state: state ?? this.state,
      country: country ?? this.country,
      followingRequestsStatus:
          followingRequestsStatus ?? this.followingRequestsStatus,
      followingStatus: followingStatus ?? this.followingStatus,
      biography: biography ?? this.biography,
      tableName: tableName ?? this.tableName,
      postCount: postCount ?? this.postCount,
      following: following ?? this.following,
      followers: followers ?? this.followers,
    );
  }

  String? get firstName {
    final nameParts = name?.split(' ') ?? [];
    return nameParts.isNotEmpty ? nameParts.first : null;
  }

  String? get lastName {
    final nameParts = name?.split(' ') ?? [];
    return nameParts.length > 1 ? nameParts.last : null;
  }
}

class PostModel {
  final int? id;
  final List<Media> media;
  final UserModel? user;
  final bool? blocked;
  final String? createdAt;
  final String? updatedAt;
  final TextContent? text;
  final bool? isTemple;
  final String? location;
  final bool? isPrivate;
  final bool? liked;
  final List<dynamic>? saved;
  final List<dynamic>? repost;
  final List<dynamic>? viewed;
  final List<int>? blockedBy;
  final List<dynamic>? tags;
  final bool? report;
  final int? commentsCount;
  final int? repostCount;
  final int? likedCount;
  final List<UserModel>? likedUsers;

  PostModel({
    this.id,
    this.media = const [],
    this.user,
    this.blocked,
    this.createdAt,
    this.updatedAt,
    this.text,
    this.isTemple,
    this.location,
    this.isPrivate,
    this.liked,
    this.saved,
    this.repost,
    this.viewed,
    this.blockedBy,
    this.tags,
    this.report,
    this.commentsCount,
    this.repostCount,
    this.likedCount,
    this.likedUsers,
  });
factory PostModel.fromJson(Map<String, dynamic> json) {
  return PostModel(
    id: json['id'],
    media: (json['media'] as List<dynamic>?)
            ?.map((e) => Media.fromJson(e))
            .toList() ??
        [],
    user: json['user'] != null && json['user'] is Map<String, dynamic> 
        ? UserModel.fromJson(json['user']) 
        : null,
    blocked: json['blocked'] is bool ? json['blocked'] : null,
    createdAt: json['created_at']?.toString(),
    updatedAt: json['updated_at']?.toString(),
    text: (json['text'] != null && json['text'] is Map<String, dynamic>)
        ? TextContent.fromJson(json['text'])
        : null,
    isTemple: json['is_temple'] is bool ? json['is_temple'] : null,
    location: json['location']?.toString(),
    isPrivate: json['is_private'] is bool ? json['is_private'] : null,
    liked: json['liked'] is bool ? json['liked'] : null,
    // Handle saved - can be bool or List
    saved: json['saved'] is List ? json['saved'] : null,
    // Handle repost - can be bool or List
    repost: json['repost'] is List ? json['repost'] : null,
    // Handle viewed - can be bool or List
    viewed: json['viewed'] is List ? json['viewed'] : null,
    blockedBy: json['blocked_by'] != null && json['blocked_by'] is List
        ? List<int>.from(json['blocked_by'])
        : null,
    // Handle tags - can be bool or List
    tags: json['tags'] is List ? json['tags'] : null,
    report: json['report'] is bool ? json['report'] : null,
    commentsCount: json['comments_count'] is int ? json['comments_count'] : null,
    repostCount: json['repost_count'] is int ? json['repost_count'] : null,
    likedCount: json['liked_count'] is int ? json['liked_count'] : null,
    likedUsers: json['liked_users'] != null && json['liked_users'] is List
        ? (json['liked_users'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => UserModel.fromJson(e))
            .toList()
        : null,
  );
}}

class TextContent {
  final String? delta;
  final String? html;

  TextContent({
    this.delta,
    this.html,
  });

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      delta: json['delta'],
      html: json['html'],
    );
  }
}

class Media {
  final int? id;
  final String? fileUrl;
  final String? file;
  final String? fileType;
  final int? user;

  Media({
    this.id,
    this.fileUrl,
    this.file,
    this.fileType,
    this.user,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      fileUrl: json['file_url'],
      file: json['file'],
      fileType: json['file_type'],
      user: json['user'],
    );
  }
}

class UserModel {
  final int? id;
  final String? dp;
  final String? backgroundImage;
  final String? name;
  final String? email;
  final String? state;
  final String? country;
  final bool? followingRequestsStatus;
  final bool? followingStatus;
  final String? biography;
  final String? city;
  final String? phone;
  final String? gender;
  final String? dob;

  UserModel({
    this.id,
    this.dp,
    this.backgroundImage,
    this.name,
    this.email,
    this.state,
    this.country,
    this.followingRequestsStatus,
    this.followingStatus,
    this.biography,
    this.city,
    this.phone,
    this.gender,
    this.dob,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      dp: json['dp'],
      backgroundImage: json['background_image'],
      name: json['name'],
      email: json['email'],
      state: json['state'],
      country: json['country'],
      followingRequestsStatus: json['following_requests_status'],
      followingStatus: json['following_status'],
      biography: json['biography'],
      city: json['city'],
      phone: json['phone'],
      gender: json['gender'],
      dob: json['dob'],
    );
  }
}