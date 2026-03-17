
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../application/kirti/service/service_cubit.dart';
import '../../application/profile/profile_info_about/profile_info_cubit.dart';
import '../../application/profile/profile_info_about/profile_info_state.dart';
import '../../core/shared_preference.dart';
import '../core/constants/strings.dart';
import '../core/widget/custom_cache_image.dart';
import '../profile/profile_main_screen.dart';
import 'kriti_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    loadUserImage();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  Future<void> loadUserImage() async {
    userId = await PrefManager.getUserDevalayId();
    setState(() {
      isLoading = false;
    });
  }

  String whichTab(int index) {
    switch (index) {
      case 0:
        return StringConstant.anusthan;
      case 1:
        return StringConstant.remotePuja;
      case 2:
        return StringConstant.pujaSamagri;
      case 3:
        return StringConstant.festivalDecor;
      default:
        return StringConstant.anusthan; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(child: Column(
        children: [
          Gap(12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        context.read<ServiceCubit>().searchService(value);
                      },
                      cursorColor: AppColor.greyColor,
                      decoration: InputDecoration(
                        hintText: StringConstant.search,
                        prefixIcon: const Icon(Icons.search, color: AppColor.greyColor,),
                        filled: true,
                        fillColor: AppColor.lightGrayColor,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 5.sp, vertical: 1.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileMainScreen(
                          id: int.tryParse(userId ?? '0') ?? 0,
                          profileType: "profile",
                        ),
                      ),
                    );
                  },
                  icon: ClipOval(
                    child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                      builder: (context, state) {
                        final imageUrl = (state is ProfileInfoLoaded &&
                            state.profileInfoModel?.dp != null)
                            ? state.profileInfoModel!.dp
                            : StringConstant.defaultImage;
                        return CustomCacheImage(
                            imageUrl: imageUrl, height: 50.h, width: 50.h);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: KritiScreen())
   
        ],
      )),
    );
  }
}
