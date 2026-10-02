// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_page_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialPageAdapter extends TypeAdapter<SocialPage> {
  @override
  final int typeId = 6;

  @override
  SocialPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialPage(
      id: fields[0] as String,
      creatorId: fields[1] as String,
      nome: fields[2] as String,
      categoria: fields[3] as String,
      bio: fields[4] as String?,
      fotoProfilo: fields[5] as String?,
      fotoCopertina: fields[6] as String?,
      adminIds: (fields[7] as List).cast<String>(),
      followerIds: (fields[8] as List).cast<String>(),
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialPage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creatorId)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.categoria)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.fotoProfilo)
      ..writeByte(6)
      ..write(obj.fotoCopertina)
      ..writeByte(7)
      ..write(obj.adminIds)
      ..writeByte(8)
      ..write(obj.followerIds)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
