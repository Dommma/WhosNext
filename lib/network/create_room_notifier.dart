import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/models/topic_message_model.dart';
import 'package:untitled/pages/lobby_page.dart';
import 'package:uuid/uuid.dart';
import "package:untitled/models/room_model.dart";

class CreateRoomNotifier extends ChangeNotifier {
  TextEditingController userNameController = TextEditingController();
  TextEditingController roomNameController = TextEditingController();

  bool userNameValidate = true;
  bool roomNameValidate = true;

  bool isLoading = false;
  String? error;

  void createValidate(String userName, String roomName, BuildContext context, GlobalKey<FormState> key) {
    userNameValidate = userNameController.text.isEmpty ? false : true;
    roomNameValidate = roomNameController.text.isEmpty ? false : true;
    key.currentState?.validate();

    if(roomNameValidate && userNameValidate) {
      createRoom(userName, roomName, context);
    }
  }

  void createRoom(String userName, String roomName, BuildContext context) async {
    if(isLoading) return;

    isLoading = true;
    error=null;
    notifyListeners();
    int nextNumber = 0;

    try {
      await FirebaseFirestore.instance.collection("default").doc("defaultdoc").get().then((res) => nextNumber = res.get("roomIdCounter"),);
      await FirebaseFirestore.instance.collection("default").doc("defaultdoc").update({"roomIdCounter": nextNumber+1});
      String ownerId = Uuid().v1().toString();
      Map<String, String> userTmp = {ownerId: userName};
      final saveIt = Room(
          roomName: roomName,
          ownerId: ownerId,
          users: userTmp,
          isStarted: false
      );
      await FirebaseFirestore.instance.collection("rooms").doc(nextNumber.toString()).set(saveIt.toJson());
      final flagMessage = TopicMessage(
          senderId: "whocares",
          senderName: "Placeholder",
          timeStamp: DateTime.now().millisecondsSinceEpoch*2,
        type: "lenyegtelen"
      );
      await FirebaseFirestore.instance.collection("rooms").doc(nextNumber.toString()).collection("topics").doc("flagTopic").set(flagMessage.toJson());
      await FirebaseFirestore.instance.collection("rooms").doc(nextNumber.toString()).collection("reactions").doc("flagReaction").set(flagMessage.toJson());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LobbyPage(myUserId: ownerId, myUserName: userNameController.text, currentRoomId: nextNumber.toString(),)));

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