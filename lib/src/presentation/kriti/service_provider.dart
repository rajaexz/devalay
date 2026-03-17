import 'dart:io';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ServiceProvider extends StatefulWidget {
  const ServiceProvider({super.key});

  @override
  State<ServiceProvider> createState() => _ServiceProviderState();
}

class _ServiceProviderState extends State<ServiceProvider> {
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
        title: Text(StringConstant.serviceList,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColor.whiteColor)),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('this is the add');
          },
          child: const Icon(Icons.add)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  StringConstant.registrationSuccessVerified)
            ],
          ),
        ),
      ),
    );
  }
}
