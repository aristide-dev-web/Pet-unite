import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/booking_model.dart';
import 'package:petping/petsitting/screens/bookings/components/booking_card.dart';
import 'package:petping/petsitting/services/booking_service.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryTeal = const Color(0xFF00AAA0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    BookingService().startBookingSync();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            "ps_bookings_title".tr().toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                          ),
                          Text(
                            "booking_status_active_services".tr(),
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                  tabs: [
                    Tab(text: "ps_bookings_sent".tr()),
                    Tab(text: "ps_bookings_received".tr()),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: currentUserId.isEmpty 
              ? Center(child: Text("ps_bookings_login_required".tr()))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(userId: currentUserId, isSitter: false),
                    _buildBookingList(userId: currentUserId, isSitter: true),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList({required String userId, required bool isSitter}) {
    return ValueListenableBuilder<Box<PetBooking>>(
      valueListenable: Hive.box<PetBooking>('bookings_box').listenable(),
      builder: (context, box, _) {
        final allBookings = box.values.toList();

        final filtered = allBookings.where((b) {
          final matchesUser = isSitter ? b.sitterId == userId : b.ownerId == userId;
          final isNotDeleted = isSitter ? !b.deletedBySitter : !b.deletedByOwner;
          
          final isConfirmed = b.paymentStatus == 'authorized' || b.paymentStatus == 'captured';
          
          return matchesUser && isNotDeleted && isConfirmed;
        }).toList();

        filtered.sort((a, b) => b.id.compareTo(a.id));

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  isSitter ? "ps_bookings_empty_sitter".tr() : "ps_bookings_empty_owner".tr(),
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "booking_status_authorized_only".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final booking = filtered[index];
            return BookingCard(
              booking: booking,
              isSitterView: isSitter,
              primaryColor: primaryTeal,
              rawDoc: booking.toMap(),
            );
          },
        );
      },
    );
  }
}
