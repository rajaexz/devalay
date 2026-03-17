import 'package:devalay_app/src/data/model/profile/profile_info_model.dart';

class ExploreUser {
  int? id;
  String? dob;
  String? phone;
  String? gender;
  String? biography;
  String? dp;
  String? backgroundImage;
  String? city;
  String? state;
  String? country;
  bool? followingRequestsStatus;
  bool? followingStatus;
  String? name;
  String? email;
  List<FollowersRequestElement>? followersRequests;
  List<FollowersRequestElement>? followers;
  bool? following;
  bool? followingRequests;
  int? postCount;
  // New fields from API response
  String? title;
  String? description;
  String? image;
  String? tableName;
  int? addedById;

  ExploreUser({
    this.id,
    this.dob,
    this.phone,
    this.gender,
    this.biography,
    this.dp,
    this.backgroundImage,
    this.city,
    this.state,
    this.country,
    this.name,
    this.email,
    this.followingRequestsStatus,
    this.followingStatus,
    this.followersRequests,
    this.followers,
    this.following,
    this.followingRequests,
    this.postCount,
    this.title,
    this.description,
    this.image,
    this.tableName,
    this.addedById,
  });

  factory ExploreUser.fromJson(Map<String, dynamic> json) {
    return ExploreUser(
      id: json['id'],
      // Map 'title' to 'name' if 'name' is not present
      name: json['name'] ?? json['title'],
      // Map 'image' to 'dp' if 'dp' is not present
      dp: json['dp'] ?? json['image'],
      // Map 'description' to 'biography' if 'biography' is not present
      biography: json['biography'] ?? json['description'],
      // New API fields
      title: json['title'],
      description: json['description'],
      image: json['image'],
      tableName: json['table_name'],
      addedById: json['added_by_id'],
      // Existing fields (may not be in search API response)
      dob: json['dob'],
      phone: json['phone'],
      gender: json['gender'],
      backgroundImage: json['background_image'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      followingRequestsStatus: json['following_requests_status'],
      followingStatus: json['following_status'],
      email: json["email"],
      followersRequests: json['followers_requests'] != null
          ? (json['followers_requests'] as List)
              .map((e) => FollowersRequestElement.fromJson(e))
              .toList()
          : [],
      followers: json['followers'] != null
          ? (json['followers'] as List)
          .map((e) => FollowersRequestElement.fromJson(e))
          .toList()
          : [],
      following: json['following'] is bool ? json['following'] : false,
      followingRequests: json['following_requests'] is bool
          ? json['following_requests']
          : false,
      postCount: json['post_count'],
    );
  }

  static List<ExploreUser> fromList(List<dynamic> jsonList) {
    return jsonList.map((e) => ExploreUser.fromJson(e)).toList();
  }
}
