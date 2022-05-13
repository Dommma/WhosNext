import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/network/create_room_notifier.dart';
import "package:flutter_gen/gen_l10n/l10n.dart";

class CreateButton extends StatelessWidget {

  var formKey;

  CreateButton(GlobalKey key) {
    formKey = key;
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context)!;
    var newRoom = context.watch<CreateRoomNotifier>();

    if(newRoom.isLoading) {
      return const CircularProgressIndicator();
    } else {
      return ElevatedButton(
        onPressed: () {
          newRoom.createValidate(newRoom.userNameController.text, newRoom.roomNameController.text, context, formKey);},
        child: Text(l10n.createButtonText),
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