import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/a_main/memory/main_login.dart';
import 'package:petping/b_homes/a_homes/home.dart';
import 'package:petping/social/social_feed_screen.dart';
import 'package:petping/b_homes/d_message/message_listener.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/d_tab_sds/a_tab/tab_sds.dart';
import 'package:petping/a_main/tab/add_choice_screen.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/petsitting/petsitting_main_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int initialSubIndex;
  const MainScreen({super.key, this.initialIndex = 0, this.initialSubIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      MessageListener().start(user.uid);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _showPetSittingMaintenance() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA709A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFFA709A), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "In Arrivo! ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              const Text(
                "Ciao! Il servizio Pet Sitting arriverà tra non molto. 🐾\n\nTi verrà dato un avviso non appena sarà disponibile! Grazie per l'interesse, ti terremo aggiornato! ✨",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA709A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Ho capito, grazie! 😊", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChoice() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddChoiceScreen(currentUserId: user.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginScreen();

    final String userId = user.uid;

    final Color accentColor = _currentIndex == 1
        ? const Color(0xFFE67E22)
        : (_currentIndex == 2 ? const Color(0xFF64B5B4) : Colors.lightBlue[400]!);

    final List<Widget> tabs = [
      HomeScreen(currentUserId: userId),
      SecondaryBottomTabs(
        initialColor: const Color(0xFFE67E22),
        initialIndex: widget.initialSubIndex,
        onBack: () => setState(() => _currentIndex = 0),
      ),
      SocialFeedScreen(currentUserId: userId),
      // Passiamo isActive per gestire correttamente il pop-up di benvenuto
      PetsittingMainScreen(userId: userId, isActive: _currentIndex == 3),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      bottomNavigationBar: _currentIndex == 1
          ? const SizedBox.shrink()
          : Container(
        height: 100,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: BNBClipper(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 80),
                    painter: BNBCustomPainter(borderColor: accentColor.withOpacity(0.2)),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 75,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: Hive.box<ChatPreview>('chatPreviews').listenable(),
                      builder: (context, Box<ChatPreview> box, _) {
                        final unreadCount = box.values.where((p) => p.isRead == false).length;
                        return _buildNavItem(0, Icons.home_rounded, 'nav_home'.tr(),
                            badgeCount: unreadCount,
                            activeColor: accentColor,
                            colors: [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)]);
                      },
                    ),
                    _buildNavItem(1, Icons.pets_rounded, 'nav_sos'.tr(),
                        activeColor: accentColor,
                        colors: [const Color(0xFFE67E22), const Color(0xFFF39C12)]),

                    const SizedBox(width: 70),

                    ValueListenableBuilder(
                      valueListenable: Hive.box<SocialNotification>('social_notifications_box').listenable(),
                      builder: (context, Box<SocialNotification> box, _) {
                        final unreadCount = box.values.where((n) => !n.isRead).length;
                        return _buildNavItem(2, Icons.explore_rounded, 'nav_social'.tr(),
                            badgeCount: unreadCount,
                            activeColor: accentColor,
                            colors: [const Color(0xFFFA709A), const Color(0xFFFEE140)]);
                      },
                    ),
                    _buildNavItem(3, Icons.volunteer_activism_rounded, 'nav_petsitting'.tr(),
                        activeColor: accentColor,
                        colors: [const Color(0xFFFA709A), const Color(0xFFFEE140)]), // Usando i colori definiti nel nav item originale per consistenza grafica
                  ],
                ),
              ),
            ),

            Positioned(
              top: 15,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 4 * _floatController.value),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _showAddChoice,
                  child: _buildCentralButton(accentColor)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int badgeCount = 0, required List<Color> colors, required Color activeColor}) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _showPetSittingMaintenance();
          return;
        }
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: isSelected ? 42 : 0,
                height: isSelected ? 42 : 0,
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.blueGrey[200],
                size: 28,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -10,
                  top: -10,
                  child: _buildFancyBadge(badgeCount, colors),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? activeColor : Colors.blueGrey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralButton(Color color) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3.5),
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 40),
    );
  }

  Widget _buildFancyBadge(int count, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BNBClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double middle = size.width / 2;
    double humpWidth = 180;
    double humpHeight = 35;
    path.moveTo(0, 0);
    path.lineTo(middle - humpWidth / 2 - 20, 0);
    path.cubicTo(middle - humpWidth / 2, 0, middle - humpWidth / 3, -humpHeight, middle, -humpHeight);
    path.cubicTo(middle + humpWidth / 3, -humpHeight, middle + humpWidth / 2, 0, middle + humpWidth / 2 + 20, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BNBCustomPainter extends CustomPainter {
  final Color borderColor;
  BNBCustomPainter({this.borderColor = Colors.transparent});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white.withOpacity(0.95)..style = PaintingStyle.fill;
    Path path = Path();
    double middle = size.width / 2;
    double humpWidth = 180;
    double humpHeight = 35;
    path.moveTo(0, 0);
    path.lineTo(middle - humpWidth / 2 - 20, 0);
    path.cubicTo(middle - humpWidth / 2, 0, middle - humpWidth / 3, -humpHeight, middle, -humpHeight);
    path.cubicTo(middle + humpWidth / 3, -humpHeight, middle + humpWidth / 2, 0, middle + humpWidth / 2 + 20, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path.shift(const Offset(0, -2)), Colors.black.withOpacity(0.12), 12, true);
    canvas.drawPath(path, paint);

    Paint linePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, linePaint);
  }
  @override
  bool shouldRepaint(BNBCustomPainter oldDelegate) => oldDelegate.borderColor != borderColor;
}
