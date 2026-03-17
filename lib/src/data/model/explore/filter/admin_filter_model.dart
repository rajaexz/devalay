import 'dart:convert';

ServiceFilterModel serviceFilterModelFromJson(String str) => 
    ServiceFilterModel.fromJson(json.decode(str));

String serviceFilterModelToJson(ServiceFilterModel data) => 
    json.encode(data.toJson());

class ServiceFilterModel {
  List<Location>? location;
  List<Dev>? dev;
  List<dynamic>? ordering;

  ServiceFilterModel({
    this.location,
    this.dev,
    this.ordering,
  });

  // ✅ Factory method for demo data
  factory ServiceFilterModel.demo() {
    return ServiceFilterModel(
      location: [
        Location(
          title: "Mumbai, Maharashtra, India",
          filter: LocationFilter(
            country: "India",
            state: "Maharashtra",
            city: "Mumbai",
          ),
        ),
        Location(
          title: "Delhi, Delhi, India",
          filter: LocationFilter(
            country: "India",
            state: "Delhi",
            city: "Delhi",
          ),
        ),
        Location(
          title: "Bangalore, Karnataka, India",
          filter: LocationFilter(
            country: "India",
            state: "Karnataka",
            city: "Bangalore",
          ),
        ),
        Location(
          title: "Varanasi, Uttar Pradesh, India",
          filter: LocationFilter(
            country: "India",
            state: "Uttar Pradesh",
            city: "Varanasi",
          ),
        ),
        Location(
          title: "Ayodhya, Uttar Pradesh, India",
          filter: LocationFilter(
            country: "India",
            state: "Uttar Pradesh",
            city: "Ayodhya",
          ),
        ),
        Location(
          title: "Chennai, Tamil Nadu, India",
          filter: LocationFilter(
            country: "India",
            state: "Tamil Nadu",
            city: "Chennai",
          ),
        ),
        Location(
          title: "Kolkata, West Bengal, India",
          filter: LocationFilter(
            country: "India",
            state: "West Bengal",
            city: "Kolkata",
          ),
        ),
        Location(
          title: "Pune, Maharashtra, India",
          filter: LocationFilter(
            country: "India",
            state: "Maharashtra",
            city: "Pune",
          ),
        ),
      ],
      dev: [
        Dev(
          title: "Shiva Temple",
          filter: DevFilter(dev: "1"),
        ),
        Dev(
          title: "Vishnu Temple",
          filter: DevFilter(dev: "2"),
        ),
        Dev(
          title: "Durga Temple",
          filter: DevFilter(dev: "3"),
        ),
        Dev(
          title: "Hanuman Temple",
          filter: DevFilter(dev: "4"),
        ),
        Dev(
          title: "Ganesh Temple",
          filter: DevFilter(dev: "5"),
        ),
        Dev(
          title: "Krishna Temple",
          filter: DevFilter(dev: "6"),
        ),
      ],
      ordering: ['asc', 'desc'],
    );
  }

  // ✅ Updated to match API response with capitalized keys
  factory ServiceFilterModel.fromJson(Map<String, dynamic> json) => ServiceFilterModel(
    location: json["Location"] == null 
        ? [] 
        : List<Location>.from(json["Location"]!.map((x) => Location.fromJson(x))),
    dev: json["Dev"] == null 
        ? [] 
        : List<Dev>.from(json["Dev"]!.map((x) => Dev.fromJson(x))),
    ordering: json["Ordering"] == null 
        ? [] 
        : List<dynamic>.from(json["Ordering"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "Location": location == null 
        ? [] 
        : List<dynamic>.from(location!.map((x) => x.toJson())),
    "Dev": dev == null 
        ? [] 
        : List<dynamic>.from(dev!.map((x) => x.toJson())),
    "Ordering": ordering == null 
        ? [] 
        : List<dynamic>.from(ordering!.map((x) => x)),
  };
}

class Dev {
  String? title;
  DevFilter? filter;

  Dev({
    this.title,
    this.filter,
  });

  factory Dev.fromJson(Map<String, dynamic> json) => Dev(
    title: json["title"],
    filter: json["filter"] == null 
        ? null 
        : DevFilter.fromJson(json["filter"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "filter": filter?.toJson(),
  };
}

class DevFilter {
  String? dev;

  DevFilter({
    this.dev,
  });

  factory DevFilter.fromJson(Map<String, dynamic> json) => DevFilter(
    dev: json["dev"],
  );

  Map<String, dynamic> toJson() => {
    "dev": dev,
  };
}

class Location {
  String? title;
  LocationFilter? filter;

  Location({
    this.title,
    this.filter,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    title: json["title"],
    filter: json["filter"] == null 
        ? null 
        : LocationFilter.fromJson(json["filter"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "filter": filter?.toJson(),
  };
}

class LocationFilter {
  String? country;
  String? state;
  String? city;

  LocationFilter({
    this.country,
    this.state,
    this.city,
  });

  factory LocationFilter.fromJson(Map<String, dynamic> json) => LocationFilter(
    country: json["country"],
    state: json["state"],
    city: json["city"],
  );

  Map<String, dynamic> toJson() => {
    "country": country,
    "state": state,
    "city": city,
  };
}