import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petping/a_registrazione/a/age_confirmation.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSettings extends StatefulWidget {
  final bool isFromSettings;
  const LanguageSettings({super.key, this.isFromSettings = false});

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  String? _linguaTemporanea; 

  final Map<String, String> _lingueDisponibili = {
    'it': 'Italiano',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  @override
  void initState() {
    super.initState();
    // Se veniamo dalle impostazioni, pre-selezioniamo la lingua corrente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _linguaTemporanea = context.locale.languageCode;
      });
    });
  }

  Future<void> _confermaESalva() async {
    if (_linguaTemporanea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language to continue')),
      );
      return;
    }

    // 1. Cambia la lingua effettiva dell'app tramite EasyLocalization
    await context.setLocale(Locale(_linguaTemporanea!));

    // 2. Salva la preferenza localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lingua_scelta', _linguaTemporanea!);
    
    if (mounted) {
      if (widget.isFromSettings) {
        // Se veniamo dalle impostazioni, torniamo indietro invece di andare alla conferma età
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AgeConfirmationScreen()),
        );
      }
    }
  }

  void _mostraSelettoreLingua() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                const Text('Choose Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _lingueDisponibili.length,
                    itemBuilder: (context, index) {
                      final entry = _lingueDisponibili.entries.elementAt(index);
                      return ListTile(
                        title: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: _linguaTemporanea == entry.key ? const Icon(Icons.check_circle, color: Colors.lightBlue) : null,
                        onTap: () {
                          setState(() {
                            _linguaTemporanea = entry.key;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAzure = Colors.lightBlue[400]!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sfondi/lenguage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 100.0, top: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'WELCOME TO PETPING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black87, offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "The app for you and your pet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black87, offset: Offset(1, 1))],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55),
                    child: GestureDetector(
                      onTap: _mostraSelettoreLingua,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.language, color: Colors.lightBlue),
                            Expanded(
                              child: Text(
                                _lingueDisponibili[_linguaTemporanea] ?? 'Select Language',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _confermaESalva,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _linguaTemporanea != null ? primaryAzure : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
