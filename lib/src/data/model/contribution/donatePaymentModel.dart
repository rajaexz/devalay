// To parse this JSON data, do
//
//     final donatePaymentModel = donatePaymentModelFromJson(jsonString);

import 'dart:convert';

DonatePaymentModel donatePaymentModelFromJson(String str) => DonatePaymentModel.fromJson(json.decode(str));

String donatePaymentModelToJson(DonatePaymentModel data) => json.encode(data.toJson());

class DonatePaymentModel {
  String? paymentUrl;

  DonatePaymentModel({
    this.paymentUrl,
  });

  factory DonatePaymentModel.fromJson(Map<String, dynamic> json) => DonatePaymentModel(
    paymentUrl: json["payment_url"],
  );

  Map<String, dynamic> toJson() => {
    "payment_url": paymentUrl,
  };
}
