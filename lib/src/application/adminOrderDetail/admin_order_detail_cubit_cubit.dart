// admin_order_detail_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_state.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter/material.dart';
// admin_order_detail_cubit.dart

class AdminOrderDetailCubit extends Cubit<AdminOrderDetailState> {
  AdminOrderDetailCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(AdminOrderDetailInitial());

  final KirtiRepo _kirtiRepo;

  Future<void> fetchOrderDetail({required String orderId, String? status}) async {
    emit(AdminOrderDetailLoading(isLoading: true));

    try {
      final result = await _kirtiRepo.fetchAdminOrderDetail(orderId: orderId, status: status);

      result.fold(
        (failure) {
          Logger.logError(
              'Failed to fetch order detail: ${failure.errorMessage}');
          emit(AdminOrderDetailError(
            errorMessage: failure.errorMessage,
          ));
        },
        (response) {
          if (response.response?.data != null) {
            try {
              final responseData = response.response!.data;
              
              // Check if response has 'results' field (AdminOrderDetailResponse format)
              if (responseData is Map<String, dynamic> && 
                  responseData.containsKey('results')) {
                // Parse as AdminOrderDetailResponse (with results field)
                final orderResponse =
                    AdminOrderDetailResponse.fromJson(responseData);

                if (orderResponse.results != null &&
                    orderResponse.results!.isNotEmpty) {
                  emit(AdminOrderDetailLoaded(
                      order: orderResponse.results!.first));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else if (responseData is Map<String, dynamic>) {
                // Single object response - parse directly as AdminOrderDetailModel
                final order = AdminOrderDetailModel.fromJson(responseData);
                emit(AdminOrderDetailLoaded(order: order));
              } else if (responseData is List) {
                // List response - get first item
                if (responseData.isNotEmpty) {
                  final order = AdminOrderDetailModel.fromJson(
                      responseData.first as Map<String, dynamic>);
                  emit(AdminOrderDetailLoaded(order: order));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else {
                emit(AdminOrderDetailError(
                    errorMessage: 'Unexpected response format'));
              }
            } catch (e, stackTrace) {
              Logger.logError('Error parsing order detail: $e');
              Logger.logError('Stack trace: $stackTrace');
              emit(AdminOrderDetailError(
                  errorMessage: 'Error parsing order data: $e'));
            }
          } else {
            emit(AdminOrderDetailError(errorMessage: 'No data received'));
          }
        },
      );
    } catch (e) {
      Logger.logError('Exception in fetchOrderDetail: $e');
      emit(AdminOrderDetailError(errorMessage: 'An unexpected error occurred'));
    }
  }

  
  Future<void> fetchOrderDetailAssigned({required String orderId}) async {
    emit(AdminOrderDetailLoading(isLoading: true));
    try {
      final result = await _kirtiRepo.fetchAdminOrderDetailAssigned(orderId: orderId);
      result.fold(
        (failure) {
          Logger.logError('Failed to fetch order detail: ${failure.errorMessage}');
          emit(AdminOrderDetailError(
            errorMessage: failure.errorMessage,
          ));
        },
        (response) {
          if (response.response?.data != null) {
            try {
              final responseData = response.response!.data;
              
              // Check if response has 'results' field (AdminOrderDetailResponse format)
              if (responseData is Map<String, dynamic> && 
                  responseData.containsKey('results')) {
                // Parse as AdminOrderDetailResponse (with results field)
                final orderResponse =
                    AdminOrderDetailResponse.fromJson(responseData);

                if (orderResponse.results != null &&
                    orderResponse.results!.isNotEmpty) {
                  emit(AdminOrderDetailLoaded(
                      order: orderResponse.results!.first));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else if (responseData is Map<String, dynamic>) {
                // Single object response - parse directly as AdminOrderDetailModel
                final order = AdminOrderDetailModel.fromJson(responseData);
                emit(AdminOrderDetailLoaded(order: order));
              } else if (responseData is List) {
                // List response - get first item
                if (responseData.isNotEmpty) {
                  final order = AdminOrderDetailModel.fromJson(
                      responseData.first as Map<String, dynamic>);
                  emit(AdminOrderDetailLoaded(order: order));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else {
                emit(AdminOrderDetailError(
                    errorMessage: 'Unexpected response format'));
              }
            } catch (e, stackTrace) {
              Logger.logError('Error parsing order detail: $e');
              Logger.logError('Stack trace: $stackTrace');
              emit(AdminOrderDetailError(
                  errorMessage: 'Error parsing order data: $e'));
            }
          } else {
            emit(AdminOrderDetailError(errorMessage: 'No data received'));
          }
        },
      );
    } catch (e) {
      Logger.logError('Exception in fetchOrderDetailAssigned: $e');
      emit(AdminOrderDetailError(errorMessage: 'An unexpected error occurred'));
    }
  }

  Future<void> fetchOrderDetailConfirmed({required String orderId}) async {
    emit(AdminOrderDetailLoading(isLoading: true));
    try {
      final result = await _kirtiRepo.fetchAdminOrderDetailConfirmed(orderId: orderId);
      result.fold(
        (failure) {
          Logger.logError('Failed to fetch order detail: ${failure.errorMessage}');
          emit(AdminOrderDetailError(
            errorMessage: failure.errorMessage,
          ));
        },
        (response) {
          if (response.response?.data != null) {
            try {
              final responseData = response.response!.data;
              
              // Check if response has 'results' field (AdminOrderDetailResponse format)
              if (responseData is Map<String, dynamic> && 
                  responseData.containsKey('results')) {
                // Parse as AdminOrderDetailResponse (with results field)
                final orderResponse =
                    AdminOrderDetailResponse.fromJson(responseData);

                if (orderResponse.results != null &&
                    orderResponse.results!.isNotEmpty) {
                  emit(AdminOrderDetailLoaded(
                      order: orderResponse.results!.first));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else if (responseData is Map<String, dynamic>) {
                // Single object response - parse directly as AdminOrderDetailModel
                final order = AdminOrderDetailModel.fromJson(responseData);
                emit(AdminOrderDetailLoaded(order: order));
              } else if (responseData is List) {
                // List response - get first item
                if (responseData.isNotEmpty) {
                  final order = AdminOrderDetailModel.fromJson(
                      responseData.first as Map<String, dynamic>);
                  emit(AdminOrderDetailLoaded(order: order));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else {
                emit(AdminOrderDetailError(
                    errorMessage: 'Unexpected response format'));
              }
            } catch (e, stackTrace) {
              Logger.logError('Error parsing order detail: $e');
              Logger.logError('Stack trace: $stackTrace');
              emit(AdminOrderDetailError(
                  errorMessage: 'Error parsing order data: $e'));
            }
          } else {
            emit(AdminOrderDetailError(errorMessage: 'No data received'));
          }
        },
      );
    } catch (e) {
      Logger.logError('Exception in fetchOrderDetailConfirmed: $e');
      emit(AdminOrderDetailError(errorMessage: 'An unexpected error occurred'));
    }
  }


  // confirm order
  Future<void> confirmOrder(String orderId, int jobId,BuildContext context) async {
    emit(AdminOrderDetailLoading(isLoading: true));
    try {
      final result = await _kirtiRepo.confirmOrder(orderId, jobId);
      result.fold((failure) {
        Logger.logError('Failed to confirm order: ${failure.errorMessage}');
        emit(AdminOrderDetailError(errorMessage: failure.errorMessage));
      }, (response) {
        // i get api thought detail page massage map , make a condtion if i get map then hendle the error
        if (response.response!.data is Map) {
          // show a pop with the error message pop
          showDialog(context: context, builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(response.response!.data['detail']),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
            ],
          ));
          Navigator.pop(context);
          

        } else {
          emit(AdminOrderDetailLoading(isLoading: false));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order confirmed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      Logger.logError('Exception in confirmOrder: $e');
      emit(AdminOrderDetailError(errorMessage: 'An unexpected error occurred'));
    }
  }

  Future<void> refreshOrderDetail(String orderId, {String? status}) async {
    final currentState = state;

    if (currentState is AdminOrderDetailLoaded) {
      emit(AdminOrderDetailRefreshing(order: currentState.order));
    }

    try {
      final result = await _kirtiRepo.fetchAdminOrderDetail(orderId: orderId, status: status);

      result.fold(
        (failure) {
          Logger.logError(
              'Failed to refresh order detail: ${failure.errorMessage}');
          // Keep the current order and show error
          if (currentState is AdminOrderDetailLoaded) {
            emit(AdminOrderDetailLoaded(order: currentState.order));
          } else {
            emit(AdminOrderDetailError(errorMessage: failure.errorMessage));
          }
        },
        (response) {
          if (response.response?.data != null) {
            try {
              final responseData = response.response!.data;
              
              // Check if response has 'results' field (AdminOrderDetailResponse format)
              if (responseData is Map<String, dynamic> && 
                  responseData.containsKey('results')) {
                // Parse as AdminOrderDetailResponse (with results field)
                final orderResponse =
                    AdminOrderDetailResponse.fromJson(responseData);

                if (orderResponse.results != null &&
                    orderResponse.results!.isNotEmpty) {
                  emit(AdminOrderDetailLoaded(
                      order: orderResponse.results!.first));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else if (responseData is Map<String, dynamic>) {
                // Single object response - parse directly as AdminOrderDetailModel
                final order = AdminOrderDetailModel.fromJson(responseData);
                emit(AdminOrderDetailLoaded(order: order));
              } else if (responseData is List) {
                // List response - get first item
                if (responseData.isNotEmpty) {
                  final order = AdminOrderDetailModel.fromJson(
                      responseData.first as Map<String, dynamic>);
                  emit(AdminOrderDetailLoaded(order: order));
                } else {
                  emit(AdminOrderDetailError(errorMessage: 'No order found'));
                }
              } else {
                emit(AdminOrderDetailError(
                    errorMessage: 'Unexpected response format'));
              }
            } catch (e, stackTrace) {
              Logger.logError('Error parsing order detail: $e');
              Logger.logError('Stack trace: $stackTrace');
              // Keep the current order if available
              if (currentState is AdminOrderDetailLoaded) {
                emit(AdminOrderDetailLoaded(order: currentState.order));
              } else {
                emit(AdminOrderDetailError(
                    errorMessage: 'Error parsing order data: $e'));
              }
            }
          } else {
            emit(AdminOrderDetailError(errorMessage: 'No data received'));
          }
        },
      );
    } catch (e) {
      Logger.logError('Exception in refreshOrderDetail: $e');
      if (currentState is AdminOrderDetailLoaded) {
        emit(AdminOrderDetailLoaded(order: currentState.order));
      } else {
        emit(AdminOrderDetailError(
            errorMessage: 'An unexpected error occurred'));
      }
    }
  }

  void clearOrderDetail() {
    emit(AdminOrderDetailInitial());
  }
}
