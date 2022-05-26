import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/user_item.dart';
import "package:flutter_gen/gen_l10n/l10n.dart";
import "package:untitled/models/room_model.dart";
import "package:untitled/pages/room_page.dart";

class LobbyPage extends StatelessWidget {
  final String? myUserId;
  final String? myUserName;
  final String? currentRoomId;

  LobbyPage({Key? key, required this.myUserId, required this.myUserName, required this.currentRoomId})
      : super(key: key);

  final listKey = GlobalKey<AnimatedListState>();

  var room = Room();
  bool isAdmin = false;
  bool notFirstRefresh = false;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context)!;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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

            if(notFirstRefresh) {

              final length = room.users?.length;
              for (int i = length! - 1; i >= 0; i--) {
                String removeKey = room.users!.keys.elementAt(0);
                String? removedItem = room.users!.remove(removeKey!);
                AnimatedListRemovedItemBuilder builder = (context, animation) {
                  return buildItem(removeKey, removedItem!, animation, isAdmin, room.ownerId!);
                };
                listKey.currentState?.removeItem(i, builder);
              }
            }

            room =
                Room.fromJson(snapshot.data?.data() as Map<String, dynamic>);
            isAdmin = myUserId == room.ownerId ? true : false;

            if(notFirstRefresh) {

              if(room.isStarted!) {
                WidgetsBinding.instance?.addPostFrameCallback((_) =>
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoomPage(myUserId: myUserId, myUserName: myUserName, currentRoomId: currentRoomId,)))
          );}

              if(!room.users!.containsKey(myUserId)) {
                return AlertDialog(
                  title: Text(l10n.adminKickedYou),
                  actions: [
                    TextButton(
                        child: Text(l10n.backToTheMenu),
                        onPressed: () {
                          Navigator.pop(context, true);
                        }),
                  ],
                );
              }

              for (int offset = 0; offset < room.users!.length; offset++) {
                listKey.currentState?.insertItem(0 + offset);
              }
            }

            notFirstRefresh = true;

            return WillPopScope(
              onWillPop: () async {
                var result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(l10n.areYouSureText),
                        content: Text(isAdmin ? l10n.doYorReallyWantToCloseThisRoomText : l10n.doYouReallyWantToQuitText),
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
                                }
                                else {
                                  removeItem(myUserId!);
                                }
                                Navigator.pop(context, true);
                              }),
                        ],
                      );
                    });
                return result ?? false;
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(room.roomName!+": "+currentRoomId!),
                ),
                body: Column(
                  children: [
                    const SizedBox(
                      height: 6.0,
                    ),
                    Expanded(
                      child: AnimatedList(
                        key: listKey,
                        initialItemCount: room.users!.length,
                        itemBuilder: (context, index, animation) {
                          return buildItem(room.users!.keys.elementAt(index),room.users!.values.elementAt(index), animation, isAdmin, room.ownerId!);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 6.0,
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: startButton(context, l10n),
                        ))
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget buildItem(
          String userId, String userName, Animation<double> animation, bool isAdmin, String adminId) =>
      UserItemWidget(userId, userName, animation, () => removeItem(userId), isAdmin, adminId);

  void removeItem(String userId) {
    String? removedItem = room.users!.remove(userId);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildItem(userId, removedItem!, animation, isAdmin, room.ownerId!);
    };
    listKey.currentState?.removeItem(0, builder);

    final update = <String, dynamic>{
      "users.$userId": FieldValue.delete(),
    };
      FirebaseFirestore.instance.collection("rooms").doc(currentRoomId).update(update);
  }

  Widget? startButton(BuildContext context, L10n l10n) {
    if(!isAdmin) {
      return null;
    }
    else {
      return ElevatedButton(
        onPressed: () {
          FirebaseFirestore.instance.collection("rooms").doc(currentRoomId).update({"isStarted":true});
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoomPage(myUserId: myUserId, myUserName: myUserName, currentRoomId: currentRoomId,)));
        },
        child: Text(l10n.startText),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          minimumSize: const Size(150, 50),
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}
