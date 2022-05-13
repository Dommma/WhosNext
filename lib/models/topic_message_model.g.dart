// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicMessage _$TopicMessageFromJson(Map<String, dynamic> json) => TopicMessage(
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      timeStamp: json['timeStamp'] as int?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TopicMessageToJson(TopicMessage instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'timeStamp': instance.timeStamp,
      'type': instance.type,
    };
