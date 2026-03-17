import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/kirti/order/order_processing_state.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderProcessingCubit extends Cubit<OrderProcessingState> {
  OrderProcessingCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(OrderProcessingInitialState());

  final KirtiRepo _kirtiRepo;
  bool _hasInitialData = false; // Track if we have initial data

  Future<void> fetchProcessingOrders({bool forceRefresh = false}) async {
    // If we have data and not forcing refresh, don't fetch again
    if (_hasInitialData && !forceRefresh) {
      final currentState = state;
      if (currentState is OrderProcessingLoadingState && currentState.orderList != null) {
        setOrderProcessingState(isLoading: false, orderList: currentState.orderList);
        return;
      }
    }

    setOrderProcessingState(isLoading: true);

    final result = await _kirtiRepo.fetchOderData( page: 1, status: 'Order Placed');

    result.fold((failure) {
      setOrderProcessingState(isLoading: false, errorMessage: failure.toString());
    }, (r) {
      try {
        // Handle paginated response structure
        List<dynamic> ordersList;
        if (r.response?.data is Map) {
          // Paginated response with 'results' field
          final responseData = r.response?.data as Map<String, dynamic>;
          if (responseData.containsKey('results')) {
            ordersList = responseData['results'] as List;
          } else {
            setOrderProcessingState(
              isLoading: false,
              errorMessage: 'Invalid response format: missing results field',
            );
            return;
          }
        } else if (r.response?.data is List) {
          // Direct list response (fallback for non-paginated responses)
          ordersList = r.response?.data as List;
        } else {
          setOrderProcessingState(
            isLoading: false,
            errorMessage: 'Invalid response format from server',
          );
          return;
        }

        final allOrders = ordersList
            .map((x) => OrderModel.fromJson(x as Map<String, dynamic>))
            .toList();
        
        // Filter orders with processing status (case-insensitive check)
        final processingOrders = allOrders.where((order) => 
          order.status?.toLowerCase() == 'order placed'
        ).toList();
        
        _hasInitialData = true; // Mark that we have initial data
        setOrderProcessingState(isLoading: false, orderList: processingOrders);
      } catch (e) {
        setOrderProcessingState(
          isLoading: false,
          errorMessage: 'Error parsing order data: ${e.toString()}',
        );
      }
    });
  }

  // Method to force refresh data
  Future<void> refreshProcessingOrders() async {
    await fetchProcessingOrders(forceRefresh: true);
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    // setOrderProcessingState(isLoading: true);
    
    // final result = await _kirtiRepo.updateOrderStatus(orderId, newStatus);

    // result.fold((failure) {
    //   setOrderProcessingState(isLoading: false, errorMessage: failure.toString());
    // }, (r) {
    //   // Refresh the processing orders after status update
    //   fetchProcessingOrders(forceRefresh: true);
    // });
  }

  Future<void> cancelOrder(int orderId) async {
    setOrderProcessingState(isLoading: true);

    final result = await _kirtiRepo.cancelOrder(orderId);

    result.fold((failure) {
      setOrderProcessingState(isLoading: false, errorMessage: failure.toString());
    }, (r) {
      // Refresh the processing orders after cancellation
      fetchProcessingOrders(forceRefresh: true);
    });
  }

  void setOrderProcessingState({
    List<OrderModel>? orderList,
    bool isLoading = false,
    String errorMessage = '',
  }) {
    emit(OrderProcessingLoadingState(
      orderList: orderList,
      isLoading: isLoading,
      errorMessage: errorMessage,
    ));
  }
} 