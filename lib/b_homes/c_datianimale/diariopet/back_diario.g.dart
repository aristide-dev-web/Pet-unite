// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'back_diario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimaleAdapter extends TypeAdapter<Animale> {
  @override
  final int typeId = 3;

  @override
  Animale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Animale(
      id: fields[0] as String,
      nome: fields[1] as String,
      tipo: fields[2] as String,
      razza: fields[3] as String,
      sesso: fields[4] as String,
      day: fields[5] as String,
      month: fields[6] as String,
      year: fields[7] as String,
      coloreDominante: fields[8] as String,
      coloreSecondario: fields[9] as String,
      coloreTerziario: fields[10] as String,
      peloGrandezza: fields[11] as String,
      peloTipo: fields[12] as String,
      codaGrandezza: fields[13] as String,
      codaTipo: fields[14] as String,
      orecchieGrandezza: fields[15] as String,
      orecchieTipo: fields[16] as String,
      occhiColore: fields[17] as String,
      occhiForma: fields[18] as String,
      taglia: fields[19] as String,
      microchip: fields[20] as String,
      microchipNumero: fields[21] as String,
      vaccinato: fields[22] as String,
      riproduttivo: fields[23] as String,
      iperteso: fields[24] as String,
      allergico: fields[25] as String,
      allergie: fields[26] as String,
      passaporto: fields[27] as String,
      passaportoNumero: fields[28] as String,
      passaportoNote: fields[29] as String,
      noteGenerali: fields[30] as String,
      fotoUrl: fields[31] as String?,
      peso: fields[32] as String,
      fegato: fields[33] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Animale obj) {
    writer
      ..writeByte(34)
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
      ..write(obj.day)
      ..writeByte(6)
      ..write(obj.month)
      ..writeByte(7)
      ..write(obj.year)
      ..writeByte(8)
      ..write(obj.coloreDominante)
      ..writeByte(9)
      ..write(obj.coloreSecondario)
      ..writeByte(10)
      ..write(obj.coloreTerziario)
      ..writeByte(11)
      ..write(obj.peloGrandezza)
      ..writeByte(12)
      ..write(obj.peloTipo)
      ..writeByte(13)
      ..write(obj.codaGrandezza)
      ..writeByte(14)
      ..write(obj.codaTipo)
      ..writeByte(15)
      ..write(obj.orecchieGrandezza)
      ..writeByte(16)
      ..write(obj.orecchieTipo)
      ..writeByte(17)
      ..write(obj.occhiColore)
      ..writeByte(18)
      ..write(obj.occhiForma)
      ..writeByte(19)
      ..write(obj.taglia)
      ..writeByte(20)
      ..write(obj.microchip)
      ..writeByte(21)
      ..write(obj.microchipNumero)
      ..writeByte(22)
      ..write(obj.vaccinato)
      ..writeByte(23)
      ..write(obj.riproduttivo)
      ..writeByte(24)
      ..write(obj.iperteso)
      ..writeByte(25)
      ..write(obj.allergico)
      ..writeByte(26)
      ..write(obj.allergie)
      ..writeByte(27)
      ..write(obj.passaporto)
      ..writeByte(28)
      ..write(obj.passaportoNumero)
      ..writeByte(29)
      ..write(obj.passaportoNote)
      ..writeByte(30)
      ..write(obj.noteGenerali)
      ..writeByte(31)
      ..write(obj.fotoUrl)
      ..writeByte(32)
      ..write(obj.peso)
      ..writeByte(33)
      ..write(obj.fegato);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
