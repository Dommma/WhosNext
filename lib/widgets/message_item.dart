import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageItemWidget extends StatelessWidget {
  final String userId;
  final String userName;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final bool isAdmin;
  final String type;

  const MessageItemWidget(this.userId, this.userName, this.animation,
      this.onClicked, this.isAdmin, this.type);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: type=="topic" ? Colors.orange.shade800 : Colors.red.shade700,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: Icon(
            type=="topic" ? Icons.add : Icons.error_outline,
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
