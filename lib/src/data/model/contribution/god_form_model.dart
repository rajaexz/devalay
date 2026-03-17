// To parse this JSON data, do
//
//     final godFormModel = godFormModelFromJson(jsonString);

import 'dart:convert';

List<GodFormModel> godFormModelFromJson(String str) => List<GodFormModel>.from(json.decode(str).map((x) => GodFormModel.fromJson(x)));

String godFormModelToJson(List<GodFormModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GodFormModel {
    int? id;
    String? title;

    GodFormModel({
        this.id,
        this.title,
    });

    factory GodFormModel.fromJson(Map<String, dynamic> json) => GodFormModel(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}
