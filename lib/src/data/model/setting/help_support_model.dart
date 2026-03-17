// To parse this JSON data, do
//
//     final helpSupportModel = helpSupportModelFromJson(jsonString);

import 'dart:convert';

List<HelpSupportModel> helpSupportModelFromJson(String str) => List<HelpSupportModel>.from(json.decode(str).map((x) => HelpSupportModel.fromJson(x)));

String helpSupportModelToJson(List<HelpSupportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HelpSupportModel {
  int? id;
  String? name;
  Details? details;

  HelpSupportModel({
    this.id,
    this.name,
    this.details,
  });

  factory HelpSupportModel.fromJson(Map<String, dynamic> json) => HelpSupportModel(
    id: json["id"],
    name: json["name"],
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "details": details?.toJson(),
  };
}

class Details {
  String? delta;
  String? html;

  Details({
    this.delta,
    this.html,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    delta: json["delta"],
    html: json["html"],
  );

  Map<String, dynamic> toJson() => {
    "delta": delta,
    "html": html,
  };
}
