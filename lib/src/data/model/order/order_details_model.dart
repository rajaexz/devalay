class OrderStatusStep {
  final String label;
  final String? date;
  OrderStatusStep({required this.label, this.date});
}

class OrderDetailsModel {
  final String orderId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<OrderStatusStep> statusSteps;
  final int currentStep;
  final bool isCompleted;
  final bool isConfirmed;
  final List<Map<String, dynamic>> summaryRows;
  final String? infoNote;
  final bool canCancel;
  final bool showFeedback;

  OrderDetailsModel({
    required this.orderId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.statusSteps,
    required this.currentStep,
    required this.isCompleted,
    required this.isConfirmed,
    required this.summaryRows,
    this.infoNote,
    this.canCancel = false,
    this.showFeedback = false,
  });
} 