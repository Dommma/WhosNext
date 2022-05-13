import 'package:json_annotation/json_annotation.dart';

part 'room_model.g.dart';

@JsonSerializable()
class Room {
  final String? roomName;
  final String? ownerId;
  final Map<String, String>? users;
  final bool? isStarted;

  Room( {
    this.roomName,
    this.ownerId,
    this.users,
    this.isStarted
});

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);
}