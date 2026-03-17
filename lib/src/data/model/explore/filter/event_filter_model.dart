// To parse this JSON data, do
//
//     final eventFilterModel = eventFilterModelFromJson(jsonString);

import 'dart:convert';

EventFilterModel eventFilterModelFromJson(String str) => EventFilterModel.fromJson(json.decode(str));

String eventFilterModelToJson(EventFilterModel data) => json.encode(data.toJson());

class EventFilterModel {
    List<Location>? location;
    List<dynamic>? date;
    List<dynamic>? ordering;

    EventFilterModel({
        this.location,
        this.date,
        this.ordering,
    });

    factory EventFilterModel.fromJson(Map<String, dynamic> json) => EventFilterModel(
        location: json["Location"] == null ? [] : List<Location>.from(json["Location"]!.map((x) => Location.fromJson(x))),
        date: json["Date"] == null ? [] : List<dynamic>.from(json["Date"]!.map((x) => x)),
        ordering: json["Ordering"] == null ? [] : List<dynamic>.from(json["Ordering"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Location": location == null ? [] : List<dynamic>.from(location!.map((x) => x.toJson())),
        "Date": date == null ? [] : List<dynamic>.from(date!.map((x) => x)),
        "Ordering": ordering == null ? [] : List<dynamic>.from(ordering!.map((x) => x)),
    };
}

class Location {
    String? title;
    Filter? filter;

    Location({
        this.title,
        this.filter,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        title: json["title"],
        filter: json["filter"] == null ? null : Filter.fromJson(json["filter"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "filter": filter?.toJson(),
    };
}

class Filter {
    String? country;
    String? state;
    String? city;

    Filter({
        this.country,
        this.state,
        this.city,
    });

    factory Filter.fromJson(Map<String, dynamic> json) => Filter(
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
