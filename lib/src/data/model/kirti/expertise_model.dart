// To parse this JSON data, do
//
//     final languageModel = languageModelFromJson(jsonString);

import 'dart:convert';

List<ExpertiseModel> expertiseModelFromJson(String str) => List<ExpertiseModel>.from(json.decode(str).map((x) => ExpertiseModel.fromJson(x)));

String expertiseModelToJson(List<ExpertiseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpertiseModel {
  int? id;
  String? expertise;

  ExpertiseModel({
    this.id,
    this.expertise,
  });

  factory ExpertiseModel.fromJson(Map<String, dynamic> json) => ExpertiseModel(
    id: json["id"],
    expertise: json["expertise"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "expertise": expertise,
  };
}
