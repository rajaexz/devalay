import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/assign/assign_state.dart';
import 'package:devalay_app/src/data/model/kirti/admin_card_model.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignCubit extends Cubit<AssignState> {
  // AssignCubit() : super(AssignInitialState());
  AssignCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(AssignInitialState());

  final KirtiRepo _kirtiRepo;
  // final KirtiRepo _kirtiRepo; // Will be used when API is ready
  int page = 1;
  bool hasMoreData = true;
  List<OrderModel>? allData = [];

  OrderModel? singleOrder;// ✅ Initialize as empty list
  List<AdminOrderResponseModel> allAdminData = [];

  Future<void> fetchNewOrderData({
    String? value,
    String filterQuery = '',
    bool loadMoreData = false,
  }) async {
    if (!hasMoreData && loadMoreData) return;

    setOrderState(isLoading: true, adminOrderList: allAdminData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allAdminData.clear();
    }

    final result = await _kirtiRepo.fetchNewOrderData(page: page);

    result.fold(
      (failure) {
        hasMoreData = false;
        print('❌ API Error: $failure');
        
        if (failure.toString().contains("Permission denied")) {
          setOrderState(isLoading: false);
        } else {
          setOrderState(isLoading: false, adminOrderList: allAdminData);
          if (failure.toString() == "Not Found") {
            hasMoreData = false;
          }
        }
      },
      (r) {
        final responseData = r.response?.data;
        bool nextPageAvailable = false;

        if (responseData is Map<String, dynamic>) {
          final results = responseData['results'];
          final next = responseData['next'];

          nextPageAvailable = next != null && next.toString().isNotEmpty;

          if (results != null && results is List) {
            print('📦 Total orders in response: ${results.length}');
            
            final newOrders = <AdminOrderResponseModel>[];
            
            for (var item in results) {
              try {
                if (item is Map<String, dynamic>) {
                  final order = AdminOrderResponseModel.fromJson(item);
                  newOrders.add(order);
                  print('✅ Parsed order ID: ${order.id}, Status: ${order.status}');
                }
              } catch (e, stackTrace) {
                print('❌ Error parsing order: $e');
                print('📦 Stack trace: $stackTrace');
                print('📦 Item data: $item');
              }
            }

            if (loadMoreData) {
              allAdminData.addAll(newOrders);
              print('➕ Added ${newOrders.length} orders. Total: ${allAdminData.length}');
            } else {
              allAdminData = newOrders;
              print('🔄 Replaced with ${newOrders.length} orders');
            }
          } else {
            print('⚠️ Results is not a valid list');
            hasMoreData = false;
          }
        } else {
          print('⚠️ Response data is not a Map');
          hasMoreData = false;
        }

        hasMoreData = nextPageAvailable;

        setOrderState(
          isLoading: false,
          adminOrderList: allAdminData,
        );
        
        print('🎯 Final state - Total orders: ${allAdminData.length}, Has more: $hasMoreData');
      },
    );
  }



  fetchAssignedOrderData(
      {String? value,
      String filterQuery = '',
     
      bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;

    setOrderState(isLoading: true, orderList: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData!.clear();
    }

    final result = await _kirtiRepo.fetchOderDataAsgined(page: page);

    result.fold(
      (failure) {
        hasMoreData = false;
        if (failure.toString().contains("Permission denied")) {
          setOrderState(
            isLoading: false,
          );
        } else {
          setOrderState(isLoading: false, orderList: allData);
          if (failure.toString() == "Not Found") {
            hasMoreData = false;
          }
        }
      },
      (r) {
        final responseData = r.response?.data;
        List<OrderModel> data = [];
        bool nextPageAvailable = false;

        if (responseData is Map<String, dynamic>) {
          final results = responseData['results'];
          final next = responseData['next'];

          if (results is List) {
            data = results.map((e) => OrderModel.fromJson(e)).toList();
          }

          nextPageAvailable = next != null && next.toString().isNotEmpty;
        } else if (responseData is List) {
          data = responseData.map((e) => OrderModel.fromJson(e)).toList();
          nextPageAvailable = data.length >= 10;
        } else {
          setOrderState(
            isLoading: false,
            orderList: allData,
            errorMessage: 'Unexpected response format',
          );
          hasMoreData = false;
          return;
        }

        if (loadMoreData) {
          allData!.addAll(data);
        } else {
          allData = data;
        }

        hasMoreData = nextPageAvailable;

        setOrderState(
          isLoading: false,
          orderList: allData,
        );
      },
    );
  }

  // Fetch completed orders
  List<OrderModel>? completedOrders = [];
  int completedPage = 1;
  bool hasMoreCompletedData = true;

  // Fetch confirmed orders
  List<OrderModel>? confirmedOrders = [];
  int confirmedPage = 1;
  bool hasMoreConfirmedData = true;

  Future<void> fetchCompletedOrderData({bool loadMoreData = false}) async {
    if (!hasMoreCompletedData && loadMoreData) return;

    setOrderState(isLoading: true, orderList: completedOrders);

    if (loadMoreData) {
      completedPage++;
    } else {
      completedPage = 1;
      completedOrders!.clear();
    }

    final result = await _kirtiRepo.fetchCompletedOrderData(page: completedPage);

    result.fold(
      (failure) {
        hasMoreCompletedData = false;
        if (failure.toString().contains("Permission denied")) {
          setOrderState(isLoading: false);
        } else {
          setOrderState(isLoading: false, orderList: completedOrders);
          if (failure.toString() == "Not Found") {
            hasMoreCompletedData = false;
          }
        }
      },
      (r) {
        final responseData = r.response?.data;
        List<OrderModel> data = [];
        bool nextPageAvailable = false;

        if (responseData is Map<String, dynamic>) {
          final results = responseData['results'];
          final next = responseData['next'];

          if (results is List) {
            data = results.map((e) => OrderModel.fromJson(e)).toList();
          }

          nextPageAvailable = next != null && next.toString().isNotEmpty;
        } else if (responseData is List) {
          data = responseData.map((e) => OrderModel.fromJson(e)).toList();
          nextPageAvailable = data.length >= 10;
        } else {
          setOrderState(
            isLoading: false,
            orderList: completedOrders,
            errorMessage: 'Unexpected response format',
          );
          hasMoreCompletedData = false;
          return;
        }

        if (loadMoreData) {
          completedOrders!.addAll(data);
        } else {
          completedOrders = data;
        }

        hasMoreCompletedData = nextPageAvailable;

        setOrderState(
          isLoading: false,
          orderList: completedOrders,
        );
      },
    );
  }

  // Fetch confirmed orders
  Future<void> fetchConfirmedOrderData({bool loadMoreData = false}) async {
    if (!hasMoreConfirmedData && loadMoreData) return;

    setOrderState(isLoading: true, orderList: confirmedOrders);

    if (loadMoreData) {
      confirmedPage++;
    } else {
      confirmedPage = 1;
      confirmedOrders!.clear();
    }

    final result = await _kirtiRepo.fetchConfirmedOrderData(page: confirmedPage);

    result.fold(
      (failure) {
        hasMoreConfirmedData = false;
        if (failure.toString().contains("Permission denied")) {
          setOrderState(isLoading: false);
        } else {
          setOrderState(isLoading: false, orderList: confirmedOrders);
          if (failure.toString() == "Not Found") {
            hasMoreConfirmedData = false;
          }
        }
      },
      (r) {
        final responseData = r.response?.data;
        List<OrderModel> data = [];
        bool nextPageAvailable = false;

        if (responseData is Map<String, dynamic>) {
          final results = responseData['results'];
          final next = responseData['next'];

          if (results is List) {
            data = results.map((e) => OrderModel.fromJson(e)).toList();
          }

          nextPageAvailable = next != null && next.toString().isNotEmpty;
        } else if (responseData is List) {
          data = responseData.map((e) => OrderModel.fromJson(e)).toList();
          nextPageAvailable = data.length >= 10;
        } else {
          setOrderState(
            isLoading: false,
            orderList: confirmedOrders,
            errorMessage: 'Unexpected response format',
          );
          hasMoreConfirmedData = false;
          return;
        }

        if (loadMoreData) {
          confirmedOrders!.addAll(data);
        } else {
          confirmedOrders = data;
        }

        hasMoreConfirmedData = nextPageAvailable;

        setOrderState(
          isLoading: false,
          orderList: confirmedOrders,
        );
      },
    );
  }




  Future<void> fetchSingleOrderData({
    required String orderId,
  }) async {
    setOrderState(isLoading: true);

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));

      final order = allData?.firstWhere(
        (o) => o.id.toString() == orderId,
        orElse: () => OrderModel(
          id: int.tryParse(orderId.replaceAll('ORD', '')) ?? 1,
          name: 'Customer Name',
          address: 'Temple Address',
          status: 'Order Placed',
          paymentStatus: true,
          mobileNumber: '+91 9876543210',
          scheduledDatetime:
              DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          otp1: null,
          otp2: null,
          otp1Verified: false,
          otp2Verified: false,
          pandit: null,
          user: User(
            id: 1,
            name: 'Customer Name',
            email: 'customer@example.com',
            phone: '+91 9876543210',
            tableName: 'users',
          ),
          serviceSection: ServiceSection(
            id: 1,
            name: 'Satyanarayan Katha',
            images: 'https://via.placeholder.com/150',
            description: Description(
              html: 'Traditional Hindu religious ceremony',
              delta: 'Traditional Hindu religious ceremony',
            ),
            duration: '2-3 hours',
            star: 5,
            metaDescription: 'Traditional Hindu religious ceremony',
          ),
          plan: Plan(
            id: 1,
            type: 'Premium',
            price: 1500.0,
            pooja: 1,
            description: Description(
              html: 'Premium plan description',
              delta: 'Premium plan description',
            ),
          ),
          addOns: [],
          orderTracking: [
            OrderTracking(
              createdAt: DateTime.now().toIso8601String(),
              orderStatus: 'Order Placed',
            ),
          ],
          feedback: null,
        ),
      );

      setOrderState(isLoading: false, singleOrder: order);
    } catch (e) {
      setOrderState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    setOrderState(
        isLoading: true, orderList: allData, singleOrder: singleOrder);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update order status in local data
      if (allData != null) {
        for (int i = 0; i < allData!.length; i++) {
          if (allData![i].id.toString() == orderId) {
            allData![i] = allData![i].copyWith(
              status: newStatus,
              updatedAt: DateTime.now().toIso8601String(),
            );
            break;
          }
        }
      }

      if (singleOrder != null && singleOrder!.id.toString() == orderId) {
        singleOrder = singleOrder!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now().toIso8601String(),
        );
      }

      setOrderState(
          isLoading: false, orderList: allData, singleOrder: singleOrder);
    } catch (e) {
      setOrderState(
        isLoading: false,
        orderList: allData,
        singleOrder: singleOrder,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> assignOrder(String orderId, String assignedTo) async {
    setOrderState(
        isLoading: true, orderList: allData, singleOrder: singleOrder);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update order assignment in local data
      if (allData != null) {
        for (int i = 0; i < allData!.length; i++) {
          if (allData![i].id.toString() == orderId) {
            allData![i] = allData![i].copyWith(
              pandit: assignedTo,
              status: 'Assigned',
              updatedAt: DateTime.now().toIso8601String(),
            );
            break;
          }
        }
      }

      if (singleOrder != null && singleOrder!.id.toString() == orderId) {
        singleOrder = singleOrder!.copyWith(
          pandit: assignedTo,
          status: 'Assigned',
          updatedAt: DateTime.now().toIso8601String(),
        );
      }

      setOrderState(
          isLoading: false, orderList: allData, singleOrder: singleOrder);
    } catch (e) {
      setOrderState(
        isLoading: false,
        orderList: allData,
        singleOrder: singleOrder,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> completeOrder(String orderId) async {
    setOrderState(
        isLoading: true, orderList: allData, singleOrder: singleOrder);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update order status in local data
      if (allData != null) {
        for (int i = 0; i < allData!.length; i++) {
          if (allData![i].id.toString() == orderId) {
            allData![i] = allData![i].copyWith(
              status: 'Order Completed',
              updatedAt: DateTime.now().toIso8601String(),
            );
            break;
          }
        }
      }

      if (singleOrder != null && singleOrder!.id.toString() == orderId) {
        singleOrder = singleOrder!.copyWith(
          status: 'Order Completed',
          updatedAt: DateTime.now().toIso8601String(),
        );
      }

      setOrderState(
          isLoading: false, orderList: allData, singleOrder: singleOrder);
    } catch (e) {
      setOrderState(
        isLoading: false,
        orderList: allData,
        singleOrder: singleOrder,
        errorMessage: e.toString(),
      );
    }
  }

  void setOrderState({
    List<OrderModel>? orderList,
    List<AdminOrderResponseModel>? adminOrderList,
    OrderModel? singleOrder,
    bool isLoading = false,
    String errorMessage = '',
  }) {
    emit(AssignLoadingState(
      orderListAssigned: orderList,
      singleOrder: singleOrder,
      adminOrderList: adminOrderList,
      isLoading: isLoading,
      errorMessage: errorMessage,
    ));
  }

  void refreshOrderData() {
    assignOrder( '1', '1');
    
  }

//  https://devalay.org/apis/Orders/admin-orders/?status=Pending 
//   https://devalay.org/apis/Orders/admin-asign-orders/?status=Assigned 
}

// Extension to add copyWith method to OrderModel
extension OrderModelCopyWith on OrderModel {
  OrderModel copyWith({
    int? id,
    User? user,
    List<AddOn>? addOns,
    String? createdAt,
    String? updatedAt,
    String? name,
    String? address,
    String? status,
    bool? paymentStatus,
    String? mobileNumber,
    String? scheduledDatetime,
    dynamic otp1,
    dynamic otp2,
    bool? otp1Verified,
    bool? otp2Verified,
    ServiceSection? serviceSection,
    dynamic pandit,
    Plan? plan,
    List<OrderTracking>? orderTracking,
    dynamic feedback,
  }) {
    return OrderModel(
      id: id ?? this.id,
      user: user ?? this.user,
      addOns: addOns ?? this.addOns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      address: address ?? this.address,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      scheduledDatetime: scheduledDatetime ?? this.scheduledDatetime,
      otp1: otp1 ?? this.otp1,
      otp2: otp2 ?? this.otp2,
      otp1Verified: otp1Verified ?? this.otp1Verified,
      otp2Verified: otp2Verified ?? this.otp2Verified,
      serviceSection: serviceSection ?? this.serviceSection,
      pandit: pandit ?? this.pandit,
      plan: plan ?? this.plan,
      orderTracking: orderTracking ?? this.orderTracking,
      feedback: feedback ?? this.feedback,
    );
  }
}
