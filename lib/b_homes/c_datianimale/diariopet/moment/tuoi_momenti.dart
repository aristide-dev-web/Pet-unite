import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'place/inverno.dart';
import 'place/estate.dart';
import 'place/primavera.dart';
import 'place/autunno.dart';
import 'collezione_completa.dart';

class TuoiMomenti extends StatefulWidget {
  final String animaleId;

  const TuoiMomenti({super.key, required this.animaleId});

  @override
  State<TuoiMomenti> createState() => _TuoiMomentiState();
}

class _TuoiMomentiState extends State<TuoiMomenti> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBE1), // Carta antica/beige
      appBar: AppBar(
        title: Text("moment_diary_title".tr(), 
          style: const TextStyle(fontFamily: 'Cursive', fontSize: 32, color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5D4037)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Effetto anelli raccoglitore laterale
          Positioned(
            left: 5,
            top: 20,
            bottom: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(8, (index) => Container(
                width: 15,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(2, 2))],
                ),
              )),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              children: [
                // CARD ALBUM COMPLETO - Stile "Copertina"
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => CollezioneCompletaPage(animaleId: widget.animaleId))
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8D6E63),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [const BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(4, 4))],
                        border: Border.all(color: const Color(0xFF5D4037), width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories, color: Colors.white, size: 40),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("moment_my_collection".tr(), 
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Cursive')),
                                Text("moment_browse_photos".tr(), 
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 20,
                    children: [
                      _buildPolaroidCard(
                        context,
                        "season_winter".tr(),
                        Icons.ac_unit,
                        Colors.blue[300]!,
                        InvernoMomentiPage(animaleId: widget.animaleId),
                        -0.05, // Inclinazione
                      ),
                      _buildPolaroidCard(
                        context,
                        "season_summer".tr(),
                        Icons.wb_sunny,
                        Colors.orange[400]!,
                        MareMomentiPage(animaleId: widget.animaleId),
                        0.04,
                      ),
                      _buildPolaroidCard(
                        context,
                        "season_spring".tr(),
                        Icons.local_florist,
                        Colors.pink[300]!,
                        PrimaveraMomentiPage(animaleId: widget.animaleId),
                        -0.03,
                      ),
                      _buildPolaroidCard(
                        context,
                        "season_autumn".tr(),
                        Icons.eco,
                        Colors.orange[800]!,
                        AutunnoMomentiPage(animaleId: widget.animaleId),
                        0.05,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidCard(BuildContext context, String title, IconData icon, Color color, Widget page, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(5, 5),
              )
            ],
          ),
          child: Column(
            children: [
              // Area "Foto"
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: color.withOpacity(0.1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(icon, size: 50, color: color.withOpacity(0.5)),
                      // Effetto "nastro adesivo" nell'angolo
                      Positioned(
                        top: -5,
                        left: -15,
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Container(
                            width: 50,
                            height: 20,
                            color: Colors.yellow.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Didascalia scritta a mano
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
