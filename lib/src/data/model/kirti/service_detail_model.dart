import 'dart:convert';

ServiceDetailModel serviceDetailModelFromJson(String str) =>
    ServiceDetailModel.fromJson(json.decode(str));

String serviceDetailModelToJson(ServiceDetailModel data) =>
    json.encode(data.toJson());

class ServiceDetailModel {
  int? id;
  List<Service>? service;
  String? name;
  Benefits? benefits;
  Benefits? steps;
  Benefits? description;
  String? duration;
  String? images;
  int? star;
  List<Plan>? plans;

  ServiceDetailModel({
    this.id,
    this.service,
    this.name,
    this.benefits,
    this.steps,
    this.description,
    this.duration,
    this.images,
    this.star,
    this.plans,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) =>
      ServiceDetailModel(
        id: json["id"],
        service: json["service"] == null
            ? []
            : List<Service>.from(
                json["service"].map((x) => Service.fromJson(x))),
        name: json["name"] ?? "",
        benefits: json["benefits"] != null
            ? Benefits.fromJson(json["benefits"])
            : null,
        steps: json["steps"] != null 
            ? Benefits.fromJson(_ensureMap(json["steps"])) 
            : null,
        description: json["description"] != null
            ? Benefits.fromJson(_ensureMap(json["description"]))
            : null,
        duration: json["duration"] ?? "",
        images: json["images"] ?? "",
        star: json["star"] ?? 0,
        plans: json["plans"] == null
            ? []
            : List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
      );

  // Helper method to handle both Map and String inputs
  static Map<String, dynamic> _ensureMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    } else if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return {"delta": value, "html": value};
      }
    }
    return {};
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service == null
            ? []
            : List<dynamic>.from(service!.map((x) => x.toJson())),
        "name": name,
        "benefits": benefits?.toJson(),
        "steps": steps?.toJson(),
        "description": description?.toJson(),
        "duration": duration,
        "images": images,
        "star": star,
        "plans": plans == null
            ? []
            : List<dynamic>.from(plans!.map((x) => x.toJson())),
      };
}

class Benefits {
  String? delta;
  String? html;

  Benefits({
    this.delta,
    this.html,
  });

  factory Benefits.fromJson(Map<String, dynamic> json) => Benefits(
        delta: json["delta"] is String 
            ? json["delta"] 
            : jsonEncode(json["delta"] ?? ""),
        html: json["html"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "delta": delta,
        "html": html,
      };
}
class Plan {
  int? id;
  String? type;
  double? price;
  Benefits? description;
  int? pooja;

  Plan({
    this.id,
    this.type,
    this.price,
    this.description,
    this.pooja,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        type: json["type"] ?? "",
        price: json["price"] != null
            ? (json["price"] as num).toDouble()
            : 0.0,
        description: _planDescriptionFromJson(json["description"]),
        pooja: json["pooja"],
      );

  /// Handles description as object { html, delta } or as raw HTML string.
  static Benefits? _planDescriptionFromJson(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return Benefits.fromJson(value);
    }
    if (value is String && value.trim().isNotEmpty) {
      return Benefits(html: value, delta: null);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "price": price,
        "description": description?.toJson(),
        "pooja": pooja,
      };
}

class Service {
  int? id;
  String? type;

  Service({
    this.id,
    this.type,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        type: json["type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
      };
}
