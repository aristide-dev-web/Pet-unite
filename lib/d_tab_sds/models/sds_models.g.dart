// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sds_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LostAnimalAdapter extends TypeAdapter<LostAnimal> {
  @override
  final int typeId = 11;

  @override
  LostAnimal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LostAnimal(
      id: fields[0] as String,
      nome: fields[1] as String,
      tipo: fields[2] as String,
      razza: fields[3] as String,
      sesso: fields[4] as String,
      immagini: (fields[5] as List).cast<String>(),
      ricompensa: fields[6] as String?,
      haCicatrici: fields[7] as bool,
      uidUtente: fields[8] as String,
      via: fields[9] as String,
      citta: fields[10] as String,
      dataSmarrimento: fields[11] as String?,
      lat: fields[12] as double?,
      lng: fields[13] as double?,
      timestamp: fields[14] as DateTime?,
      rawData: (fields[15] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LostAnimal obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.razza)
      ..writeByte(4)
      ..write(obj.sesso)
      ..writeByte(5)
      ..write(obj.immagini)
      ..writeByte(6)
      ..write(obj.ricompensa)
      ..writeByte(7)
      ..write(obj.haCicatrici)
      ..writeByte(8)
      ..write(obj.uidUtente)
      ..writeByte(9)
      ..write(obj.via)
      ..writeByte(10)
      ..write(obj.citta)
      ..writeByte(11)
      ..write(obj.dataSmarrimento)
      ..writeByte(12)
      ..write(obj.lat)
      ..writeByte(13)
      ..write(obj.lng)
      ..writeByte(14)
      ..write(obj.timestamp)
      ..writeByte(15)
      ..write(obj.rawData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LostAnimalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustodiaAnimalAdapter extends TypeAdapter<CustodiaAnimal> {
  @override
  final int typeId = 12;

  @override
  CustodiaAnimal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustodiaAnimal(
      id: fields[0] as String,
      nome: fields[1] as String,
      tipo: fields[2] as String,
      razza: fields[3] as String,
      sesso: fields[4] as String,
      immagini: (fields[5] as List).cast<String>(),
      haCicatrici: fields[6] as bool,
      uidUtente: fields[7] as String,
      via: fields[8] as String,
      citta: fields[9] as String,
      lat: fields[10] as double?,
      lng: fields[11] as double?,
      timestamp: fields[12] as DateTime?,
      rawData: (fields[13] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustodiaAnimal obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.razza)
      ..writeByte(4)
      ..write(obj.sesso)
      ..writeByte(5)
      ..write(obj.immagini)
      ..writeByte(6)
      ..write(obj.haCicatrici)
      ..writeByte(7)
      ..write(obj.uidUtente)
      ..writeByte(8)
      ..write(obj.via)
      ..writeByte(9)
      ..write(obj.citta)
      ..writeByte(10)
      ..write(obj.lat)
      ..writeByte(11)
      ..write(obj.lng)
      ..writeByte(12)
      ..write(obj.timestamp)
      ..writeByte(13)
      ..write(obj.rawData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustodiaAnimalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdozioneAnimalAdapter extends TypeAdapter<AdozioneAnimal> {
  @override
  final int typeId = 13;

  @override
  AdozioneAnimal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdozioneAnimal(
      id: fields[0] as String,
      nome: fields[1] as String,
      tipo: fields[2] as String,
      razza: fields[3] as String,
      sesso: fields[4] as String,
      immagini: (fields[5] as List).cast<String>(),
      eta: fields[6] as String?,
      vaccinato: fields[7] as bool,
      castrato: fields[8] as bool,
      uidUtente: fields[9] as String,
      via: fields[10] as String,
      citta: fields[11] as String,
      lat: fields[12] as double?,
      lng: fields[13] as double?,
      timestamp: fields[14] as DateTime?,
      rawData: (fields[15] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AdozioneAnimal obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.razza)
      ..writeByte(4)
      ..write(obj.sesso)
      ..writeByte(5)
      ..write(obj.immagini)
      ..writeByte(6)
      ..write(obj.eta)
      ..writeByte(7)
      ..write(obj.vaccinato)
      ..writeByte(8)
      ..write(obj.castrato)
      ..writeByte(9)
      ..write(obj.uidUtente)
      ..writeByte(10)
      ..write(obj.via)
      ..writeByte(11)
      ..write(obj.citta)
      ..writeByte(12)
      ..write(obj.lat)
      ..writeByte(13)
      ..write(obj.lng)
      ..writeByte(14)
      ..write(obj.timestamp)
      ..writeByte(15)
      ..write(obj.rawData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdozioneAnimalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
