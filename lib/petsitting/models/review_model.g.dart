// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetReviewAdapter extends TypeAdapter<PetReview> {
  @override
  final int typeId = 15;

  @override
  PetReview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetReview(
      id: fields[0] as String,
      sitterId: fields[1] as String,
      reviewerId: fields[2] as String,
      reviewerName: fields[3] as String,
      rating: fields[4] as double,
      comment: fields[5] as String,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PetReview obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sitterId)
      ..writeByte(2)
      ..write(obj.reviewerId)
      ..writeByte(3)
      ..write(obj.reviewerName)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
