import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  // final String imagePath; // you can pass asset or network image path
  bool isAppbar;
   ComingSoonScreen({super.key,required this.isAppbar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAppbar ? AppBar(
       iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      ) : null,
     
      body: Center(
        child: Image.asset("assets/background/Coming soon.png"),
      ),
    );
  }
}
