import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserItemWidget extends StatelessWidget {
  final String userId;
  final String userName;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final bool isAdmin;
  final String adminId;

  const UserItemWidget(this.userId, this.userName, this.animation,
      this.onClicked, this.isAdmin, this.adminId);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: Icon(
            Icons.account_circle,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          title: Text(
            userName,
            style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold),
          ),
          trailing: adminTrailing(),
        ),
      ),
    );
  }

  Widget? adminTrailing() {
    if (userId == adminId) {
      return Icon(Icons.castle, color: Colors.yellow, size: 40);
    }
    if (isAdmin) {
      return IconButton(
        icon: Icon(Icons.highlight_remove_outlined, color: Colors.red, size: 40),
        onPressed: onClicked,
      );
    } else {
      return null;
    }
  }
}
