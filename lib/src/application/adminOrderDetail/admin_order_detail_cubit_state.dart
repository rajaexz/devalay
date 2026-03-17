// admin_order_detail_state.dart

import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';

abstract class AdminOrderDetailState {}

class AdminOrderDetailInitial extends AdminOrderDetailState {}

class AdminOrderDetailLoading extends AdminOrderDetailState {
  final AdminOrderDetailModel? order;
  final bool isLoading;
  final String errorMessage;

  AdminOrderDetailLoading({
    this.order,
    this.isLoading = false,
    this.errorMessage = '',
  });
}

class AdminOrderDetailLoaded extends AdminOrderDetailState {
  final AdminOrderDetailModel order;

  AdminOrderDetailLoaded({required this.order});
}

class AdminOrderDetailError extends AdminOrderDetailState {
  final String errorMessage;

  AdminOrderDetailError({required this.errorMessage});
}

class AdminOrderDetailRefreshing extends AdminOrderDetailState {
  final AdminOrderDetailModel order;

  AdminOrderDetailRefreshing({required this.order});
}