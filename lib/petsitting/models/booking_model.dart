import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 8)
enum BookingStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  accepted,
  @HiveField(2)
  declined,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled
}

@HiveType(typeId: 9)
class PetBooking extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String sitterId;
  @HiveField(2)
  final String ownerId;
  @HiveField(3)
  final String petId; 
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime endDate;
  @HiveField(6)
  final String serviceType;
  @HiveField(7)
  final double totalPrice;
  @HiveField(8)
  final BookingStatus status;
  @HiveField(9)
  final String note;
  @HiveField(10)
  final int petCount;
  @HiveField(11)
  final String checkInTime; 
  @HiveField(12)
  final String checkOutTime;
  @HiveField(13)
  final String? stripePaymentMethodId;
  @HiveField(14)
  final bool deletedByOwner;
  @HiveField(15)
  final bool deletedBySitter;
  @HiveField(16)
  final String paymentStatus;

  @HiveField(17)
  final List<String> selectedTimes; // ✅ Orari specifici selezionati

  @HiveField(18)
  final String? location; // ✅ Zona/Indirizzo della prestazione

  @HiveField(19)
  final List<Map<String, dynamic>> petsInfo; // ✅ Info dettagliate pet (nome, foto)

  @HiveField(20)
  final String? ownerName; // ✅ Nome del proprietario

  @HiveField(21)
  final String? ownerPhotoUrl; // ✅ Foto del proprietario

  PetBooking({
    required this.id,
    required this.sitterId,
    required this.ownerId,
    required this.petId,
    required this.startDate,
    required this.endDate,
    required this.serviceType,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.note = "",
    this.petCount = 1,
    this.checkInTime = "10:00",
    this.checkOutTime = "18:00",
    this.stripePaymentMethodId,
    this.deletedByOwner = false,
    this.deletedBySitter = false,
    this.paymentStatus = 'none',
    this.selectedTimes = const [],
    this.location,
    this.petsInfo = const [],
    this.ownerName,
    this.ownerPhotoUrl,
  });

  factory PetBooking.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    String statusStr = data['status'] ?? 'pending';
    if (statusStr == 'rejected') statusStr = 'declined';

    return PetBooking(
      id: id,
      sitterId: data['sitterId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      petId: data['petId'] ?? 'DEFAULT_PET',
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      serviceType: data['serviceType'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr,
        orElse: () => BookingStatus.pending,
      ),
      note: data['note'] ?? '',
      petCount: data['petCount'] ?? 1,
      checkInTime: data['checkInTime'] ?? "10:00",
      checkOutTime: data['checkOutTime'] ?? "18:00",
      stripePaymentMethodId: data['stripePaymentMethodId'],
      deletedByOwner: data['deletedByOwner'] ?? false,
      deletedBySitter: data['deletedBySitter'] ?? false,
      paymentStatus: data['paymentStatus'] ?? 'none',
      selectedTimes: List<String>.from(data['selectedTimes'] ?? []),
      location: data['location'],
      petsInfo: (data['petsInfo'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      ownerName: data['ownerName'],
      ownerPhotoUrl: data['ownerPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sitterId': sitterId,
      'ownerId': ownerId,
      'petId': petId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'serviceType': serviceType,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'note': note,
      'petCount': petCount,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'stripePaymentMethodId': stripePaymentMethodId,
      'deletedByOwner': deletedByOwner,
      'deletedBySitter': deletedBySitter,
      'paymentStatus': paymentStatus,
      'selectedTimes': selectedTimes,
      'location': location,
      'petsInfo': petsInfo,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  static PetBooking fromFirestore(DocumentSnapshot doc) {
    return PetBooking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
