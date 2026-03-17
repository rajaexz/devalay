import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/kirti/order/order_cancelled_state.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCancelledCubit extends Cubit<OrderCancelledState> {
  OrderCancelledCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(OrderCancelledInitialState());

  final KirtiRepo _kirtiRepo;
  bool _hasInitialData = false; // Track if we have initial data

  Future<void> fetchCancelledOrders({bool forceRefresh = false}) async {
    // If we have data and not forcing refresh, don't fetch again
    if (_hasInitialData && !forceRefresh) {
      final currentState = state;
      if (currentState is OrderCancelledLoadingState && currentState.orderList != null) {
        setOrderCancelledState(isLoading: false, orderList: currentState.orderList);
        return;
      }
    }

    setOrderCancelledState(isLoading: true);

    final result = await _kirtiRepo.fetchOderData();

    result.fold((failure) {
      setOrderCancelledState(isLoading: false, errorMessage: failure.toString());
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
            setOrderCancelledState(
              isLoading: false,
              errorMessage: 'Invalid response format: missing results field',
            );
            return;
          }
        } else if (r.response?.data is List) {
          // Direct list response (fallback for non-paginated responses)
          ordersList = r.response?.data as List;
        } else {
          setOrderCancelledState(
            isLoading: false,
            errorMessage: 'Invalid response format from server',
          );
          return;
        }

        final allOrders = ordersList
            .map((x) => OrderModel.fromJson(x as Map<String, dynamic>))
            .toList();
        
        // Filter orders with cancelled status
        final cancelledOrders = allOrders.where((order) => 
          order.status?.toLowerCase() == 'cancelled' || 
          order.status?.toLowerCase() == 'refunded'
        ).toList();
        
        _hasInitialData = true; // Mark that we have initial data
        setOrderCancelledState(isLoading: false, orderList: cancelledOrders);
      } catch (e) {
        setOrderCancelledState(
          isLoading: false,
          errorMessage: 'Error parsing order data: ${e.toString()}',
        );
      }
    });
  }

  // Method to force refresh data
  Future<void> refreshCancelledOrders() async {
    await fetchCancelledOrders(forceRefresh: true);
  }

  Future<void> reorderFromCancelled(int orderId) async {
    setOrderCancelledState(isLoading: true);

    final result = await _kirtiRepo.reorderService(orderId);

    result.fold((failure) {
      setOrderCancelledState(isLoading: false, errorMessage: failure.toString());
    }, (r) {
      // Handle successful reorder from cancelled order
      setOrderCancelledState(isLoading: false);
    });
  }

  void setOrderCancelledState({
    List<OrderModel>? orderList,
    bool isLoading = false,
    String errorMessage = '',
  }) {
    emit(OrderCancelledLoadingState(
      orderList: orderList,
      isLoading: isLoading,
      errorMessage: errorMessage,
    ));
  }
} 