// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetBookingAdapter extends TypeAdapter<PetBooking> {
  @override
  final int typeId = 9;

  @override
  PetBooking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetBooking(
      id: fields[0] as String,
      sitterId: fields[1] as String,
      ownerId: fields[2] as String,
      petId: fields[3] as String,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      serviceType: fields[6] as String,
      totalPrice: fields[7] as double,
      status: fields[8] as BookingStatus,
      note: fields[9] as String,
      petCount: fields[10] as int,
      checkInTime: fields[11] as String,
      checkOutTime: fields[12] as String,
      stripePaymentMethodId: fields[13] as String?,
      deletedByOwner: fields[14] as bool,
      deletedBySitter: fields[15] as bool,
      paymentStatus: fields[16] as String,
      selectedTimes: (fields[17] as List).cast<String>(),
      location: fields[18] as String?,
      petsInfo: (fields[19] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, PetBooking obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sitterId)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.petId)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.serviceType)
      ..writeByte(7)
      ..write(obj.totalPrice)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.petCount)
      ..writeByte(11)
      ..write(obj.checkInTime)
      ..writeByte(12)
      ..write(obj.checkOutTime)
      ..writeByte(13)
      ..write(obj.stripePaymentMethodId)
      ..writeByte(14)
      ..write(obj.deletedByOwner)
      ..writeByte(15)
      ..write(obj.deletedBySitter)
      ..writeByte(16)
      ..write(obj.paymentStatus)
      ..writeByte(17)
      ..write(obj.selectedTimes)
      ..writeByte(18)
      ..write(obj.location)
      ..writeByte(19)
      ..write(obj.petsInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetBookingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookingStatusAdapter extends TypeAdapter<BookingStatus> {
  @override
  final int typeId = 8;

  @override
  BookingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookingStatus.pending;
      case 1:
        return BookingStatus.accepted;
      case 2:
        return BookingStatus.declined;
      case 3:
        return BookingStatus.completed;
      case 4:
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BookingStatus obj) {
    switch (obj) {
      case BookingStatus.pending:
        writer.writeByte(0);
        break;
      case BookingStatus.accepted:
        writer.writeByte(1);
        break;
      case BookingStatus.declined:
        writer.writeByte(2);
        break;
      case BookingStatus.completed:
        writer.writeByte(3);
        break;
      case BookingStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
