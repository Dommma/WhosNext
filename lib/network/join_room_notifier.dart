import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/lobby_page.dart';
import 'package:uuid/uuid.dart';

class JoinRoomNotifier extends ChangeNotifier {
  TextEditingController userNameController = TextEditingController();
  TextEditingController roomIdController = TextEditingController();

  bool userNameValidate = true;
  bool roomIdValidate = true;

  bool isLoading = false;
  String? error;

  void joinValidate(String userName, String roomName, BuildContext context, GlobalKey<FormState> key) {
    userNameValidate = userNameController.text.isEmpty ? false : true;
    roomIdValidate = roomIdController.text.isEmpty ? false : true;
    key.currentState?.validate();

    if(roomIdValidate && userNameValidate) {
      joinRoom(userName, roomName, context);
    }
  }

  void joinRoom(String userName, String roomId, BuildContext context) async {
    if(isLoading) return;

    isLoading = true;
    error=null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection("rooms").doc(roomId).get().then((res) {});
      String userId = Uuid().v1().toString();

      await FirebaseFirestore.instance.collection("rooms").doc(roomId).update({"users.$userId": userNameController.text.toString()});
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LobbyPage(myUserId: userId, myUserName: userNameController.text, currentRoomId: roomId,)));

    } on Exception catch(e) {
      error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error!)));
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}