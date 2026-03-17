   import 'package:devalay_app/src/presentation/core/helper/animated_routes/blur_page_route.dart';
import 'package:devalay_app/src/presentation/core/widget/blurred_dialoge_box.dart';
import 'package:flutter/material.dart';

Future showBlurredDialoge(BuildContext context,
      {required BlurDialog dialoge, double? sigmaX, double? sigmaY}) async {
    return await Navigator.push(
      context,
      BlurredRouter(
          barrierDismiss: true,
          builder: (context) {
            if (dialoge is BlurredDialogBox) {
              return dialoge;
            } else if (dialoge is BlurredDialogBuilderBox) {
              return dialoge;
            } else if (dialoge is EmptyDialogBox) {
              return dialoge;
            }

            return Container();
          },
          sigmaX: sigmaX,
          sigmaY: sigmaY),
    );
  }