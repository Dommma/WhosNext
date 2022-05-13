import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:flutter_gen/gen_l10n/l10n.dart";

import '../network/join_room_notifier.dart';

class JoinButton extends StatelessWidget {

  var formKey;

  JoinButton(GlobalKey key) {
    formKey = key;
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context)!;
    var newRoom = context.watch<JoinRoomNotifier>();

    if(newRoom.isLoading) {
      return const CircularProgressIndicator();
    } else {
      return ElevatedButton(
        onPressed: () {
          newRoom.joinValidate(newRoom.userNameController.text, newRoom.roomIdController.text, context, formKey);},
        child: Text(l10n.joinButtonText),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          minimumSize: const Size(220, 50),
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

  }
}