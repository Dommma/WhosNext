import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/network/create_room_notifier.dart';
import 'package:untitled/widgets/create_button.dart';
import "package:flutter_gen/gen_l10n/l10n.dart";

class CreateRoomPage extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  CollectionReference defRef = FirebaseFirestore.instance.collection("default");

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => CreateRoomNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Who's next? - "+l10n.createButtonText),
        ),
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
              child: Consumer<CreateRoomNotifier>(
            builder: (context, value, child) => Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: (valid) {
                      if (!value.userNameValidate) {
                        return l10n.dontLetEmptyError;
                      } else {
                        return null;
                      }
                    },
                    controller: value.userNameController,
                    decoration: InputDecoration(
                      labelText: l10n.yourNameTextFieldLabelText,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintText: l10n.yourNameTextFieldHint,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    validator: (valid) {
                      if (!value.roomNameValidate) {
                        return l10n.dontLetEmptyError;
                      } else {
                        return null;
                      }
                    },
                    controller: value.roomNameController,
                    decoration: InputDecoration(
                      labelText: l10n.roomNameTextFieldLabelText,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintText: l10n.roomNameTextFieldHint,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CreateButton(formKey)
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
