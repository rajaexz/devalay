// To parse this JSON data, do
//
//     final globleSearch = globleSearchFromJson(jsonString);

import 'dart:convert';

GlobleSearch globleSearchFromJson(String str) => GlobleSearch.fromJson(json.decode(str));

String globleSearchToJson(GlobleSearch data) => json.encode(data.toJson());

class GlobleSearch {
    List<Result>? results;
    bool? hasNext;
    bool? hasPrevious;
    dynamic nextPageNumber;
    dynamic previousPageNumber;
    int? dataFrom;
    int? dataTo;
    int? totalData;
    Paginator? paginator;
    int? number;

    GlobleSearch({
        this.results,
        this.hasNext,
        this.hasPrevious,
        this.nextPageNumber,
        this.previousPageNumber,
        this.dataFrom,
        this.dataTo,
        this.totalData,
        this.paginator,
        this.number,
    });

    GlobleSearch copyWith({
        List<Result>? results,
        bool? hasNext,
        bool? hasPrevious,
        dynamic nextPageNumber,
        dynamic previousPageNumber,
        int? dataFrom,
        int? dataTo,
        int? totalData,
        Paginator? paginator,
        int? number,
    }) => 
        GlobleSearch(
            results: results ?? this.results,
            hasNext: hasNext ?? this.hasNext,
            hasPrevious: hasPrevious ?? this.hasPrevious,
            nextPageNumber: nextPageNumber ?? this.nextPageNumber,
            previousPageNumber: previousPageNumber ?? this.previousPageNumber,
            dataFrom: dataFrom ?? this.dataFrom,
            dataTo: dataTo ?? this.dataTo,
            totalData: totalData ?? this.totalData,
            paginator: paginator ?? this.paginator,
            number: number ?? this.number,
        );

    factory GlobleSearch.fromJson(Map<String, dynamic> json) => GlobleSearch(
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
        hasNext: json["has_next"],
        hasPrevious: json["has_previous"],
        nextPageNumber: json["next_page_number"],
        previousPageNumber: json["previous_page_number"],
        dataFrom: json["data_from"],
        dataTo: json["data_to"],
        totalData: json["total_data"],
        paginator: json["paginator"] == null ? null : Paginator.fromJson(json["paginator"]),
        number: json["number"],
    );

    Map<String, dynamic> toJson() => {
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
        "has_next": hasNext,
        "has_previous": hasPrevious,
        "next_page_number": nextPageNumber,
        "previous_page_number": previousPageNumber,
        "data_from": dataFrom,
        "data_to": dataTo,
        "total_data": totalData,
        "paginator": paginator?.toJson(),
        "number": number,
    };
}

class Paginator {
    int? numPages;

    Paginator({
        this.numPages,
    });

    Paginator copyWith({
        int? numPages,
    }) => 
        Paginator(
            numPages: numPages ?? this.numPages,
        );

    factory Paginator.fromJson(Map<String, dynamic> json) => Paginator(
        numPages: json["num_pages"],
    );

    Map<String, dynamic> toJson() => {
        "num_pages": numPages,
    };
}

class Result {
    int? id;
    String? title;
    String? description;
    String? location;
    String? tableName;
    dynamic image;
    String? dp;
    String? followersCount;
    String? postsCount;
    String? backgroundImage;
    String? name;
    String? email;
    String? biography;
    String? phone;
    String? thumbnailUrl;

    Result({
        this.id,
        this.title,
        this.description,
        this.tableName,
        this.image,
        this.followersCount,
        this.postsCount,
        this.location,
        this.dp,
        this.backgroundImage,
        this.name,
        this.email,
        this.biography,
        this.phone,
        this.thumbnailUrl,
    });

    Result copyWith({
        int? id,
        String? title,
        String? description,
        String? tableName,
        dynamic image,
        String? dp,
        String? followersCount,
        String? postsCount,
        String? backgroundImage,
        String? name,
        String? email,
        String? biography,
        String? phone,
        String? thumbnailUrl,
    }) => 
        Result(
            id: id ?? this.id,
            title: title ?? this.title,
            description: description ?? this.description,
            tableName: tableName ?? this.tableName,
            image: image ?? this.image,
            dp: dp ?? this.dp,
            followersCount: followersCount ?? this.followersCount,
            postsCount: postsCount ?? this.postsCount,
            backgroundImage: backgroundImage ?? this.backgroundImage,
            name: name ?? this.name,
            email: email ?? this.email,
            biography: biography ?? this.biography,
            phone: phone ?? this.phone,
            thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        );

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        tableName: json["table_name"],
        followersCount: json["followers_count"] ?? "0",
        postsCount: json["posts_count"] ?? "0",
        image: json["image"],
        location: json["location"] ?? "Noida Scetor 15",
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        email: json["email"],
        biography: json["biography"],
        phone: json["phone"],
        thumbnailUrl: json["table_name"] == "User"
            ? json["dp"]
            : _extractThumbnailFromImage(json["images"]),
        
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "table_name": tableName,
        "image": image,
        "dp": dp,
        "background_image": backgroundImage,
        "name": name,
        "email": email,
        "biography": biography,
        "phone": phone,
        "thumbnail_url": thumbnailUrl,
    };
}

String? _extractThumbnailFromImage(dynamic imageData) {
  if (imageData is Map) {
    final dynamic imagesObj = imageData["images"] ?? imageData;

    if (imagesObj is Map) {
      final dynamic gallery = imagesObj["Gallery"];
      if (gallery is List && gallery.isNotEmpty) {
        final dynamic firstImage = gallery.first;
        if (firstImage is Map && firstImage["image"] != null) {
          return firstImage["image"].toString();
        }
      }

      final dynamic banner = imagesObj["Banner"];
      if (banner is List && banner.isNotEmpty) {
        final dynamic firstBanner = banner.first;
        if (firstBanner is Map && firstBanner["image"] != null) {
          return firstBanner["image"].toString();
        }
      }
    }
  }
  return null;
}
