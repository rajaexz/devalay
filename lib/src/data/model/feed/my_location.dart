
import 'dart:convert';

class MyLocation {
    String mainText;
    String secondaryText;

    MyLocation({
        required this.mainText,
        required this.secondaryText,
    });

    MyLocation copyWith({
        String? mainText,
        String? secondaryText,
    }) => 
        MyLocation(
            mainText: mainText ?? this.mainText,
            secondaryText: secondaryText ?? this.secondaryText,
        );

    factory MyLocation.fromRawJson(String str) => MyLocation.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MyLocation.fromJson(Map<String, dynamic> json) => MyLocation(
        mainText: json["main_text"] ?? "",
        secondaryText: json["secondary_text"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "main_text": mainText,
        "secondary_text": secondaryText,
    };
}
