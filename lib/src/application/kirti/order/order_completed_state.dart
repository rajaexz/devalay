import 'package:devalay_app/src/data/model/kirti/order_model.dart';

abstract class OrderCompletedState {}

class OrderCompletedInitialState extends OrderCompletedState {}

class OrderCompletedLoadingState extends OrderCompletedState {
  List<OrderModel>? orderList;
  bool isLoading;
  String errorMessage;
  
  OrderCompletedLoadingState({
    this.orderList,
    this.isLoading = false,
    this.errorMessage = '',
  });
} 