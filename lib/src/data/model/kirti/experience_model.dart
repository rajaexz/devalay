
class ExperienceModel {
  final int? id;
  final String? name;

  ExperienceModel({this.id, this.name});

  // ✅ Add fromJson factory
  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  // ✅ Add toJson method (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}