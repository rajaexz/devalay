// To parse this JSON data, do
//
//     final serviceModel = serviceModelFromJson(jsonString);

import 'dart:convert';

List<ServiceModel> serviceModelFromJson(String str) => List<ServiceModel>.from(json.decode(str).map((x) => ServiceModel.fromJson(x)));

String serviceModelToJson(List<ServiceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ServiceModel {
    int id;
    List<Service> service;
    String name;
    Benefits benefits;
    Benefits steps;
    dynamic description;
    String? duration;
    String? images;
    int star;
    List<Plan> plans;

    ServiceModel({
        required this.id,
        required this.service,
        required this.name,
        required this.benefits,
        required this.steps,
        required this.description,
        required this.duration,
        required this.images,
        required this.star,
        required this.plans,
    });

    factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json["id"],
        service: List<Service>.from(json["service"].map((x) => Service.fromJson(x))),
        name: json["name"],
        benefits: Benefits.fromJson(json["benefits"]),
        steps: Benefits.fromJson(json["steps"]),
        description: json["description"],
        duration: json["duration"],
        images: json["images"],
        star: json["star"],
        plans: List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "service": List<dynamic>.from(service.map((x) => x.toJson())),
        "name": name,
        "benefits": benefits.toJson(),
        "steps": steps.toJson(),
        "description": description,
        "duration": duration,
        "images": images,
        "star": star,
        "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
    };
}

class Benefits {
    String delta;
    String html;

    Benefits({
        required this.delta,
        required this.html,
    });

    factory Benefits.fromJson(Map<String, dynamic> json) => Benefits(
        delta: json["delta"],
        html: json["html"],
    );

    Map<String, dynamic> toJson() => {
        "delta": delta,
        "html": html,
    };
}

class Plan {
    int id;
    String type;
    double price;
    dynamic description;
    int pooja;

    Plan({
        required this.id,
        required this.type,
        required this.price,
        required this.description,
        required this.pooja,
    });

    factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        type: json["type"],
        price: json["price"],
        description: json["description"],
        pooja: json["pooja"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "price": price,
        "description": description,
        "pooja": pooja,
    };
}

class Service {
    int id;
    String type;

    Service({
        required this.id,
        required this.type,
    });

    factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
    };
}
