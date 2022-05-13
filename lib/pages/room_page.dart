import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/l10n.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/topic_message_model.dart';

import '../widgets/message_item.dart';

class RoomPage extends StatelessWidget {
  final String? myUserId;
  final String? currentRoomId;
  final String? myUserName;

  RoomPage(
      {Key? key,
      required this.myUserId,
      required this.myUserName,
      required this.currentRoomId})
      : super(key: key);

  final listKey = GlobalKey<AnimatedListState>();
  
  var topicList = List<TopicMessage>.empty(growable: true);
  var reactionList = List<TopicMessage>.empty(growable: true);
  var showingList = List<TopicMessage>.empty(growable: true);

  bool isAdmin = false;
  bool isActiveTopic = false;
  bool isActiveReaction = false;
  String actualItemType = "";

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance.collection("rooms").doc(currentRoomId);
    listenToTheTopics();
    listenToTheReactions();
    final L10n l10n = L10n.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        var result = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(l10n.areYouSureText),
                content: Text(isAdmin
                    ? l10n.doYorReallyWantToCloseThisRoomText
                    : l10n.doYouReallyWantToQuitText),
                actions: [
                  TextButton(
                    child: Text(l10n.noText),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                      child: Text(l10n.yesText),
                      onPressed: () {
                        if (isAdmin) {
                          FirebaseFirestore.instance
                              .collection("rooms")
                              .doc(currentRoomId)
                              .delete();
                        } else {
                          if (isActiveReaction) {
                            docRef
                                .collection("reactions")
                                .doc("R-" + myUserId!)
                                .delete();
                          }
                          if (isActiveTopic) {
                            docRef
                                .collection("topics")
                                .doc("T-" + myUserId!)
                                .delete().then((value) => isActiveTopic = false);
                          }
                        }
                        Navigator.pop(context, true);
                      }),
                ],
              );
            });
        return result ?? false;
      },
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("rooms")
              .doc(currentRoomId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              print("snapshot error: ${snapshot.error}");
              return Center(child: Text(l10n.somethingWrong));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              print("loading");
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.data() == null) {
              return AlertDialog(
                title: Text(l10n.adminClosedTheRoom),
                actions: [
                  TextButton(
                      child: Text(l10n.backToTheMenu),
                      onPressed: () {
                        Navigator.pop(context, true);
                      }),
                ],
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text(snapshot.data?.get("roomName")),
                ),
                body: Column(children: [
                  const SizedBox(
                    height: 6.0,
                  ),
                  Expanded(
                  child: AnimatedList(
                    key: listKey,
                    initialItemCount: 0,
                    itemBuilder: (context, index, animation) {
                      return buildItem(showingList[index].senderId ,showingList[index].senderName, animation, isAdmin, showingList[index].type!);
                    },
                  ),
                ),
                  const SizedBox(
                    height: 6.0,
                  ),
                ]),
                floatingActionButton: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      tooltip: l10n.reactionButtonHint,
                      backgroundColor: Colors.red.shade700,
                        child: Text(
                          "!",
                          style: TextStyle(fontSize: 40.0, color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                        shape: CircleBorder(
                            side: BorderSide(color: Theme.of(context).scaffoldBackgroundColor)
                        ),
                        onPressed: () {
                          if (isActiveReaction) {
                            docRef
                                .collection("reactions")
                                .doc("R-" + myUserId!)
                                .delete().then((value) => isActiveReaction=false);
                          } else {
                            var newTopic = TopicMessage(
                                senderId: myUserId,
                                senderName: myUserName,
                                timeStamp:
                                    DateTime.now().millisecondsSinceEpoch,
                            type: "reaction");
                            docRef
                                .collection("reactions")
                                .doc("R-" + myUserId!)
                                .set(newTopic.toJson()).then((value) => isActiveReaction=true);
                          }
                        }),
                    SizedBox(
                      height: 20.0,
                    ),
                    FloatingActionButton(
                      tooltip: l10n.topicButtonHint,
                      backgroundColor: Colors.orange.shade800,
                        child: Text(
                          "+",
                          style: TextStyle(fontSize: 50.0, color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                        shape: CircleBorder(
                          side: BorderSide(color: Theme.of(context).scaffoldBackgroundColor)
                        ),
                        onPressed: () {
                          if (isActiveTopic) {
                            docRef
                                .collection("topics")
                                .doc("T-" + myUserId!)
                                .delete().then((value) => isActiveTopic = false);
                          } else {
                            docRef
                                .collection("topics")
                                .doc("T-" + myUserId!)
                                .set({
                              "timestamp":
                                  DateTime.now().millisecondsSinceEpoch,
                              "senderName": myUserName,
                              "senderId": myUserId,
                              "type": "topic"
                            }).then((value) => isActiveTopic = true);
                          }
                        })
                  ],
                ),
              );
            }
          }),
    );
  }

  void listenToTheTopics() {

    var topicStream = FirebaseFirestore.instance.collection("rooms").doc(currentRoomId).collection("topics")
        .snapshots().listen((event) {
      for(var change in event.docChanges) {
        switch(change.type) {
          case DocumentChangeType.added:
            var tmp = TopicMessage.fromJson(change.doc.data() as Map<String, dynamic>);
            if(tmp.senderId!="whocares") {
              actualItemType = "topic";
              topicList.insert(topicList.length, tmp);
              mergeLists();
              listKey.currentState?.insertItem(showingList.length-1);
            }
            break;
          case DocumentChangeType.removed:
            TopicMessage rem = TopicMessage.fromJson(change.doc.data() as Map<String, dynamic>);
            removeTopicItem(rem);
            break;
          default:
            break;
        }
      }
    });
  }

  void listenToTheReactions() {
    var reactionStream = FirebaseFirestore.instance.collection("rooms").doc(currentRoomId).collection("reactions")
        .snapshots().listen((event) {
      for(var change in event.docChanges) {
        switch(change.type) {
          case DocumentChangeType.added:
            actualItemType = "reaction";
            var tmp = TopicMessage.fromJson(change.doc.data() as Map<String, dynamic>);
            if(tmp.senderId!="whocares") {
              reactionList.insert(reactionList.length, tmp);
              mergeLists();
              print("topic lengt: "+topicList.length.toString());
              listKey.currentState?.insertItem(reactionList.length-1);
            }
            break;
          case DocumentChangeType.removed:
            TopicMessage rem = TopicMessage.fromJson(change.doc.data() as Map<String, dynamic>);
            removeReactionItem(rem);
            break;
          default:
            break;
        }
      }
    });
  }

  Widget buildItem(
      String? userId, String? userName, Animation<double> animation, bool isAdmin, String type) =>
      MessageItemWidget(userId!, userName!, animation, () => {}, isAdmin, type);

  void mergeLists() {
    showingList.clear();
    if(reactionList.isNotEmpty) {
      showingList.addAll(reactionList);
    }
    if(topicList.isNotEmpty) {
      showingList.addAll(topicList);
    }}

  void removeTopicItem(TopicMessage rem) {
    for(int i =0; i<topicList.length; i++) {
      if(topicList[i].senderId == rem.senderId) {
        topicList.removeAt(i);
        mergeLists();
        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return buildItem(rem.senderId, rem.senderName, animation, isAdmin, "topic");
        };
        listKey.currentState?.removeItem(reactionList.length+i, builder);
      }
    }
  }

  void removeReactionItem(TopicMessage rem) {
    for(int i =0; i<reactionList.length; i++) {
      if(reactionList[i].senderId == rem.senderId) {
        reactionList.removeAt(i);
        mergeLists();
        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return buildItem(rem.senderId, rem.senderName, animation, isAdmin, "reaction");
        };
        listKey.currentState?.removeItem(i, builder);
      }
    }
  }
}

