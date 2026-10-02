import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/d_message/widgets/booking_actions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../petsitting/screens/search/components/sections/sitter_ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../c_datianimale/diariopet/diario_pet.dart';

class BookingRequestBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String chatId;
  final String currentUserId;

  const BookingRequestBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final data = message.bookingData ?? {};
    final String bid = data['id']?.toString() ?? '';

    if (bid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(bid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final dbData = snapshot.data?.data() as Map<String, dynamic>?;
        if (dbData == null) return const SizedBox.shrink();

        final status = dbData['status']?.toString() ?? 'pending';
        final payStatus = dbData['paymentStatus']?.toString() ?? 'none';
        
        final rawPrice = dbData['totalPrice'];
        double price = 0.0;
        if (rawPrice is num) {
          price = rawPrice.toDouble();
        } else if (rawPrice is String) {
          price = double.tryParse(rawPrice) ?? 0.0;
        }

        final sitterId = dbData['sitterId']?.toString() ?? message.receiverId;
        final serviceCode = dbData['serviceCode']?.toString();
        final String serviceType = dbData['serviceType']?.toString() ?? 'booking_request_default_service'.tr();
        
        DateTime? startDate;
        if (dbData['startDate'] is Timestamp) {
          startDate = (dbData['startDate'] as Timestamp).toDate();
        } else if (dbData['startDate'] is String) {
          startDate = DateTime.tryParse(dbData['startDate']);
        }

        DateTime? endDate;
        if (dbData['endDate'] is Timestamp) {
          endDate = (dbData['endDate'] as Timestamp).toDate();
        } else if (dbData['endDate'] is String) {
          endDate = DateTime.tryParse(dbData['endDate']);
        }
        
        final List<dynamic> petsInfo = dbData['petsInfo'] is List ? dbData['petsInfo'] : [];
        final List<dynamic> selectedTimes = dbData['selectedTimes'] is List ? dbData['selectedTimes'] : [];

        final String? sitterRealName = dbData['sitterRealName']?.toString();
        final String? sitterPhone = dbData['sitterPhone']?.toString();
        
        final String? ownerNameFromDb = dbData['ownerName']?.toString();
        final String? ownerPhotoFromDb = dbData['ownerPhotoUrl']?.toString();
        final String ownerId = dbData['ownerId']?.toString() ?? message.senderId;

        return FutureBuilder<DocumentSnapshot?>(
          future: (ownerNameFromDb == null || ownerNameFromDb.isEmpty || ownerPhotoFromDb == null || ownerPhotoFromDb.isEmpty)
              ? FirebaseFirestore.instance.collection('utenti').doc(ownerId).get()
              : Future<DocumentSnapshot?>.value(null),
          builder: (context, userSnapshot) {
            String displayPhoto = ownerPhotoFromDb ?? '';
            String displayName = ownerNameFromDb ?? '';

            if (userSnapshot.hasData && userSnapshot.data != null) {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              if (userData != null) {
                if (displayPhoto.isEmpty) displayPhoto = userData['fotoUrl']?.toString() ?? '';
                if (displayName.isEmpty) displayName = userData['username']?.toString() ?? userData['nickname']?.toString() ?? 'label_user'.tr();
              }
            }

            if (displayName.isEmpty) displayName = 'label_user'.tr();

            return Container(
              width: MediaQuery.of(context).size.width * 0.85,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _getStatusColor(status).withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(status, serviceType, displayName, displayPhoto),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainPrice(price),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle('booking_bubble_pets_section'.tr()),
                          _buildPetsRow(petsInfo, context),
                          const SizedBox(height: 16),
                          
                          _buildSectionTitle('booking_bubble_details_section'.tr()),
                          _buildDetailRow(Icons.calendar_today_rounded, _formatDateRange(context, startDate, endDate)),
                          if (selectedTimes.isNotEmpty)
                            _buildDetailRow(Icons.access_time_filled_rounded, selectedTimes.join(", ")),
                          
                          if (dbData['location'] != null && dbData['location'].toString().isNotEmpty)
                            _buildDetailRow(Icons.location_on_rounded, dbData['location'].toString()),

                          if (dbData['note'] != null && dbData['note'].toString().isNotEmpty)
                             _buildNoteBox(dbData['note'].toString()),
                        ],
                      ),
                    ),

                    if (payStatus.toLowerCase() == 'authorized' && sitterRealName != null)
                      _buildContactInfo(sitterRealName, sitterPhone),

                    const Divider(height: 1),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: BookingActions(
                        bid: bid,
                        status: status,
                        payStatus: payStatus,
                        price: price,
                        sitterId: sitterId,
                        serviceCode: serviceCode,
                        startDate: startDate,
                        checkInTime: dbData['checkInTime']?.toString(),
                        isMe: isMe,
                        chatId: chatId,
                        currentUserId: currentUserId,
                        originalMessage: message,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPetsRow(List<dynamic> pets, BuildContext context) {
    if (pets.isEmpty) return Text('booking_bubble_no_pets'.tr(), style: const TextStyle(fontSize: 12));
    
    return Container(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index] is Map ? pets[index] : {};
          final String petId = pet['id']?.toString() ?? '';
          final String fotoUrl = pet['fotoUrl']?.toString() ?? '';
          final String nome = pet['nome']?.toString() ?? 'Pet';
          final bool isManual = pet['isManual'] == true;

          return GestureDetector(
            onTap: () {
              if (petId.isNotEmpty && !isManual) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text('pet_diary_title'.tr(args: [nome])), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
                      body: DiarioPet(animaleId: petId),
                    )
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: SitterUIHelpers.primaryIndigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: SitterUIHelpers.primaryIndigo.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: SitterUIHelpers.primaryIndigo.withOpacity(0.2),
                    backgroundImage: (fotoUrl.isNotEmpty && !isManual) ? NetworkImage(fotoUrl) : null,
                    child: (fotoUrl.isEmpty || isManual) ? Icon(isManual ? Icons.pets_rounded : Icons.pets, size: 14, color: SitterUIHelpers.primaryIndigo) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: SitterUIHelpers.textColor),
                  ),
                  if (!isManual)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.auto_awesome_rounded, size: 10, color: Colors.amber),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: SitterUIHelpers.primaryIndigo),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SitterUIHelpers.textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBox(String note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_rounded, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: TextStyle(fontSize: 12, color: Colors.brown[700], fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPrice(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('booking_bubble_quote'.tr(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
            Text(
              "€${price.toInt()}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor, letterSpacing: -1),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SitterUIHelpers.accentEmerald,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'booking_bubble_guaranteed'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9),
          ),
        ),
      ],
    );
  }

  String _formatDateRange(BuildContext context, DateTime? start, DateTime? end) {
    if (start == null) return 'booking_bubble_date_not_specified'.tr();
    final DateFormat formatter = DateFormat('d MMM', context.locale.languageCode);
    if (end == null || start.isAtSameMomentAs(end)) {
      return formatter.format(start);
    }
    return "${formatter.format(start)} - ${formatter.format(end)}";
  }

  Widget _buildContactInfo(String name, String? phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.lightBlue, size: 16),
              const SizedBox(width: 8),
              Text('booking_bubble_verified_contacts'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.lightBlue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: SitterUIHelpers.textColor)),
                    if (phone != null)
                      Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (phone != null)
                IconButton(
                  onPressed: () => launchUrl(Uri.parse("tel:$phone")),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.lightBlue),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String status, String serviceType, String displayName, String displayPhoto) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        border: Border(bottom: BorderSide(color: _getStatusColor(status).withOpacity(0.2))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _getStatusColor(status),
            backgroundImage: displayPhoto.isNotEmpty ? NetworkImage(displayPhoto) : null,
            child: displayPhoto.isEmpty
              ? Text(_getStatusEmoji(status), style: const TextStyle(fontSize: 14))
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_bubble_from_user'.tr(args: [displayName.toUpperCase()]),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.0, color: _getStatusColor(status)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  serviceType.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: SitterUIHelpers.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (status != 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(10)),
              child: Text(_getStatusText(status).toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'accepted': return "✔️";
      case 'declined': return "✕";
      case 'counter_offered': return "⚖️";
      case 'completed': return "✨";
      default: return "🐾";
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted': return 'booking_bubble_status_accepted'.tr();
      case 'declined': return 'booking_bubble_status_declined'.tr();
      case 'counter_offered': return 'booking_bubble_status_counter'.tr();
      case 'completed': return 'booking_bubble_status_completed'.tr();
      default: return 'booking_bubble_status_pending'.tr();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return SitterUIHelpers.accentEmerald;
      case 'declined': return Colors.redAccent;
      case 'counter_offered': return Colors.orangeAccent;
      case 'completed': return SitterUIHelpers.accentEmerald;
      default: return SitterUIHelpers.primaryIndigo;
    }
  }
}
