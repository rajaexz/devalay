import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_state.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';

class TempleSearchSheet extends StatefulWidget {
  final List<Result> selectedTemples;
  final Function(List<Result>) onTemplesSelected;

  const TempleSearchSheet({
    super.key,
    required this.selectedTemples,
    required this.onTemplesSelected,
  });

  @override
  State<TempleSearchSheet> createState() => _TempleSearchSheetState();
}

class _TempleSearchSheetState extends State<TempleSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final GobelSearchCubit _searchCubit = GobelSearchCubit();
  late List<Result> _selectedTemples;

  @override
  void initState() {
    super.initState();
    _selectedTemples = List<Result>.from(widget.selectedTemples);
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
    _searchCubit.fetchGlobleSearchData(
      makeSearch: query,
      textType: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(40.h),
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: 24.sp),
              ),
              Gap(12.h),
              Text(
                StringConstant.selectTemples,
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
                hintText: StringConstant.searchTemples,
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true, // Makes the field more compact
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
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
                  final temples = state.data ?? [];
                  if (temples.isEmpty) {
                    return Center(
                      child: Text(
                        StringConstant.noTemplesFound,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  }

        return ListView.builder(
  itemCount: temples.length,
  itemBuilder: (context, index) {
    final temple = temples[index];

    // Skip "User" type results
    if (temple.tableName == "User") {
      return const SizedBox.shrink();
    }

    final isSelected =
        _selectedTemples.any((t) => t.id == temple.id);

    final imageUrl = temple.image;
    final displayTitle = temple.title;

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTemples.removeWhere((t) => t.id == temple.id);
          } else {
            _selectedTemples.add(temple);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h,),
        child: Row(
          children: [
          
          
            
            // Image (if available)
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CustomCacheImage(
                  imageUrl: imageUrl,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (temple.description != null)
                    Text(
                      temple.location ?? '',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColor.whiteColor
                                : AppColor.greyColor,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    displayTitle ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if( isSelected
                  )
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
);    }

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
                      _selectedTemples.clear();
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
                    widget.onTemplesSelected(_selectedTemples);
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