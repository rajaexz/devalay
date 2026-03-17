import 'package:devalay_app/src/application/kirti/order/order_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class MyorderScreen extends StatelessWidget {
  const MyorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          StringConstant.myOrder,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocProvider(
        create: (context) => OrderCubit()..fetchOrderData(),
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoadingState) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage.isNotEmpty) {
                return Center(child: Text(state.errorMessage));
              }
              if (state.orderList == null || state.orderList!.isEmpty) {
                return Center(child: Text(StringConstant.noOrderFound));
              }

              return Padding(
                padding: EdgeInsets.all(16.sp),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = state.orderList![index];
                      return Container(
                        color: Colors.yellow,
                        padding: EdgeInsets.all(16.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.id.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.plan?.type??'',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.serviceSection?.name??'',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.paymentStatus.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Gap(10.h),
                    itemCount: state.orderList!.length),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
