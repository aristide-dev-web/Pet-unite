// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 10;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      username: fields[1] as String,
      nome: fields[2] as String,
      cognome: fields[3] as String,
      bio: fields[4] as String,
      dataNascita: fields[5] as String,
      sesso: fields[6] as String,
      fotoUrl: fields[7] as String,
      emails: (fields[8] as List).cast<String>(),
      telefoni: (fields[9] as List).cast<String>(),
      whatsapp: (fields[10] as List).cast<String>(),
      nazione: fields[11] as String,
      regione: fields[12] as String,
      citta: fields[13] as String,
      indirizzo: fields[14] as String,
      lat: fields[15] as double?,
      lng: fields[16] as double?,
      visibilita: (fields[17] as Map).cast<String, bool>(),
      isPetSitter: fields[18] as bool,
      quartiere: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.cognome)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.dataNascita)
      ..writeByte(6)
      ..write(obj.sesso)
      ..writeByte(7)
      ..write(obj.fotoUrl)
      ..writeByte(8)
      ..write(obj.emails)
      ..writeByte(9)
      ..write(obj.telefoni)
      ..writeByte(10)
      ..write(obj.whatsapp)
      ..writeByte(11)
      ..write(obj.nazione)
      ..writeByte(12)
      ..write(obj.regione)
      ..writeByte(13)
      ..write(obj.citta)
      ..writeByte(14)
      ..write(obj.indirizzo)
      ..writeByte(15)
      ..write(obj.lat)
      ..writeByte(16)
      ..write(obj.lng)
      ..writeByte(17)
      ..write(obj.visibilita)
      ..writeByte(18)
      ..write(obj.isPetSitter)
      ..writeByte(19)
      ..write(obj.quartiere);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
