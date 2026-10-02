// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialStoryAdapter extends TypeAdapter<SocialStory> {
  @override
  final int typeId = 14;

  @override
  SocialStory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialStory(
      id: fields[0] as String,
      uid: fields[1] as String,
      autore: fields[2] as String,
      fotoProfilo: fields[3] as String?,
      immagineUrl: fields[4] as String,
      audioUrl: fields[5] as String?,
      lat: fields[6] as double?,
      lng: fields[7] as double?,
      timestamp: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialStory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.autore)
      ..writeByte(3)
      ..write(obj.fotoProfilo)
      ..writeByte(4)
      ..write(obj.immagineUrl)
      ..writeByte(5)
      ..write(obj.audioUrl)
      ..writeByte(6)
      ..write(obj.lat)
      ..writeByte(7)
      ..write(obj.lng)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialStoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
