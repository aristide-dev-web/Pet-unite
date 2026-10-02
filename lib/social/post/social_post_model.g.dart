// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialPostAdapter extends TypeAdapter<SocialPost> {
  @override
  final int typeId = 4;

  @override
  SocialPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialPost(
      id: fields[0] as String,
      uid: fields[1] as String,
      autore: fields[2] as String,
      fotoProfilo: fields[3] as String?,
      testo: fields[4] as String,
      categoria: fields[5] as String,
      ruoloAutore: fields[6] as String,
      immagineUrl: fields[7] as String?,
      timestamp: fields[8] as DateTime?,
      isShared: fields[9] as bool,
      originalPostId: fields[10] as String?,
      originalAutore: fields[11] as String?,
      eventDate: fields[12] as DateTime?,
      eventLocation: fields[13] as String?,
      eventLink: fields[14] as String?,
      lat: fields[15] as double?,
      lng: fields[16] as double?,
      eventEndDate: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialPost obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.autore)
      ..writeByte(3)
      ..write(obj.fotoProfilo)
      ..writeByte(4)
      ..write(obj.testo)
      ..writeByte(5)
      ..write(obj.categoria)
      ..writeByte(6)
      ..write(obj.ruoloAutore)
      ..writeByte(7)
      ..write(obj.immagineUrl)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.isShared)
      ..writeByte(10)
      ..write(obj.originalPostId)
      ..writeByte(11)
      ..write(obj.originalAutore)
      ..writeByte(12)
      ..write(obj.eventDate)
      ..writeByte(13)
      ..write(obj.eventLocation)
      ..writeByte(14)
      ..write(obj.eventLink)
      ..writeByte(15)
      ..write(obj.lat)
      ..writeByte(16)
      ..write(obj.lng)
      ..writeByte(17)
      ..write(obj.eventEndDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
