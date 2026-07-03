import 'package:app/utils/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';

class User {
  dynamic id; // This might be a UUID string in the near future
  String name;
  String email;
  String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  CachedNetworkImageProvider get avatar {
    if (avatarUrl != null) {
      return CachedNetworkImageProvider(avatarUrl!);
    }

    final hash = md5(email.trim().toLowerCase());
    return CachedNetworkImageProvider(
      'https://www.gravatar.com/avatar/$hash?s=512&d=mp',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar'] as String?,
    );
  }
}
