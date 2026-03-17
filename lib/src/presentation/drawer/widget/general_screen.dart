import 'package:flutter/material.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final List<bool> _isExpanded = List.generate(3, (index) => false);

  final List<Map<String, dynamic>> _faqList = [
    {
      "title": "Issue in logout",
      "content": [
        "Open the app and navigate to the Profile section.",
        "Tap on the menu icon or swipe to open the navigation drawer.",
        "Locate and tap on the 'Logout' or 'Sign Out' button.",
        "If prompted, confirm your action to successfully log out."
      ]
    },
    {"title": "Image Upload Issue", "content": []},
    {"title": "Dislike Functionality", "content": []},
    {"title": "Unable to add Temples", "content": []},
    {"title": "I Want to Delete my account", "content": []},
    {"title": "How to Change Password", "content": []},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpansionPanelList(
          elevation: 2,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
          children: _faqList.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(
                    item["title"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
              body: item["content"].isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (item["content"] as List<String>)
                      .map((text) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• $text"),
                  ))
                      .toList(),
                ),
              )
                  : Container(),
              isExpanded: _isExpanded[index],
            );
          }).toList(),
        ),
      ),
    );
  }
}
