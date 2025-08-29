class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? token; // JWT token from backend
  final List<String> interests; // User interests
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.token,
    this.interests = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create User from API response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: '', // Don't store password from response
      token: json['token'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  // Method to convert User to JSON for API requests (without sensitive data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'interests': interests,
      // Note: password should not be included in toJson for security
    };
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? token,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 