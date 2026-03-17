import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart' show HelperClass;
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_state.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';

class PersonSearchSheet extends StatefulWidget {
  final List<Result> selectedPeople;
  final Function(List<Result>) onPeopleSelected;

  const PersonSearchSheet({
    super.key,
    required this.selectedPeople,
    required this.onPeopleSelected,
  });

  @override
  State<PersonSearchSheet> createState() => _PersonSearchSheetState();
}

class _PersonSearchSheetState extends State<PersonSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final GobelSearchCubit _searchCubit = GobelSearchCubit();
  late List<Result> _selectedPeople;

  @override
  void initState() {
    super.initState();
    _selectedPeople = List<Result>.from(widget.selectedPeople);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCubit.close();
    super.dispose();
  }

  void _search(String query) {
    if (query.isEmpty) {
      _searchCubit.setScreenState(
        data: [],
        isLoading: false,
        hasError: false,
      );
      return;
    }
    _searchCubit.fetchGlobleSearcUserhData(
      makeSearch: query,
      textType: "User",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: 24.sp),
              ),
              Gap(12.h),
              Text(
                StringConstant.selectPeople,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(12.h),
          SizedBox(
            height: 40.h,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: StringConstant.searchPeople,
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true, // Makes the field more compact
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 0.5),
                ),
              ),
              onChanged: _search,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BlocBuilder<GobelSearchCubit, GlobleState>(
              bloc: _searchCubit,
              builder: (context, state) {
                if (state is GlobleLoaded && state.loadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GlobleLoaded && state.hasError) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                  );
                }

                if (state is GlobleLoaded) {
                  final people = state.data ?? [];
                  if (people.isEmpty) {
                    return Center(
                      child: Text(
                        StringConstant.noPeopleFound,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: people.length,
                    itemBuilder: (context, index) {
                      final person = people[index];
                      final isSelected =
                          _selectedPeople.any((p) => p.id == person.id);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedPeople
                                  .removeWhere((p) => p.id == person.id);
                            } else {
                              _selectedPeople.add(person);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                          ),
                          child: Row(
                            children: [
                              CustomCacheImage(
                                imageUrl: person.dp ?? '',
                                width: 50.w,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100)),
                                height: 50.w,
                                fit: BoxFit.cover,
                              ),

                              SizedBox(width: 12.w),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      person.title ?? '',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    SizedBox(height: 4.h),
                                    
                                    Row(
                                      children: [
                                        Text(
                                          "${HelperClass.formatCountCompact(int.parse(person.followersCount ?? "0"))} Followers", // 1k, 100k, 1m use helper class to format the number 
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: AppColor.greyColor),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${HelperClass.formatCountCompact(int.parse(person.postsCount ?? "0"))} Posts",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: AppColor.greyColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 20.sp,
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeople.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    StringConstant.clearAll,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onPeopleSelected(_selectedPeople);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    StringConstant.done,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
