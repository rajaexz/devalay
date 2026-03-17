class ReportReason {
  final int id;
  final String label;

  ReportReason({required this.id, required this.label});

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      id: json['id'],
      label: json['label'],
    );
  }
}
