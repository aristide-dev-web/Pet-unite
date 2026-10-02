import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'sections/section_a_identita.dart';
import 'sections/section_b_esperienza.dart';
import 'sections/section_c_servizi.dart';
import 'sections/section_d_attrezzatura.dart';
import 'sections/section_e_preferenze.dart';
import 'sections/section_f_pagamenti.dart';
import 'sections/step_9_revisione.dart';
import 'sections/step_10_inviato.dart';

class SitterRegistrationView extends StatelessWidget {
  final int currentStep;
  final PageController pageController;
  final bool isEditing;
  final bool isLoading;
  final Color primaryIndigo;
  final Color bgLight;
  final Color textColor;

  // Controllers
  final TextEditingController nicknameController;
  final TextEditingController nomeController;
  final TextEditingController cognomeController;
  final TextEditingController dataNascitaController;
  final TextEditingController bioBreveController;
  final TextEditingController nazioneController;
  final TextEditingController regioneController;
  final TextEditingController cittaController;
  final TextEditingController indirizzoController;
  final TextEditingController quartiereController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final TextEditingController anniEsperienzaController;
  final TextEditingController descrizioneAltroController;
  final TextEditingController attrezzaturaAltroController;

  // State & Callbacks
  final String telefonoPrefix;
  final Function(String) onPrefixChanged;
  final double? lat;
  final double? lng;
  final Function(double, double) onLocationFound;
  final File? fotoProfiloPro;
  final String? existingFotoUrl;
  final Function(File?) onFotoProPicked;
  final File? docFronte;
  final Function(File?) onDocFrontePicked;
  final bool emailVerified;
  final bool phoneVerified;
  final bool identityVerified;
  final Function(bool) onEmailVerifiedChanged;
  final Function(bool) onPhoneVerifiedChanged;
  final Function(bool) onIdentityVerified;

  final List<String> specieEsperienza;
  final bool prenotazioneLastMinute;
  final Function(String, bool) onSpecieChanged;
  final Function(bool) onLastMinuteChanged;
  final double raggioKm;
  final Function(double) onRaggioKmChanged;

  final List<File?> fotoInserzioneFiles;
  final List<String> existingFotoInserzioneUrls;
  final Function(List<File>) onMultiFotoInserzionePicked;
  final Function(int) onFotoInserzioneRemoved;
  final Function(int) onExistingFotoInserzioneRemoved;

  final List<Map<String, dynamic>> certifications;
  final Function(File, String, String?) onCertificationAdded;
  final Function(int) onCertificationRemoved;

  final List<String> competenze;
  final Function(String, bool) onSkillToggled;

  final bool bisogniSpeciali;
  final bool somministrazioneFarmaci;
  final bool gestioneAnimaliDifficili;
  final Function(bool) onBisogniSpecialiChanged;
  final Function(bool) onFarmaciChanged;
  final Function(bool) onDifficiliChanged;

  // Servizi
  final Map<String, bool> serviziAttivi;
  final Map<String, double> serviziPrezzi;
  final Map<String, int> serviziMaxAnimali;
  final Map<String, String> serviziOrari;
  final Map<String, String> serviziNote;
  final Map<String, String> serviziDurata;
  final Map<String, double> serviziWeekendExtra;
  final Map<String, bool> serviziWeekendAttivi;
  final Map<String, double> serviziNotturnoExtra;
  final Map<String, bool> serviziNotturnoAttivi;
  final Map<String, bool> serviziAsciugaturaAttivi;
  final Map<String, double> serviziTaxiPet;
  final Map<String, String> serviziCheckIn;
  final Map<String, String> serviziCheckOut;
  final Map<String, List<String>> serviziTaglie;

  // Boarding & Taxi
  final int boardingDailyWalks;
  final List<String> boardingToiletOptions;
  final String boardingToiletFrequency;
  final String boardingHygieneDescription;
  final List<String> boardingSpecialNeeds;
  final double taxiBaseFare;
  final double taxiPricePerKm;
  final double taxiPricePerMin;
  final double taxiNightSurcharge;
  final List<String> taxiSpecieAccettate;
  final Function(double) onTaxiBaseFareChanged;
  final Function(double) onTaxiPricePerKmChanged;
  final Function(double) onTaxiPricePerMinChanged;
  final Function(double) onTaxiNightSurchargeChanged;
  final Function(String, bool) onTaxiSpecieChanged;

  // Casa
  final String tipoCasa;
  final bool giardino;
  final bool altriAnimaliInCasa;
  final bool bambiniInCasa;
  final bool ambienteSicuro;
  final Function(String) onTipoCasaChanged;
  final Function(bool) onGiardinoChanged;
  final Function(bool) onAltriAnimaliChanged;
  final Function(bool) onBambiniChanged;
  final Function(bool) onSicuroChanged;
  final List<File?> fotoCasaFiles;
  final List<String> existingFotoCasaUrls;
  final Function(int, File) onFotoCasaPicked;
  final Function(int) onFotoCasaRemoved;
  final Function(int) onExistingFotoCasaRemoved;
  final Function(List<File>) onMultiFotoCasaPicked;

  final Function(String, bool) onAttrezzaturaChanged;
  final VoidCallback onConfirmRevision;

  final List<String> razzeEscluse;
  final List<String> comportamentiEsclusi;
  final Map<String, bool> attrezzatura;

  final String? stripeAccountId;
  final bool stripeOnboardingComplete;
  final Function(String) onStripeAccountCreated;
  final VoidCallback onStripeOnboardingComplete;
  final VoidCallback onStripeVerified;

  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onResetScanner;
  final VoidCallback onFinish;

  final Function(String, bool) onServizioToggled;
  final Function(String, double) onPrezzoChanged;
  final Function(String, int) onMaxAnimaliChanged;
  final Function(String, String) onOrariChanged;
  final Function(String, String) onNoteChanged;
  final Function(String, String) onDurataChanged;
  final Function(String, bool) onWeekendToggled;
  final Function(String, double) onWeekendExtraChanged;
  final Function(String, bool) onNotturnoToggled;
  final Function(String, double) onNotturnoExtraChanged;
  final Function(String, bool) onAsciugaturaToggled;
  final Function(String, double) onTaxiPetChanged;
  final Function(String, String) onCheckInChanged;
  final Function(String, String) onCheckOutChanged;
  final Function(String, String, bool) onTagliaChanged;
  final Function(String) onRazzaAggiunta;
  final Function(String) onRazzaRimossa;
  final Function(String) onComportamentoAggiunto;
  final Function(String) onComportamentoRimossa;
  final Function(int) onBoardingDailyWalksChanged;
  final Function(String, bool) onBoardingToiletOptionChanged;
  final Function(String) onBoardingToiletFrequencyChanged;
  final Function(String) onBoardingHygieneDescriptionChanged;
  final Function(String, bool) onBoardingSpecialNeedChanged;

  const SitterRegistrationView({
    super.key,
    required this.currentStep,
    required this.pageController,
    required this.isEditing,
    required this.isLoading,
    required this.primaryIndigo,
    required this.bgLight,
    required this.textColor,
    required this.nicknameController,
    required this.nomeController,
    required this.cognomeController,
    required this.dataNascitaController,
    required this.bioBreveController,
    required this.nazioneController,
    required this.regioneController,
    required this.cittaController,
    required this.indirizzoController,
    required this.quartiereController,
    required this.telefonoController,
    required this.emailController,
    required this.anniEsperienzaController,
    required this.descrizioneAltroController,
    required this.attrezzaturaAltroController,
    required this.telefonoPrefix,
    required this.onPrefixChanged,
    required this.lat,
    required this.lng,
    required this.onLocationFound,
    required this.fotoProfiloPro,
    required this.existingFotoUrl,
    required this.onFotoProPicked,
    required this.docFronte,
    required this.onDocFrontePicked,
    required this.emailVerified,
    required this.phoneVerified,
    required this.identityVerified,
    required this.onEmailVerifiedChanged,
    required this.onPhoneVerifiedChanged,
    required this.onIdentityVerified,
    required this.specieEsperienza,
    required this.prenotazioneLastMinute,
    required this.onSpecieChanged,
    required this.onLastMinuteChanged,
    required this.raggioKm,
    required this.onRaggioKmChanged,
    required this.fotoInserzioneFiles,
    required this.existingFotoInserzioneUrls,
    required this.onMultiFotoInserzionePicked,
    required this.onFotoInserzioneRemoved,
    required this.onExistingFotoInserzioneRemoved,
    required this.certifications,
    required this.onCertificationAdded,
    required this.onCertificationRemoved,
    required this.competenze,
    required this.onSkillToggled,
    required this.bisogniSpeciali,
    required this.somministrazioneFarmaci,
    required this.gestioneAnimaliDifficili,
    required this.onBisogniSpecialiChanged,
    required this.onFarmaciChanged,
    required this.onDifficiliChanged,
    required this.serviziAttivi,
    required this.serviziPrezzi,
    required this.serviziMaxAnimali,
    required this.serviziOrari,
    required this.serviziNote,
    required this.serviziDurata,
    required this.serviziWeekendExtra,
    required this.serviziWeekendAttivi,
    required this.serviziNotturnoExtra,
    required this.serviziNotturnoAttivi,
    required this.serviziAsciugaturaAttivi,
    required this.serviziTaxiPet,
    required this.serviziCheckIn,
    required this.serviziCheckOut,
    required this.serviziTaglie,
    required this.boardingDailyWalks,
    required this.boardingToiletOptions,
    required this.boardingToiletFrequency,
    required this.boardingHygieneDescription,
    required this.boardingSpecialNeeds,
    required this.taxiBaseFare,
    required this.taxiPricePerKm,
    required this.taxiPricePerMin,
    required this.taxiNightSurcharge,
    required this.taxiSpecieAccettate,
    required this.onTaxiBaseFareChanged,
    required this.onTaxiPricePerKmChanged,
    required this.onTaxiPricePerMinChanged,
    required this.onTaxiNightSurchargeChanged,
    required this.onTaxiSpecieChanged,
    required this.tipoCasa,
    required this.giardino,
    required this.altriAnimaliInCasa,
    required this.bambiniInCasa,
    required this.ambienteSicuro,
    required this.onTipoCasaChanged,
    required this.onGiardinoChanged,
    required this.onAltriAnimaliChanged,
    required this.onBambiniChanged,
    required this.onSicuroChanged,
    required this.fotoCasaFiles,
    required this.existingFotoCasaUrls,
    required this.onFotoCasaPicked,
    required this.onFotoCasaRemoved,
    required this.onExistingFotoCasaRemoved,
    required this.onMultiFotoCasaPicked,
    required this.onAttrezzaturaChanged,
    required this.onConfirmRevision,
    required this.razzeEscluse,
    required this.comportamentiEsclusi,
    required this.attrezzatura,
    required this.stripeAccountId,
    required this.stripeOnboardingComplete,
    required this.onStripeAccountCreated,
    required this.onStripeOnboardingComplete,
    required this.onStripeVerified,
    required this.onBack,
    required this.onNext,
    required this.onResetScanner,
    required this.onFinish,
    required this.onServizioToggled,
    required this.onPrezzoChanged,
    required this.onMaxAnimaliChanged,
    required this.onOrariChanged,
    required this.onNoteChanged,
    required this.onDurataChanged,
    required this.onWeekendToggled,
    required this.onWeekendExtraChanged,
    required this.onNotturnoToggled,
    required this.onNotturnoExtraChanged,
    required this.onAsciugaturaToggled,
    required this.onTaxiPetChanged,
    required this.onCheckInChanged,
    required this.onCheckOutChanged,
    required this.onTagliaChanged,
    required this.onRazzaAggiunta,
    required this.onRazzaRimossa,
    required this.onComportamentoAggiunto,
    required this.onComportamentoRimossa,
    required this.onBoardingDailyWalksChanged,
    required this.onBoardingToiletOptionChanged,
    required this.onBoardingToiletFrequencyChanged,
    required this.onBoardingHygieneDescriptionChanged,
    required this.onBoardingSpecialNeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 0: Identità (Scanner)
              SectionA1Scanner(
                docFronte: docFronte,
                onDocFrontePicked: (f) => onDocFrontePicked(f),
                onVerificationSuccess: (v) => onIdentityVerified(v),
                dataNascitaController: dataNascitaController,
                nomeController: nomeController,
                cognomeController: cognomeController,
              ),

              // Step 1: Dati Personali e Contatti
              SectionA2Dati(
                nicknameController: nicknameController,
                nomeController: nomeController,
                cognomeController: cognomeController,
                dataNascitaController: dataNascitaController,
                nazioneController: nazioneController,
                regioneController: regioneController,
                cittaController: cittaController,
                indirizzoController: indirizzoController,
                quartiereController: quartiereController,
                telefonoController: telefonoController,
                emailController: emailController,
                telefonoPrefix: telefonoPrefix,
                onPrefixChanged: onPrefixChanged,
                onLocationFound: onLocationFound,
                fotoChiSeiPro: fotoProfiloPro,
                existingFotoUrl: existingFotoUrl,
                onFotoProPicked: (f) => onFotoProPicked(f),
                onResetScanner: onResetScanner,
                emailVerified: emailVerified,
                phoneVerified: phoneVerified,
                identityVerified: identityVerified,
                onEmailVerifiedChanged: onEmailVerifiedChanged,
                onPhoneVerifiedChanged: onPhoneVerifiedChanged,
              ),

              // Step 2: Esperienza e Bio
              SectionBEsperienza(
                anniEsperienzaController: anniEsperienzaController,
                descrizioneAltroController: descrizioneAltroController,
                bioController: bioBreveController,
                specieEsperienza: specieEsperienza,
                onSpecieChanged: onSpecieChanged,
                raggioKm: raggioKm,
                onRaggioKmChanged: onRaggioKmChanged,
                fotoInserzione: fotoInserzioneFiles,
                existingFotoUrls: existingFotoInserzioneUrls,
                onMultiFotoPicked: onMultiFotoInserzionePicked,
                onFotoRemoved: onFotoInserzioneRemoved,
                onExistingFotoRemoved: onExistingFotoInserzioneRemoved,
              ),

              // Step 3: Competenze e Preferenze
              SectionEPreferenze(
                certifications: certifications,
                onCertificationAdded: onCertificationAdded,
                onCertificationRemoved: onCertificationRemoved,
                selectedSkills: competenze,
                onSkillToggled: onSkillToggled,
                bisogniSpeciali: bisogniSpeciali,
                somministrazioneFarmaci: somministrazioneFarmaci,
                gestioneAnimaliDifficili: gestioneAnimaliDifficili,
                onBisogniSpecialiChanged: onBisogniSpecialiChanged,
                onFarmaciChanged: onFarmaciChanged,
                onDifficiliChanged: onDifficiliChanged,
              ),

              // Step 4: Servizi
              SectionCServizi(
                serviziAttivi: serviziAttivi,
                serviziPrezzi: serviziPrezzi,
                serviziMaxAnimali: serviziMaxAnimali,
                serviziOrari: serviziOrari,
                serviziNote: serviziNote,
                serviziDurata: serviziDurata,
                serviziWeekendExtra: serviziWeekendExtra,
                serviziWeekendAttivi: serviziWeekendAttivi,
                serviziNotturnoExtra: serviziNotturnoExtra,
                serviziNotturnoAttivi: serviziNotturnoAttivi,
                serviziAsciugaturaAttivi: serviziAsciugaturaAttivi,
                serviziTaxiPet: serviziTaxiPet,
                serviziCheckIn: serviziCheckIn,
                serviziCheckOut: serviziCheckOut,
                serviziTaglie: serviziTaglie,
                razzeEscluse: razzeEscluse,
                comportamentiEsclusi: comportamentiEsclusi,
                boardingDailyWalks: boardingDailyWalks,
                boardingToiletOptions: boardingToiletOptions,
                boardingToiletFrequency: boardingToiletFrequency,
                boardingHygieneDescription: boardingHygieneDescription,
                boardingSpecialNeeds: boardingSpecialNeeds,
                tipoCasa: tipoCasa,
                giardino: giardino,
                altriAnimali: altriAnimaliInCasa,
                bambini: bambiniInCasa,
                ambienteSicuro: ambienteSicuro,
                fotoCasa: fotoCasaFiles,
                existingFotoCasaUrls: existingFotoCasaUrls,
                onServizioToggled: onServizioToggled,
                onPrezzoChanged: onPrezzoChanged,
                onMaxAnimaliChanged: onMaxAnimaliChanged,
                onOrariChanged: onOrariChanged,
                onNoteChanged: onNoteChanged,
                onDurataChanged: onDurataChanged,
                onWeekendToggled: onWeekendToggled,
                onWeekendExtraChanged: onWeekendExtraChanged,
                onNotturnoToggled: onNotturnoToggled,
                onNotturnoExtraChanged: onNotturnoExtraChanged,
                onAsciugaturaToggled: onAsciugaturaToggled,
                onTaxiPetChanged: onTaxiPetChanged,
                onCheckInChanged: onCheckInChanged,
                onCheckOutChanged: onCheckOutChanged,
                onTagliaChanged: onTagliaChanged,
                onRazzaAggiunta: onRazzaAggiunta,
                onRazzaRimossa: onRazzaRimossa,
                onComportamentoAggiunto: onComportamentoAggiunto,
                onComportamentoRimosso: (c) => onComportamentoRimossa(c),
                onBoardingDailyWalksChanged: onBoardingDailyWalksChanged,
                onBoardingToiletOptionChanged: onBoardingToiletOptionChanged,
                onBoardingToiletFrequencyChanged: onBoardingToiletFrequencyChanged,
                onBoardingHygieneDescriptionChanged: onBoardingHygieneDescriptionChanged,
                onBoardingSpecialNeedChanged: onBoardingSpecialNeedChanged,
                onTaxiBaseFareChanged: onTaxiBaseFareChanged,
                onTaxiPricePerKmChanged: onTaxiPricePerKmChanged,
                onTaxiPricePerMinChanged: onTaxiPricePerMinChanged,
                onTaxiNightSurchargeChanged: onTaxiNightSurchargeChanged,
                onTaxiSpecieChanged: onTaxiSpecieChanged,
                onTipoCasaChanged: onTipoCasaChanged,
                onGiardinoChanged: onGiardinoChanged,
                onAltriAnimaliChanged: onAltriAnimaliChanged,
                onBambiniChanged: onBambiniChanged,
                onSicuroChanged: onSicuroChanged,
                onFotoCasaPicked: onFotoCasaPicked,
                onFotoCasaRemoved: onFotoCasaRemoved,
                onExistingFotoCasaRemoved: onExistingFotoCasaRemoved,
                onMultiFotoPicked: onMultiFotoCasaPicked,
                taxiBaseFare: taxiBaseFare,
                taxiPricePerKm: taxiPricePerKm,
                taxiPricePerMin: taxiPricePerMin,
                taxiNightSurcharge: taxiNightSurcharge,
                taxiSpecieAccettate: taxiSpecieAccettate,
              ),

              // Step 5: Attrezzatura
              SectionDAttrezzatura(
                attrezzatura: attrezzatura,
                altroController: attrezzaturaAltroController,
                onAttrezzaturaChanged: onAttrezzaturaChanged,
              ),

              // Step 6: Revisione
              Step9Revisione(
                summaryData: {
                  'nome': nomeController.text,
                  'cognome': cognomeController.text,
                  'dataNascita': dataNascitaController.text,
                  'email': emailController.text,
                  'telefono': telefonoPrefix + telefonoController.text,
                  'indirizzo': indirizzoController.text,
                  'citta': cittaController.text,
                  'nazione': nazioneController.text,
                  'quartiere': quartiereController.text,
                  'anniEsperienza': anniEsperienzaController.text,
                  'raggioKm': raggioKm,
                  'specie': specieEsperienza,
                  'competenze': competenze,
                  'certificazioni': certifications,
                  'bisogniSpeciali': bisogniSpeciali,
                  'somministrazioneFarmaci': somministrazioneFarmaci,
                  'gestioneAnimaliDifficili': gestioneAnimaliDifficili,
                  'prenotazioneLastMinute': prenotazioneLastMinute,
                  'servizi': serviziAttivi,
                  'serviziPrezzi': serviziPrezzi,
                  'serviziTaglie': serviziTaglie,
                  'attrezzatura': attrezzatura,
                  'attrezzaturaAltro': attrezzaturaAltroController.text,
                  'razzeEscluse': razzeEscluse,
                  'comportamentiEsclusi': comportamentiEsclusi,
                  'tipoCasa': tipoCasa,
                  'giardino': giardino,
                  'altriAnimali': altriAnimaliInCasa,
                  'bambini': bambiniInCasa,
                  'ambienteSicuro': ambienteSicuro,
                  'fotoCasa': fotoCasaFiles,
                },
                onConfirm: onConfirmRevision,
              ),

              // Step 7: Fine / Inviato
              Step10Inviato(
                onFinish: onFinish,
              ),

              // Step 8: Pagamenti (Stripe) - ULTIMO DOPO LA CONFERMA
              SectionFPagamenti(
                stripeAccountId: stripeAccountId,
                onboardingComplete: stripeOnboardingComplete,
                onAccountCreated: onStripeAccountCreated,
                onOnboardingComplete: (v) => onStripeOnboardingComplete(),
                onVerified: onStripeVerified,
              ),
            ],
          ),

          // Pulsanti di navigazione
          if (currentStep < 7)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    FloatingActionButton(
                      heroTag: "btn_back",
                      onPressed: onBack,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  const Spacer(),
                  if (currentStep < 6)
                    ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Text("btn_next".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
