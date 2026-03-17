import 'package:devalay_app/src/application/language/language_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../core/utils/colors.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  String? language;

  String _getCurrentLanguage(BuildContext context) {
    if (language != null) return language!;

    final currentLocale = context.locale;
    return currentLocale.languageCode == 'hi' ? "hindi" : "english";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = _getCurrentLanguage(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 30.sp,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "display".tr(),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("language_selection".tr()),
            Gap(20.sp),
            _buildRadioOption("english", "english".tr(), currentLanguage,
                (value) {
              setState(() => language = value);
              context
                  .read<LanguageCubit>()
                  .changeLanguage(const Locale('en'), context);
            }),
            _buildRadioOption("hindi", "hindi".tr(), currentLanguage, (value) {
              setState(() => language = value);
              context
                  .read<LanguageCubit>()
                  .changeLanguage(const Locale('hi'), context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColor.blackColor, fontWeight: FontWeight.w600));
  }

  Widget _buildRadioOption(String value, String displayText,
      String currentValue, ValueChanged<String> onChanged) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: currentValue,
              onChanged: (selectedValue) => onChanged(selectedValue!),
              activeColor: AppColor.appbarBgColor,
            ),
          ],
        ),
      ),
    );
  }
}