import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialRoleSelector extends StatefulWidget {
  final String currentUserId;
  final VoidCallback onRoleSelected;

  const SocialRoleSelector({
    super.key, 
    required this.currentUserId, 
    required this.onRoleSelected
  });

  @override
  State<SocialRoleSelector> createState() => _SocialRoleSelectorState();
}

class _SocialRoleSelectorState extends State<SocialRoleSelector> {
  String? _selectedRole;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'proprietario',
      'title': 'social_role_owner_title',
      'subtitle': 'social_role_owner_sub',
      'icon': Icons.pets_rounded,
      'color': const Color(0xFF64B5B4),
    },
    {
      'id': 'veterinario',
      'title': 'social_role_vet_title',
      'subtitle': 'social_role_vet_sub',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFF2C5F78),
    },
    {
      'id': 'associazione',
      'title': 'social_role_assoc_title',
      'subtitle': 'social_role_assoc_sub',
      'icon': Icons.volunteer_activism_rounded,
      'color': const Color(0xFFE67E22),
    },
  ];

  Future<void> _saveRole() async {
    if (_selectedRole == null) return;

    await FirebaseFirestore.instance
        .collection('utenti')
        .doc(widget.currentUserId)
        .update({'socialRole': _selectedRole});
    
    widget.onRoleSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "social_role_title".tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                "social_role_subtitle".tr(),
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    bool isSelected = _selectedRole == role['id'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedRole = role['id']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? role['color'] : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                ? role['color'].withOpacity(0.2) 
                                : Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: role['color'].withOpacity(0.1),
                              child: Icon(role['icon'], color: role['color'], size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (role['title'] as String).tr(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (role['subtitle'] as String).tr(),
                                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: role['color']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _saveRole : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    "social_role_btn_start".tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
