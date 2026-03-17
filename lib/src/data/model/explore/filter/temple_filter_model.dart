// To parse this JSON data, do
//
//     final templeFilterModel = templeFilterModelFromJson(jsonString);

import 'dart:convert';

TempleFilterModel templeFilterModelFromJson(String str) => TempleFilterModel.fromJson(json.decode(str));

String templeFilterModelToJson(TempleFilterModel data) => json.encode(data.toJson());

class TempleFilterModel {
    List<Location>? location;
    List<Dev>? dev;
    List<dynamic>? ordering;

    TempleFilterModel({
        this.location,
        this.dev,
        this.ordering,
    });

    factory TempleFilterModel.fromJson(Map<String, dynamic> json) => TempleFilterModel(
        location: json["Location"] == null ? [] : List<Location>.from(json["Location"]!.map((x) => Location.fromJson(x))),
        dev: json["Dev"] == null ? [] : List<Dev>.from(json["Dev"]!.map((x) => Dev.fromJson(x))),
        ordering: json["Ordering"] == null ? [] : List<dynamic>.from(json["Ordering"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Location": location == null ? [] : List<dynamic>.from(location!.map((x) => x.toJson())),
        "Dev": dev == null ? [] : List<dynamic>.from(dev!.map((x) => x.toJson())),
        "Ordering": ordering == null ? [] : List<dynamic>.from(ordering!.map((x) => x)),
    };
}

class Dev {
    String? title;
    DevFilter? filter;

    Dev({
        this.title,
        this.filter,
    });

    factory Dev.fromJson(Map<String, dynamic> json) => Dev(
        title: json["title"],
        filter: json["filter"] == null ? null : DevFilter.fromJson(json["filter"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "filter": filter?.toJson(),
    };
}

class DevFilter {
    String? dev;

    DevFilter({
        this.dev,
    });

    factory DevFilter.fromJson(Map<String, dynamic> json) => DevFilter(
        dev: json["dev"],
    );

    Map<String, dynamic> toJson() => {
        "dev": dev,
    };
}

class Location {
    String? title;
    LocationFilter? filter;

    Location({
        this.title,
        this.filter,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        title: json["title"],
        filter: json["filter"] == null ? null : LocationFilter.fromJson(json["filter"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "filter": filter?.toJson(),
    };
}

class LocationFilter {
    String? country;
    String? state;
    String? city;

    LocationFilter({
        this.country,
        this.state,
        this.city,
    });

    factory LocationFilter.fromJson(Map<String, dynamic> json) => LocationFilter(
        country: json["country"],
        state: json["state"],
        city: json["city"],
    );

    Map<String, dynamic> toJson() => {
        "country": country,
        "state": state,
        "city": city,
    };
}
