import 'package:devalay_app/src/application/authentication/setting/setting_cubit.dart';
import 'package:devalay_app/src/application/authentication/setting/setting_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  void initState() {
    context.read<SettingCubit>().fetchGodForm('Terms_Conditions');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(builder: (context, state) {
      if (state is SettingLoaded) {
        if (state.loadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(child: Text(state.errorMessage));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.whiteColor,
            leadingWidth: 30,
            leading: IconButton(
                onPressed: () {
                  AppRouter.pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColor.blackColor,
                )),
            title: const Text(
              "Terms and Conditions",
              style: TextStyle(color: AppColor.blackColor),
            ),
            elevation: 0,
          ),
          backgroundColor: AppColor.whiteColor,
          body: SingleChildScrollView(
            child:
            Padding(padding: const EdgeInsetsGeometry.all(16),
            child:            Column(
              children: [
                Html(
                  data: state.helpSupportModel?[0].details?.html ?? '',
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14),
                    ),
                  },
                )

              ],
            ),
 
            )
           ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}