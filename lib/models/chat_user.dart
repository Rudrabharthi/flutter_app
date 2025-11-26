import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime lastActive;

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.lastActive,
  });

  factory ChatUser.fromJSON(Map<String, dynamic> data) {
    final lastActiveRaw = data['last_active'];

    DateTime lastActiveTime;

    if (lastActiveRaw is Timestamp) {
      lastActiveTime = lastActiveRaw.toDate();
    } else if (lastActiveRaw is DateTime) {
      lastActiveTime = lastActiveRaw;
    } else {
      // fallback so app doesn't crash
      lastActiveTime = DateTime.now().subtract(const Duration(days: 365));
    }

    return ChatUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      image: data['image'] ?? '',
      lastActive: lastActiveTime,
    );
  }

  /// True if user was active in last 5 minutes
  bool wasRecentlyActive() {
    final now = DateTime.now().toUtc();
    final last = lastActive.toUtc();
    final diff = now.difference(last);
    return diff.inMinutes <= 5;
  }
}
