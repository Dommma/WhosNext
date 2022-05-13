import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? userName;
  final String? userId;

  User({this.userName, this.userId});

  User.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      )   :
        userName = snapshot.data()?["userName"],
        userId = snapshot.data()?["userId"];

  Map<String, dynamic> toFirestore() {
    return {
      if (userName != null) "userName": userName,
      if (userId != null) "userId": userId,
    };
  }
}
