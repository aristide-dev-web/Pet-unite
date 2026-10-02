import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterChipsBar extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {"label": "ps_service_all", "icon": Icons.grid_view_rounded},
    {"label": "ps_service_home_visit", "icon": Icons.home_rounded},
    {"label": "ps_service_boarding", "icon": Icons.night_shelter_rounded},
    {"label": "ps_service_walk", "icon": Icons.explore_rounded},
    {"label": "ps_service_bath", "icon": Icons.auto_awesome_rounded},
    {"label": "ps_service_grooming", "icon": Icons.content_cut_rounded},
    {"label": "ps_service_medicine", "icon": Icons.health_and_safety_rounded},
    {"label": "ps_service_taxi", "icon": Icons.local_taxi_rounded},
  ];

  final String selectedService;
  final Function(String) onServiceSelected;

  FilterChipsBar({
    super.key,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              _buildGettone(context, services[0]),
              _buildGettone(context, services[1]),
              _buildGettone(context, services[2]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGettone(context, services[3]),
              _buildGettone(context, services[4]),
              _buildGettone(context, services[5]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGettone(context, services[6]),
              _buildGettone(context, services[7]),
              const Spacer(), 
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGettone(BuildContext context, Map<String, dynamic> service) {
    final String key = service['label'];
    final String label = key.tr();
    final IconData icon = service['icon'];
    
    bool isSelected;
    if (key == "ps_service_all") {
      isSelected = selectedService.isEmpty;
    } else {
      isSelected = selectedService == label;
    }

    final Color primaryIndigo = const Color(0xFF6366F1);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (key == "ps_service_all") {
            onServiceSelected("");
          } else {
            onServiceSelected(isSelected ? "" : label);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? primaryIndigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected 
              ? [BoxShadow(color: primaryIndigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
            border: Border.all(
              color: isSelected ? primaryIndigo : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : primaryIndigo,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
