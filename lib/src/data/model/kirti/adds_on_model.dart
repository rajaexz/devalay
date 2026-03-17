// To parse this JSON data, do
//
//     final addsOnModel = addsOnModelFromJson(jsonString);

import 'dart:convert';

List<AddsOnModel> addsOnModelFromJson(String str) => List<AddsOnModel>.from(json.decode(str).map((x) => AddsOnModel.fromJson(x)));

String addsOnModelToJson(List<AddsOnModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddsOnModel {
    int? id;
    String? title;
    double? price;
    String? quantity;

    AddsOnModel({
        this.id,
        this.title,
        this.price,
        this.quantity,
    });

    factory AddsOnModel.fromJson(Map<String, dynamic> json) => AddsOnModel(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "quantity": quantity,
    };
}
