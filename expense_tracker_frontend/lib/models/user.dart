class User {
  final String username;
  final String? email;
  final String? profileImage;

  User({
    required this.username,
    this.email,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profile_image': profileImage,
    };
  }
}
