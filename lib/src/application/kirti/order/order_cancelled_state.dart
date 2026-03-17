import 'package:devalay_app/src/data/model/kirti/order_model.dart';

abstract class OrderCancelledState {}

class OrderCancelledInitialState extends OrderCancelledState {}

class OrderCancelledLoadingState extends OrderCancelledState {
  List<OrderModel>? orderList;
  bool isLoading;
  String errorMessage;
  
  OrderCancelledLoadingState({
    this.orderList,
    this.isLoading = false,
    this.errorMessage = '',
  });
} 