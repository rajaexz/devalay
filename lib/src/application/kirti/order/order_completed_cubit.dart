import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/kirti/order/order_completed_state.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCompletedCubit extends Cubit<OrderCompletedState> {
  OrderCompletedCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(OrderCompletedInitialState());

  final KirtiRepo _kirtiRepo;
  bool _hasInitialData = false; // Track if we have initial data

  Future<void> fetchCompletedOrders({bool forceRefresh = false}) async {
    // If we have data and not forcing refresh, don't fetch again
    if (_hasInitialData && !forceRefresh) {
      final currentState = state;
      if (currentState is OrderCompletedLoadingState && currentState.orderList != null) {
        setOrderCompletedState(isLoading: false, orderList: currentState.orderList);
        return;
      }
    }

    setOrderCompletedState(isLoading: true);

    final result = await _kirtiRepo.fetchOderData();

    result.fold((failure) {
      setOrderCompletedState(isLoading: false, errorMessage: failure.toString());
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
            setOrderCompletedState(
              isLoading: false,
              errorMessage: 'Invalid response format: missing results field',
            );
            return;
          }
        } else if (r.response?.data is List) {
          // Direct list response (fallback for non-paginated responses)
          ordersList = r.response?.data as List;
        } else {
          setOrderCompletedState(
            isLoading: false,
            errorMessage: 'Invalid response format from server',
          );
          return;
        }

        final allOrders = ordersList
            .map((x) => OrderModel.fromJson(x as Map<String, dynamic>))
            .toList();
        
        // Filter orders with completed status
        // Also check pandit_feedback condition: if job has pandit_feedback: false, exclude from completed
        final completedOrders = allOrders.where((order) {
          // Check status first
          final isStatusCompleted = order.status?.toLowerCase() == 'completed' || 
              order.status?.toLowerCase() == 'delivered' ||
              order.status?.toLowerCase() == 'finished' ||
              order.status?.toLowerCase() == 'order completed';
          
          if (!isStatusCompleted) return false;
          
       
          
          return true;
        }).toList();
        
        _hasInitialData = true; // Mark that we have initial data
        setOrderCompletedState(isLoading: false, orderList: completedOrders);
      } catch (e) {
        setOrderCompletedState(
          isLoading: false,
          errorMessage: 'Error parsing order data: ${e.toString()}',
        );
      }
    });
  }

  // Method to force refresh data
  Future<void> refreshCompletedOrders() async {
    await fetchCompletedOrders(forceRefresh: true);
  }

  Future<void> reorderService(int orderId) async {
    setOrderCompletedState(isLoading: true);

    final result = await _kirtiRepo.reorderService(orderId);

    result.fold((failure) {
      setOrderCompletedState(isLoading: false, errorMessage: failure.toString());
    }, (r) {
      // Handle successful reorder
      setOrderCompletedState(isLoading: false);
    });
  }

  void setOrderCompletedState({
    List<OrderModel>? orderList,
    bool isLoading = false,
    String errorMessage = '',
  }) {
    emit(OrderCompletedLoadingState(
      orderList: orderList,
      isLoading: isLoading,
      errorMessage: errorMessage,
    ));
  }
} 