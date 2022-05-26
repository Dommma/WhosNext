import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../models/topic_message_model.dart';

class RoomNotifier extends ChangeNotifier {
  bool isTopicActive = false;
  bool isReactionActive = false;
  late var docRef;
  late String myUserId;
  late String myUserName;

  RoomNotifier(String roomId, String userId, String userName) {
    docRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    myUserId = userId;
    myUserName = userName;
  }

  void topicPressed() {
    if(isTopicActive) {
      docRef
          .collection("topics")
          .doc("T-" + myUserId!)
          .delete();
      isTopicActive = false;
    }
    else {
      var newTopic = TopicMessage(
          senderId: myUserId,
          senderName: myUserName,
          timeStamp:
          DateTime.now().millisecondsSinceEpoch,
          type: "topic");
      docRef
          .collection("topics")
          .doc("T-" + myUserId!)
          .set(newTopic.toJson());
      isTopicActive = true;
    }
    notifyListeners();
  }

  void reactionPressed() {
    if(isReactionActive) {
      docRef
          .collection("reactions")
          .doc("R-" + myUserId!)
          .delete();
      isReactionActive = false;
    }
    else {
      var newTopic = TopicMessage(
          senderId: myUserId,
          senderName: myUserName,
          timeStamp:
          DateTime.now().millisecondsSinceEpoch,
          type: "reaction");
      docRef
          .collection("reactions")
          .doc("R-" + myUserId!)
          .set(newTopic.toJson());
      isReactionActive = true;
    }
    notifyListeners();
  }

}