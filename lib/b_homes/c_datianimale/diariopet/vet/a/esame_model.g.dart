// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esame_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EsameAdapter extends TypeAdapter<Esame> {
  @override
  final int typeId = 2;

  @override
  Esame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Esame(
      id: fields[0] as String,
      categoria: fields[1] as String,
      titolo: fields[2] as String,
      descrizione: fields[3] as String,
      data: fields[4] as String,
      ora: fields[5] as String,
      fileUrls: (fields[6] as List).cast<String>(),
      tipiFile: (fields[7] as List).cast<String>(),
      dimensioniFile: (fields[8] as List).cast<int>(),
      valore: fields[9] as String?,
      unita: fields[10] as String?,
      range: fields[11] as String?,
      autore: fields[12] as String?,
      tags: (fields[13] as List?)?.cast<String>(),
      commentiCount: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Esame obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoria)
      ..writeByte(2)
      ..write(obj.titolo)
      ..writeByte(3)
      ..write(obj.descrizione)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.ora)
      ..writeByte(6)
      ..write(obj.fileUrls)
      ..writeByte(7)
      ..write(obj.tipiFile)
      ..writeByte(8)
      ..write(obj.dimensioniFile)
      ..writeByte(9)
      ..write(obj.valore)
      ..writeByte(10)
      ..write(obj.unita)
      ..writeByte(11)
      ..write(obj.range)
      ..writeByte(12)
      ..write(obj.autore)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.commentiCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EsameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
