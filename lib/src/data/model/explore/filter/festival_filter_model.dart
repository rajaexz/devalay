// To parse this JSON data, do
//
//     final festivalFilterModel = festivalFilterModelFromJson(jsonString);

import 'dart:convert';

FestivalFilterModel festivalFilterModelFromJson(String str) => FestivalFilterModel.fromJson(json.decode(str));

String festivalFilterModelToJson(FestivalFilterModel data) => json.encode(data.toJson());

class FestivalFilterModel {
    List<dynamic>? date;
    List<dynamic>? ordering;

    FestivalFilterModel({
        this.date,
        this.ordering,
    });

    factory FestivalFilterModel.fromJson(Map<String, dynamic> json) => FestivalFilterModel(
        date: json["Date"] == null ? [] : List<dynamic>.from(json["Date"]!.map((x) => x)),
        ordering: json["Ordering"] == null ? [] : List<dynamic>.from(json["Ordering"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Date": date == null ? [] : List<dynamic>.from(date!.map((x) => x)),
        "Ordering": ordering == null ? [] : List<dynamic>.from(ordering!.map((x) => x)),
    };
}
