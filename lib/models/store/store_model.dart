class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class OpeningHours {
  final String day;
  final int open;
  final int close;

  OpeningHours({required this.day, required this.open, required this.close});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      day: json['day'] ?? '',
      open: json['open'] ?? 0,
      close: json['close'] ?? 0,
    );
  }
}

class Social {
  final String social;
  final String url;

  Social({required this.social, required this.url});

  factory Social.fromJson(Map<String, dynamic> json) {
    return Social(social: json['social'] ?? '', url: json['url'] ?? '');
  }
}

class Branch {
  final String id;
  final String name;
  final String address;
  final Location location;
  final List<OpeningHours> openingHours;
  final List<Social> socials;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.openingHours,
    required this.socials,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      openingHours: (json['opening_hours'] as List? ?? [])
          .map((e) => OpeningHours.fromJson(e))
          .toList(),
      socials: (json['socials'] as List? ?? [])
          .map((e) => Social.fromJson(e))
          .toList(),
    );
  }
}

class Store {
  final String id;
  final String name;
  final String category;
  final String description;
  final String logo;
  final List<String> images;
  final String? website;
  final List<Branch> branches;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.logo,
    required this.images,
    required this.website,
    required this.branches,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      website: json['website'],
      branches: (json['branches'] as List? ?? [])
          .map((e) => Branch.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }

  factory Store.empty() {
    return Store(
      id: '',
      name: '',
      category: '',
      description: '',
      logo: '',
      images: [],
      website: null,
      branches: [],
    );
  }
}
