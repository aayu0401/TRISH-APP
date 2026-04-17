import '../utils/url_utils.dart';

class User {
  final int? id;
  final String email;
  final String name;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final List<String> interests;
  final List<Photo> photos;
  final String? interestedInGender;
  final int? minAge;
  final int? maxAge;
  final int? maxDistance;
  final bool isPremium;
  final bool isActive;
  final bool emailVerified;

  User({
    this.id,
    required this.email,
    required this.name,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.interests = const [],
    this.photos = const [],
    this.interestedInGender,
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.isPremium = false,
    this.isActive = true,
    this.emailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      country: json['country'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : [],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => Photo.fromJson(p)).toList()
          : [],
      interestedInGender: json['interestedInGender'],
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      maxDistance: json['maxDistance'],
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? true,
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'interests': interests,
      'interestedInGender': interestedInGender,
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'isPremium': isPremium,
      'isActive': isActive,
      'emailVerified': emailVerified,
    };
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}

class Photo {
  final int id;
  final String url;
  final int displayOrder;

  Photo({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      url: resolveMediaUrl(json['url']?.toString()),
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}
