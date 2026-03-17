// To parse this JSON data, do
//
//     final donateModel = donateModelFromJson(jsonString);

import 'dart:convert';

DonateModel donateModelFromJson(String str) => DonateModel.fromJson(json.decode(str));

String donateModelToJson(DonateModel data) => json.encode(data.toJson());

class DonateModel {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  String? email;
  String? mobileNumber;
  String? message;
  double? amount;
  String? pan;
  bool? isPaid;
  int? user;
  dynamic temple;

  DonateModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.email,
    this.mobileNumber,
    this.message,
    this.amount,
    this.pan,
    this.isPaid,
    this.user,
    this.temple,
  });

  factory DonateModel.fromJson(Map<String, dynamic> json) => DonateModel(
    id: json["id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    name: json["name"],
    email: json["email"],
    mobileNumber: json["mobile_number"],
    message: json["message"],
    amount: json["amount"],
    pan: json["pan"],
    isPaid: json["is_paid"],
    user: json["user"],
    temple: json["temple"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "name": name,
    "email": email,
    "mobile_number": mobileNumber,
    "message": message,
    "amount": amount,
    "pan": pan,
    "is_paid": isPaid,
    "user": user,
    "temple": temple,
  };
}
