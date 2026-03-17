import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/failure.dart';

abstract class KirtiRepo {
  Future<Either<Failure, CustomResponse>> createRazorpayOrder({
    required String name,
    required String mobileNumber,
    required String address,
    required String serviceId,
    required String plan,
    required List<int> addOns,
    required String scheduledDatetime,
  });
   Future<Either<Failure, CustomResponse>> fetchFilterOptions();
  Future<Either<Failure, CustomResponse>> fetchServiceData( );
  Future<Either<Failure, CustomResponse>> confirmOrder(String orderId,int jobId);
  Future<Either<Failure, CustomResponse>> fetchSingleServiceData(String id);
  Future<Either<Failure, CustomResponse>> fetchOderData({int page, String? status});
  Future<Either<Failure, CustomResponse>> deleteSkillData(String skillId);
  Future<Either<Failure, CustomResponse>> fetchOderDataAsgined({int page});
  Future<Either<Failure, CustomResponse>> fetchNewOrderData({int page});
  Future<Either<Failure, CustomResponse>> fetchCompletedOrderData({int page});
  Future<Either<Failure, CustomResponse>> fetchConfirmedOrderData({int page});
  
  Future<Either<Failure, CustomResponse>> fetchAdminOrderDetail({String? orderId, String? status});
  Future<Either<Failure, CustomResponse>> fetchAdminOrderDetailConfirmed({String? orderId});
  Future<Either<Failure, CustomResponse>> fetchAdminOrderDetailAssigned({String? orderId});
  Future<Either<Failure, CustomResponse>> sigleOrder(String id);
  Future<Either<Failure, CustomResponse>> fetchAddOnsData();
  Future<Either<Failure, CustomResponse>> downloadInvoice(String orderId);
  Future<Either<Failure, CustomResponse>> createOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required bool paymentStatus,
    required int plan,
    required List<int> addOns,
    required int serviceSection,
    required String scheduledDatetime,
    required String name,
    required String address,
    required String mobileNumber,
  });

  Future<Either<Failure, CustomResponse>> updateOrderStatus(
      int orderId, String newStatus);
  Future<Either<Failure, CustomResponse>> cancelOrder(int orderId);
  Future<Either<Failure, CustomResponse>> markOrderAsComplete(int orderId);
  Future<Either<Failure, CustomResponse>> reorderService(int orderId);
  Future<Either<Failure, CustomResponse>> fetchRoleData();
  Future<Either<Failure, CustomResponse>> fetchCategoryData(String? roleId);
  Future<Either<Failure, CustomResponse>> fetchExpertiseData(
      String? roleId, String? categoryId);
  Future<Either<Failure, CustomResponse>> updateSkillData(
      String? skillId,
      String? categoryId,
      String? expertiseId,
      String? available,
      String? about,
      String? experience,
      String? travelPreference,
      List<File> image);
  Future<Either<Failure, CustomResponse>> fetchSkillData(String id);
  Future<Either<Failure, CustomResponse>> updateOrderData(
      String addOns,
      String mobileNumber,
      String name,
      String plan,
      String scheduledDatetime,
      String serviceSection);
  Future<Either<Failure, CustomResponse>> updateDonatePayment(
      String donationId);

  /// Available pandits for an order based on expertise IDs
  /// Supports pagination with page parameter
  Future<Either<Failure, CustomResponse>> fetchAvailablePandits({
    required int? orderId,
    required List<int> expertiseIds,
    String? query,
    int page = 1,
  });

  /// Request/Assign pandits to an order based on pandit IDs (RoleRegister IDs)
  Future<Either<Failure, CustomResponse>> requestPandits({
    required int orderId,
    required List<int> panditIds,
  });

  Future<Either<Failure, CustomResponse>> submitFeedback({
    required int orderId,
    required int rating,
    String? review,
  });

  /// Fetch pandit jobs (jobs assigned to the logged-in pandit)
  /// Status values: "Assigned" (New), "Processing", "Delivered"
  Future<Either<Failure, CustomResponse>> fetchPanditJobs({
    int page = 1,
    String? jobId,
    String? status, // "Assigned", "Processing", "Delivered"
  });

  /// Pandit respond to job (accept/reject)
  /// API: apis/Orders/{orderId}/pandit-respond/
  /// Body: {"response": "accept"} or {"response": "reject"}
  Future<Either<Failure, CustomResponse>> panditRespondToJob({
    required int orderId,
    required String response, // "accept" or "reject"
  });

  /// Submit pandit feedback for a job
  /// API: apis/Orders/{orderId}/pandit-feedback/
  /// Body: {"rating": 4, "comments": "nice"}
  Future<Either<Failure, CustomResponse>> submitPanditFeedback({
    required int orderId,
    required int rating,
    String? comments,
  });

  /// Fetch experience data
  Future<Either<Failure, CustomResponse>> fetchExperienceData();

  /// Fetch bank account details
  Future<Either<Failure, CustomResponse>> fetchBankAccounts();

  /// Save/Update bank account details
  Future<Either<Failure, CustomResponse>> saveBankAccounts({
    required String accountName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    String? upiId,
  });

  /// Fetch help contact information (email and contact number)
  Future<Either<Failure, CustomResponse>> fetchHelpContact();
}
