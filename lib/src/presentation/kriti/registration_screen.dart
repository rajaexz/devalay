import 'dart:io';

import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  List<String> languages = ['English', 'Hindi', 'Gujarati', 'Marathi'];
  List<String> avilableLocation = [
    'Noida',
    'Agra',
    'Delhi-NCR',
    'Mumbai',
    'Haryana'
  ];

  String? selectedLanguage;

  File? aadhaarFront;
  File? aadhaarBack;
  bool isTermsAccepted = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(bool isFront) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          aadhaarFront = File(pickedFile.path);
        } else {
          aadhaarBack = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appbarBgColor,
        elevation: 0,
        title: Text(StringConstant.registrationScreen,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColor.whiteColor)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20.h),
              Text(StringConstant.personalInformation,
                  style: Theme.of(context).textTheme.titleLarge),
              Gap(20.h),
              CommonTextfield(title: StringConstant.fullName, controller: nameController),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.mobileNumberLabel, controller: phoneController),
              Gap(20.h),
              CommonTextfield(title: StringConstant.emailId, controller: emailController),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.currentAddress, controller: addressController),
              Gap(30.h),
              Text(StringConstant.professionalDetails,
                  style: Theme.of(context).textTheme.titleLarge),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.yearsOfExperience, controller: addressController),
              Gap(20.h),
              CommonTextfield(title: StringConstant.skills, controller: addressController),
              Gap(20.h),
              Text(StringConstant.languageSpoken,
                  style: Theme.of(context).textTheme.bodyMedium),
              Gap(20.h),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                ),
                items: languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value;
                  });
                },
              ),
              Gap(20.h),
              Text(StringConstant.bankPaymentInfo,
                  style: Theme.of(context).textTheme.titleLarge),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.bankName, controller: addressController),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.accountNumber, controller: addressController),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.ifscCodeLabel, controller: addressController),
              Gap(20.h),
              Text(StringConstant.documentUpload,
                  style: Theme.of(context).textTheme.titleLarge),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.panCardNumber, controller: addressController),
              Gap(20.h),
              Text(StringConstant.aadhaarCardUpload,
                  style: Theme.of(context).textTheme.titleLarge),
              Gap(20.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => pickImage(true),
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: aadhaarFront != null
                            ? Image.file(aadhaarFront!, fit: BoxFit.cover)
                            : Center(child: Text(StringConstant.uploadFront)),
                      ),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: InkWell(
                      onTap: () => pickImage(false),
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: aadhaarBack != null
                            ? Image.file(aadhaarBack!, fit: BoxFit.cover)
                            : Center(child: Text(StringConstant.uploadBack)),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(20.h),
              Gap(20.h),
              CheckboxListTile(
                title: Text(StringConstant.iAgreeTermsConditions),
                value: isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    isTermsAccepted = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Gap(20.h),
              if (isTermsAccepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppRouter.push(RouterConstant.serviceProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.appbarBgColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(StringConstant.submit, style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              Gap(40.h),
              Gap(40.h)
            ],
          ),
        ),
      ),
    );
  }
}
