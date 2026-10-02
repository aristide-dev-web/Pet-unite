// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialNotificationAdapter extends TypeAdapter<SocialNotification> {
  @override
  final int typeId = 5;

  @override
  SocialNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialNotification(
      id: fields[0] as String,
      fromUserId: fields[1] as String,
      fromUsername: fields[2] as String,
      fromUserPhoto: fields[3] as String?,
      type: fields[4] as String,
      text: fields[5] as String,
      postId: fields[6] as String?,
      timestamp: fields[7] as DateTime,
      isRead: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SocialNotification obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromUserId)
      ..writeByte(2)
      ..write(obj.fromUsername)
      ..writeByte(3)
      ..write(obj.fromUserPhoto)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
      ..write(obj.postId)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
