import 'package:devalay_app/src/data/model/kirti/order_model.dart';

abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {
  List<OrderModel>? orderList;
   OrderModel? sigleData;
  bool isLoading;
  String errorMessage;
  bool hasMore;
  String? helpContactEmail;
  String? helpContactNumber;
  OrderLoadingState({
    this.orderList,
    this.sigleData,
  this.hasMore = false,
    this.isLoading = false,
    this.errorMessage = '',
    this.helpContactEmail,
    this.helpContactNumber,
  });
}
