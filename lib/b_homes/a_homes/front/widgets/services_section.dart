import 'package:flutter/material.dart';
import 'package:petping/maps/map_launcher_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'home_section_nearby'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.orangeAccent],
                ).createShader(bounds),
                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCircularServiceBtn(context, Icons.medical_services_rounded, 'service_veterinarians'.tr(), Colors.teal[50]!, Colors.teal[700]!, 'veterinary veterinario'),
              const SizedBox(width: 15),
              _buildCircularServiceBtn(context, Icons.local_hospital_rounded, 'service_clinics_24h'.tr(), Colors.red[50]!, Colors.red[700]!, '24h veterinary emergency'),
              const SizedBox(width: 15),
              _buildCircularServiceBtn(context, Icons.park_rounded, 'service_pet_parks'.tr(), Colors.green[50]!, Colors.green[700]!, 'dog park area cani'),
              const SizedBox(width: 15),
              _buildCircularServiceBtn(context, Icons.shopping_basket_rounded, 'service_pet_shops'.tr(), Colors.blue[50]!, Colors.blue[700]!, 'pet shop negozio animali'),
              const SizedBox(width: 15),
              _buildCircularServiceBtn(context, Icons.hotel_rounded, 'service_pet_boarding'.tr(), Colors.orange[50]!, Colors.orange[700]!, 'pet boarding pensione animali'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularServiceBtn(BuildContext context, IconData icon, String label, Color bgColor, Color iconColor, String keyword) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => MapLauncherService.searchNearby(context, keyword),
            borderRadius: BorderRadius.circular(50),
            splashColor: iconColor.withOpacity(0.2),
            highlightColor: iconColor.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bgColor, bgColor.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54
          )
        ),
      ],
    );
  }
}
