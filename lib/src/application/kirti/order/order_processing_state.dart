import 'package:devalay_app/src/data/model/kirti/order_model.dart';

abstract class OrderProcessingState {}

class OrderProcessingInitialState extends OrderProcessingState {}

class OrderProcessingLoadingState extends OrderProcessingState {
  List<OrderModel>? orderList;
  bool isLoading;
  String errorMessage;
  
  OrderProcessingLoadingState({
    this.orderList,
    this.isLoading = false,
    this.errorMessage = '',
  });
} 