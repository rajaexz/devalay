import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appbarBgColor,
        title: const Text(
          "Contact Us",
          style: TextStyle(color: AppColor.whiteColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 20.sp),
        child: Column(
          children: [
             const Text("Need assistance? We're here to help-reach out to us!", style: TextStyle(color: AppColor.orangeColor, fontSize: 20),),
            CommonTextfield(title: "Name", controller: nameController),
            Gap(10.h),
            CommonTextfield(title: "Email", controller: emailController),
            Gap(10.h),
            CommonTextfield(title: "Phone", controller: phoneController),
            Gap(10.h),
            CommonTextfield(title: "Message", maxLines: 5,controller: messageController)
          ],
        ),
      ),
    );
  }
}
