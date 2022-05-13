// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      roomName: json['roomName'] as String?,
      ownerId: json['ownerId'] as String?,
      users: (json['users'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      isStarted: json['isStarted'] as bool?,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'roomName': instance.roomName,
      'ownerId': instance.ownerId,
      'users': instance.users,
      'isStarted': instance.isStarted,
    };
