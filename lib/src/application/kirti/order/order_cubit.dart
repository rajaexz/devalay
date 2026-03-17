import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/kirti/order/order_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(OrderInitialState());
  
  final KirtiRepo _kirtiRepo;
  int page = 1;
  bool hasMoreData = true;
  List<OrderModel>? allData = [];
  OrderModel? sigleData ;


  
  Future<void> fetchOrderData(
      {String? value,
      String filterQuery = '',
      String? approvedVal,
      String? rejectVal,
      String? draftVal,
      bool loadMoreData = false}) async {
    if (!hasMoreData && loadMoreData) return;

    setOrderState(isLoading: true, orderList: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData!.clear();
    }

    final result = await _kirtiRepo.fetchOderData(page: page);

    result.fold(
      (failure) {
        hasMoreData = false;
        if (failure.toString().contains("Permission denied")) {
          setOrderState(
            isLoading: false,
            orderList: allData,
            errorMessage: failure.toString(),
          );
        } else {
          setOrderState(
            isLoading: false,
            orderList: allData,
            errorMessage: failure.toString(),
          );
          if (failure.toString() == "Not Found") {
            hasMoreData = false;
          }
        }
      },
      (r) {
        try {
          // Check if response data is valid
          if (r.response?.data == null) {
            setOrderState(
              isLoading: false,
              orderList: allData,
              errorMessage: 'No data received from server',
            );
            return;
          }

          // Handle paginated response structure
          List<dynamic> ordersList;
          if (r.response?.data is Map) {
            // Paginated response with 'results' field
            final responseData = r.response?.data as Map<String, dynamic>;
            if (responseData.containsKey('results')) {
              ordersList = responseData['results'] as List;
              // Update hasMoreData based on 'next' field
              hasMoreData = responseData['next'] != null;
            } else {
              setOrderState(
                isLoading: false,
                orderList: allData,
                errorMessage: 'Invalid response format: missing results field',
              );
              return;
            }
          } else if (r.response?.data is List) {
            // Direct list response (fallback for non-paginated responses)
            ordersList = r.response?.data as List;
            hasMoreData = ordersList.length >= 10;
          } else {
            setOrderState(
              isLoading: false,
              orderList: allData,
              errorMessage: 'Invalid response format from server',
            );
            return;
          }

          final data = ordersList
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (loadMoreData) {
            allData!.addAll(data);
          } else {
            allData = data;
          }

          setOrderState(
            isLoading: false,
            orderList: allData,
          );
        } catch (e) {
          setOrderState(
            isLoading: false,
            orderList: allData,
            errorMessage: 'Error parsing order data: ${e.toString()}',
          );
        }
      },
    );
  }
//
  Future<void> fetchSigleOrderData({
    bool loadMoreData = false,
    String? id  ,
  }) async {
    setOrderState(isLoading: true);

    final result = await _kirtiRepo.sigleOrder(id.toString());
         
    result.fold((failure) {
      setOrderState(isLoading: false, errorMessage: failure.toString());
    }, (r) {
      sigleData = OrderModel.fromJson(r.response?.data as Map<String, dynamic>);
      setOrderState(isLoading: false, sigleData: sigleData,  orderList: allData, );
    });
  }

  void setOrderState({
    List<OrderModel>? orderList,
        OrderModel? sigleData,
    bool isLoading = false,
    String errorMessage = '',
    String? helpContactEmail,
    String? helpContactNumber,
  }) {
    final currentState = state;
    final existingEmail = currentState is OrderLoadingState ? currentState.helpContactEmail : null;
    final existingNumber = currentState is OrderLoadingState ? currentState.helpContactNumber : null;
    
    emit(OrderLoadingState(
      orderList: orderList,
      sigleData:sigleData,
      isLoading: isLoading,
      errorMessage: errorMessage,
      helpContactEmail: helpContactEmail ?? existingEmail,
      helpContactNumber: helpContactNumber ?? existingNumber,
    ));
  }

  Future<void> fetchHelpContact() async {
    try {
      final result = await _kirtiRepo.fetchHelpContact();
      
      result.fold(
        (failure) {
          // On error, keep existing state
          print('Error fetching help contact: ${failure.toString()}');
        },
        (response) {
          try {
            final responseData = response.response?.data;
            String? email;
            String? contactNumber;
            
            if (responseData is Map<String, dynamic>) {
              email = responseData['email']?.toString();
              contactNumber = responseData['contact_number']?.toString() ?? 
                             responseData['contactNumber']?.toString() ??
                             responseData['phone']?.toString() ??
                             responseData['mobile_number']?.toString();
            } else if (responseData is List && responseData.isNotEmpty) {
              // If it's a list, take the first item
              final firstItem = responseData[0];
              if (firstItem is Map<String, dynamic>) {
                email = firstItem['email']?.toString();
                contactNumber = firstItem['contact_number']?.toString() ?? 
                               firstItem['contactNumber']?.toString() ??
                               firstItem['phone']?.toString() ??
                               firstItem['mobile_number']?.toString();
              }
            }
            
            // Update state with help contact info
            setOrderState(
              orderList: allData,
              sigleData: sigleData,
              helpContactEmail: email,
              helpContactNumber: contactNumber,
            );
          } catch (e) {
            print('Error parsing help contact data: $e');
          }
        },
      );
    } catch (e) {
      print('Error in fetchHelpContact: $e');
    }
  }

  void refreshOrderData(){
   fetchOrderData(
     loadMoreData :false,
     
  );
  }


  Future<void> cancelOrder({
    required int orderId,
  }) async {
    setOrderState(isLoading: true, orderList: allData, sigleData: sigleData);
    final result = await _kirtiRepo.cancelOrder(orderId);

    result.fold((failure) {
      setOrderState(isLoading: false, orderList: allData, sigleData: sigleData, errorMessage: failure.toString());
    }, (r) async {

      
    AppRouter.pop();

      setOrderState(isLoading: false, orderList: allData, sigleData: sigleData);
    });
  }


  Future<void> submitFeedback({
    required int orderId,
    required int rating,
    String? review,
  }) async {
    setOrderState(isLoading: true, orderList: allData, sigleData: sigleData);
    final result = await _kirtiRepo.submitFeedback(orderId: orderId, rating: rating, review: review);
    result.fold((failure) {
      setOrderState(isLoading: false, orderList: allData, sigleData: sigleData, errorMessage: failure.toString());
    }, (r) async {
      await fetchSigleOrderData(id: orderId.toString());
      setOrderState(isLoading: false, orderList: allData, sigleData: sigleData);
    });
  }

  Future<void> markOrderAsComplete({
    required int orderId,
  }) async {
    setOrderState(isLoading: true, orderList: allData, sigleData: sigleData);
    final result = await _kirtiRepo.markOrderAsComplete(orderId);

    result.fold((failure) {
      setOrderState(
        isLoading: false,
        orderList: allData,
        sigleData: sigleData,
        errorMessage: failure.toString(),
      );
    }, (r) async {
      // Refresh the order data after successful completion
      await fetchSigleOrderData(id: orderId.toString());
      setOrderState(isLoading: false, orderList: allData, sigleData: sigleData);
    });
  }
}
