
import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/data/model/kirti/admin_card_model.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';

abstract class AssignState {}

class AssignInitialState extends AssignState {}

class AssignLoadingState extends AssignState {
  final List< OrderModel>? orderListAssigned;
 final List<AdminOrderResponseModel>? adminOrderList; 
  
  final List<JobModel>? jobList;
  final JobModel? singleJob;

  final OrderModel? singleOrder;
  final bool isLoading;
  final String errorMessage;







  AssignLoadingState({
    this.jobList,
    this.adminOrderList,
    this.singleJob,
        this.singleOrder,
  this.orderListAssigned,
    this.isLoading = false,
    this.errorMessage = '',
  });
}
