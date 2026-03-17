import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_calling.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/failure.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/logger.dart';

@LazySingleton(as: KirtiRepo)
class KirtiRepositories extends KirtiRepo {
  @override
  Future<Either<Failure, CustomResponse>> fetchServiceData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: AppConstant.service);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
Future<Either<Failure, CustomResponse>> fetchFilterOptions() async {
  try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: AppConstant.location);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
}

 fetchAdminOrderDetailConfirmed({String? orderId}) async {
  try {
    final CustomResponse customResponse = await ApiCalling()
        .callApi(apiTypes: ApiTypes.get, url: '${AppConstant.adminDetailOrder}?id=$orderId&status=Confirmed');
    return right(customResponse);
  } on Exception catch (e) {
    return left(Failure.getDioException(e));
  }
}

  @override
  Future<Either<Failure, CustomResponse>> fetchAdminOrderDetailAssigned({String? orderId}) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: '${AppConstant.adminDetailOrder}?id=$orderId&status=Assigned');
      return right(customResponse);
    } on Exception catch (e) {
      return left(Failure.getDioException(e));
    }
  }


  @override
  Future<Either<Failure, CustomResponse>> confirmOrder(String orderId , jobId) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.post, url: '${AppConstant.order}/$orderId${AppConstant.adminConfirmOrder}',
  
          referer: "https://devalay.org/apis/Orders/$orderId${AppConstant.adminConfirmOrder}",
          
          data: {
            'job_id': jobId,
            'status': 'Accepted',
          },
        );
      return right(customResponse);
    } on Exception catch (e) {
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchAdminOrderDetail(
   {String? orderId, String? status}) async {
    try {
        print("---------------$orderId");
      // Use provided status or default to Pending for new orders
      final statusParam = status ?? 'Pending';
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: '${AppConstant.adminDetailOrder}?id=$orderId&status=$statusParam');

      return right(customResponse);
    } on Exception catch (e) {
      return left(Failure.getDioException(e));
    }
  }


  @override
  Future<Either<Failure, CustomResponse>> fetchSingleServiceData(
      String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: '${AppConstant.service}$id/');

      return right(customResponse);
    } on Exception catch (e) {
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> deleteSkillData(String skillId) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.delete, url: '/Role-register/$skillId/', referer: 'https://devalay.org/apis/Role-register/$skillId/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
//////============
  @override
  Future<Either<Failure, CustomResponse>> fetchOderDataAsgined(
      {int? page}) async {

    try {
      String url = "/Orders${AppConstant.adminOrder}?status=Assigned";
      if (page != null && page > 1) {
        url += "?page_number=$page";
      }

      final CustomResponse customResponse =
          await ApiCalling().callApi(apiTypes: ApiTypes.get, url: url);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
@override
Future<Either<Failure, CustomResponse>> fetchNewOrderData({int? page}) async {
  try {
    // ✅ Fix: Use '&' for additional query parameters, not '?'
    String url = "/Orders${AppConstant.adminOrder}?status=Pending";
    
    if (page != null && page > 1) {
      url += "&page_number=$page";  // Changed from '?' to '&'
    }

    print('🌐 API URL: $url');  // Debug log

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: url,
    );
    
    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}

@override
Future<Either<Failure, CustomResponse>> fetchCompletedOrderData({int? page}) async {
  try {
    String url = "/Orders${AppConstant.adminOrder}?status=Order Completed";
    
    if (page != null && page > 1) {
      url += "&page_number=$page";
    }

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: url,
    );
    
    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}

@override
Future<Either<Failure, CustomResponse>> fetchConfirmedOrderData({int? page}) async {
  try {
    String url = "/Orders${AppConstant.adminOrder}?status=Confirmed";
    
    if (page != null && page > 1) {
      url += "&page_number=$page";
    }

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: url,
    );
    
    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}
@override
Future<Either<Failure, CustomResponse>> downloadInvoice(String orderId) async {
  try {
    debugPrint('📥 Calling API to download invoice for order: $orderId');

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: '/orders/$orderId/invoice',
      referer: 'https://devalay.org/apis/orders/$orderId/invoice',
    );

    if (customResponse.statusCode == 200) {
      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file name
      final fileName = 'Invoice_$orderId.pdf';
      final filePath = '${directory?.path}/$fileName';

      // Write file
      final file = File(filePath);
      
      // Get bytes from response
      final bytes = customResponse.response?.data is List<int>
          ? customResponse.response!.data as List<int>
          : (customResponse.response?.data as String).codeUnits;
      
      await file.writeAsBytes(bytes);

      debugPrint('✅ Invoice saved at: $filePath');

      // Return success with file path
      return right(CustomResponse(
        statusCode: 200,
        response: Response(
          requestOptions: customResponse.response!.requestOptions,
          data: {'filePath': filePath, 'fileName': fileName},
        ),
      ));
    } else {
      throw Exception('Failed to download invoice: ${customResponse.statusCode}');
    }
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}
  @override
  Future<Either<Failure, CustomResponse>> fetchOderData({int? page, String? status}) async {
    // API uses page_number parameter for pagination
    try {
      String url = "${AppConstant.order}/";
      if (page != null && page > 1) {
        url += "?page_number=$page";
      }
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: url);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
     Future<Either<Failure, CustomResponse>> sigleOrder(String id) async {
    // /?limit=10&page=$page
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "${AppConstant.order}/$id/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchAddOnsData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: AppConstant.addOns);
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
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
  }) async {
    try {
      final data = {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'payment_status': paymentStatus,
        'plan': plan,
        'add_ons': addOns,
        'service_section': serviceSection,
        'scheduled_datetime': scheduledDatetime,
        'name': name,
        'address': address,
        'mobile_number': mobileNumber,
      };

      debugPrint('📤 Creating order with data: $data');

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: '${AppConstant.order}/payment-update/',
          data: jsonEncode(data),
          referer: "https://devalay.org/apis/Orders/payment-update/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final data = {
        'status': newStatus,
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: '${AppConstant.order}/$orderId/',
          data: jsonEncode(data),
          referer: "https://devalay.org/apis/Orders/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }


@override
Future<Either<Failure, CustomResponse>> updateSkillData(
  String? skillId,
  String? categoryId,
  String? expertiseId,
  String? available,
  String? about,
  String? experience,
  String? travelPreference,
  List<File> image
) async {
  try {
    FormData formData = FormData();

    // Add all required fields according to API
    formData.fields.add(MapEntry('role', skillId ?? ''));
    formData.fields.add(MapEntry('category', categoryId ?? ''));
    formData.fields.add(MapEntry('expertise', expertiseId ?? ''));
    formData.fields.add(MapEntry('experience', experience ?? ''));

    // Convert boolean string to actual boolean value
    String boolValue = 'false';
    if (available != null) {
      if (available.toLowerCase() == 'true' || available == '1') {
        boolValue = 'true';
      } else if (available.toLowerCase() == 'false' || available == '0') {
        boolValue = 'false';
      }
    }
    formData.fields.add(MapEntry('is_available_for_online', boolValue));
    formData.fields.add(MapEntry('abouts', about ?? ''));

    if (travelPreference != null && travelPreference.isNotEmpty) {
      formData.fields.add(MapEntry('travel_preference', travelPreference));
    }

    // Add images to FormData
    if (image.isNotEmpty) {
      for (int i = 0; i < image.length; i++) {
        String imagePath = image[i].path;
        
       
        String fileName = imagePath.split('/').last;
        
        
        formData.files.add(
          MapEntry(
            'skills_image', 
            await MultipartFile.fromFile(
              imagePath,
              filename: fileName,
            ),
          ),
        );
      }
    }

    print('=== Sending to API ===');
    for (var field in formData.fields) {
      print('${field.key}: ${field.value}');
    }
    print('Images count: ${formData.files.length}');

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.post,
      url: '/Role-register/',
      data: formData,
      referer: "https://devalay.org/apis/Role-register/",
    );

    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    print('API Error: $e');
    return left(Failure.getDioException(e));
  }
}
  
  @override
  Future<Either<Failure, CustomResponse>> fetchSkillData(String id) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/Role-register/$id/", referer: "https://devalay.org/apis/Role-register/$id/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> cancelOrder(int orderId) async {
    try {
     
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.delete,
          url: '${AppConstant.order}/$orderId/',
          referer: "https://devalay.org/apis/Orders/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> markOrderAsComplete(int orderId) async {
    try {
      final data = {
        'is_completed': true,
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: '${AppConstant.order}/$orderId/complete-order/',
        data: jsonEncode(data),
        referer: 'https://devalay.org/apis/Orders/$orderId/complete-order/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> reorderService(int orderId) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: '${AppConstant.order}/$orderId/reorder/',
          referer: "https://devalay.org/apis/Orders/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchRoleData() async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/role/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchCategoryData(String? roleId) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/role/?role=$roleId");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchExpertiseData(String? roleId, String? categoryId) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/role/?role=$roleId&category=$categoryId");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
  
@override
Future<Either<Failure, CustomResponse>> fetchAvailablePandits({
  required int? orderId,
  required List<int> expertiseIds,
  String? query,
  int page = 1,
}) async {
  try {
    // Build query parameters
    List<String> queryParts = [];
    
    // Add page parameter
    queryParts.add('page=$page');
    
    for (var id in expertiseIds) {
      queryParts.add('expertise_ids=$id');
    }
    
    // Join all query parameters
    final queryString = queryParts.join('&');
    final url = "/Orders/$orderId/available-pandits/${query ?? ''}${(query == null || query.isEmpty) ? "?$queryString" : "&$queryString"}";

    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.get,
      url: url,
      referer: "",
    );

    return right(customResponse);
  } on Exception catch (e) {
    Logger.logError(e);
    return left(Failure.getDioException(e));
  }
}

  @override
  Future<Either<Failure, CustomResponse>> requestPandits({
    required int orderId,
    required List<int> panditIds,
  }) async {
    try {
      final data = {
        'pandit_ids': panditIds,
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/Orders/$orderId/request-pandits/",
        data: jsonEncode(data),
        referer: "https://devalay.org/apis/Orders/$orderId/request-pandits/",
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateOrderData(String? addOns,
      String? mobileNumber, String? name, String? plan, String? scheduledDatetime, String? serviceSection) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('mobile_number', mobileNumber ?? ""));
      formData.fields.add(MapEntry('name', name ??''));
      formData.fields.add(MapEntry('plan', plan ?? ''));
      formData.fields.add(MapEntry('scheduled_datetime', scheduledDatetime ??''));
      formData.fields.add(MapEntry('service_section', serviceSection ??''));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: '/Orders/',
          data: formData,
          referer: "https://devalay.org/apis/Orders/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updateDonatePayment(
      String donationId) async {
    try {
      FormData formData = FormData();

      formData.fields.add(MapEntry('order_id', donationId));

      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.post,
          url: "/payment/",
          data: formData,
          referer: "https://devalay.org/apis/payment/");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitFeedback({
    required int orderId,
    required int rating,
    String? review,
  }) async {
    try {
      final data = {
        'rating': rating,
        if (review != null && review.trim().isNotEmpty) 'comments': review.trim(),
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: '${AppConstant.order}/$orderId/user-feedback/',
        data: jsonEncode(data),
        referer: 'https://devalay.org/apis/Orders/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchPanditJobs({
    int page = 1,
    String? jobId,
    String? status,
  }) async {
    try {
      // Build URL with query parameters
      String url = '/Orders/pandit-jobs/?page=$page';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }
      if (jobId != null && jobId.isNotEmpty) {
        url += '&job_id=$jobId';
      }

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: url,
        referer: 'https://devalay.org/apis/Orders/pandit-jobs/?job_id=$jobId',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> panditRespondToJob({
    required int orderId,
    required String response,
  }) async {
    try {
      final data = {
        'response': response, // "accept" or "reject"
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: '/Orders/$orderId/pandit-respond/',
        data: jsonEncode(data),
        referer: 'https://devalay.org/apis/Orders/$orderId/pandit-respond/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> submitPanditFeedback({
    required int orderId,
    required int rating,
    String? comments,
  }) async {
    try {
      final data = {
        'rating': rating,
        if (comments != null && comments.trim().isNotEmpty) 'comments': comments.trim(),
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: '${AppConstant.order}/$orderId/pandit-feedback/',
        data: jsonEncode(data),
        referer: 'https://devalay.org/apis/Orders/$orderId/pandit-feedback/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
  
@override
Future<Either<Failure, CustomResponse>> createRazorpayOrder({

  required String name,
  required String mobileNumber,
  required String address,
  required String serviceId,
  required String plan,
  required List<int> addOns,
  required String scheduledDatetime,
}) async {
  try {
  /*

{
    "name": "gresg",
    "mobile_number": "+919876543210",
    "address": "Delhi",
    "service_section": 2,
    "plan": 12,
    "add_ons": [1],
    "scheduled_datetime": "2025-11-26T02:21:00"
}

*/





    final data = {
      'name': name,
      'mobile_number': mobileNumber,
      'address': address,
      'service_section': serviceId,
      'plan': plan,
      'add_ons': addOns,
      'scheduled_datetime': scheduledDatetime, 
    };  
    final CustomResponse customResponse = await ApiCalling().callApi(
      apiTypes: ApiTypes.post,
      url: '/Orders/create-razorpay/',
      data: jsonEncode(data),
      referer: 'https://devalay.org/apis/Orders/create-razorpay/',
    );
    return right(customResponse); 
  } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }


















  @override
  Future<Either<Failure, CustomResponse>> fetchExperienceData() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: '/experience/',
        referer: 'https://devalay.org/apis/experience/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchBankAccounts() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: AppConstant.bankAccounts,
        referer: 'https://devalay.org/apis/bank-accounts/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> saveBankAccounts({
    required String accountName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    String? upiId,
  }) async {
    try {
      final data = {
        'account_name': accountName,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
        'bank_name': bankName,
        if (upiId != null && upiId.trim().isNotEmpty) 'upi_id': upiId.trim(),
      };

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: AppConstant.bankAccounts,
        data: jsonEncode(data),
        referer: 'https://devalay.org/apis/bank-accounts/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchHelpContact() async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.get,
        url: '/help-contact/',
        referer: 'https://devalay.org/apis/help-contact/',
      );

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

 
}
