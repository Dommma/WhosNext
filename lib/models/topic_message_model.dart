import 'package:json_annotation/json_annotation.dart';

part 'topic_message_model.g.dart';

@JsonSerializable()
class TopicMessage {
  final String? senderId;
  final String? senderName;
  final int? timeStamp;
  final String? type;

  TopicMessage({
    this.senderId,
    this.senderName,
    this.timeStamp,
    this.type
});

  factory TopicMessage.fromJson(Map<String, dynamic> json) => _$TopicMessageFromJson(json);
  Map<String, dynamic> toJson() => _$TopicMessageToJson(this);
}