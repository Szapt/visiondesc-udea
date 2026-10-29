import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la app
  ///
  /// In es, this message translates to:
  /// **'VisionDesc'**
  String get appTitle;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonInfoPrefix.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get commonInfoPrefix;

  /// No description provided for @commonWarningPrefix.
  ///
  /// In es, this message translates to:
  /// **'Advertencia'**
  String get commonWarningPrefix;

  /// No description provided for @commonErrorPrefix.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonErrorPrefix;

  /// No description provided for @adjustDecrease.
  ///
  /// In es, this message translates to:
  /// **'Disminuir {label}'**
  String adjustDecrease(String label);

  /// No description provided for @adjustIncrease.
  ///
  /// In es, this message translates to:
  /// **'Aumentar {label}'**
  String adjustIncrease(String label);

  /// No description provided for @optionPosition.
  ///
  /// In es, this message translates to:
  /// **'{option}, {index} de {total}'**
  String optionPosition(String option, int index, int total);

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'VisionDesc'**
  String get homeTitle;

  /// No description provided for @homeTitleSemantics.
  ///
  /// In es, this message translates to:
  /// **'VisionDesc, inicio'**
  String get homeTitleSemantics;

  /// No description provided for @homeCaptureLabel.
  ///
  /// In es, this message translates to:
  /// **'Capturar'**
  String get homeCaptureLabel;

  /// No description provided for @homeCaptureHint.
  ///
  /// In es, this message translates to:
  /// **'Fotografía la pizarra o una diapositiva'**
  String get homeCaptureHint;

  /// No description provided for @homeImportLabel.
  ///
  /// In es, this message translates to:
  /// **'Importar archivo'**
  String get homeImportLabel;

  /// No description provided for @homeImportHint.
  ///
  /// In es, this message translates to:
  /// **'Imagen, PDF o PowerPoint'**
  String get homeImportHint;

  /// No description provided for @homeHistoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get homeHistoryLabel;

  /// No description provided for @homeSettingsLabel.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get homeSettingsLabel;

  /// No description provided for @captureTitle.
  ///
  /// In es, this message translates to:
  /// **'Capturar'**
  String get captureTitle;

  /// No description provided for @captureGuidance.
  ///
  /// In es, this message translates to:
  /// **'Lista para capturar'**
  String get captureGuidance;

  /// No description provided for @captureVoiceGuidance.
  ///
  /// In es, this message translates to:
  /// **'Guía por voz'**
  String get captureVoiceGuidance;

  /// No description provided for @captureFlashlight.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get captureFlashlight;

  /// No description provided for @captureAutoCapture.
  ///
  /// In es, this message translates to:
  /// **'Captura automática'**
  String get captureAutoCapture;

  /// No description provided for @captureTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get captureTakePhoto;

  /// No description provided for @captureTakePhotoHint.
  ///
  /// In es, this message translates to:
  /// **'Analiza la foto y abre el resultado'**
  String get captureTakePhotoHint;

  /// No description provided for @capturePhotoTaken.
  ///
  /// In es, this message translates to:
  /// **'Foto tomada. Abriendo el resultado.'**
  String get capturePhotoTaken;

  /// No description provided for @importTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar archivo'**
  String get importTitle;

  /// No description provided for @importImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen de la galería'**
  String get importImage;

  /// No description provided for @importPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get importPdf;

  /// No description provided for @importPowerPoint.
  ///
  /// In es, this message translates to:
  /// **'Presentación PowerPoint'**
  String get importPowerPoint;

  /// No description provided for @importMaxSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño máximo: 20 megabytes.'**
  String get importMaxSize;

  /// No description provided for @resultTitle.
  ///
  /// In es, this message translates to:
  /// **'Diagrama de clases: Sistema de pedidos'**
  String get resultTitle;

  /// No description provided for @resultReadingHeader.
  ///
  /// In es, this message translates to:
  /// **'Lectura'**
  String get resultReadingHeader;

  /// No description provided for @resultPreviousSection.
  ///
  /// In es, this message translates to:
  /// **'Sección anterior'**
  String get resultPreviousSection;

  /// No description provided for @resultNextSection.
  ///
  /// In es, this message translates to:
  /// **'Sección siguiente'**
  String get resultNextSection;

  /// No description provided for @resultReadSection.
  ///
  /// In es, this message translates to:
  /// **'Leer sección'**
  String get resultReadSection;

  /// No description provided for @resultReadSectionHint.
  ///
  /// In es, this message translates to:
  /// **'El lector de pantalla lee la sección actual'**
  String get resultReadSectionHint;

  /// No description provided for @resultCurrentSection.
  ///
  /// In es, this message translates to:
  /// **'Sección actual: {section}'**
  String resultCurrentSection(String section);

  /// No description provided for @resultSpeed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get resultSpeed;

  /// No description provided for @resultSpeedValue.
  ///
  /// In es, this message translates to:
  /// **'{rate} por'**
  String resultSpeedValue(String rate);

  /// No description provided for @resultFirstSection.
  ///
  /// In es, this message translates to:
  /// **'Ya estás en la primera sección.'**
  String get resultFirstSection;

  /// No description provided for @resultLastSection.
  ///
  /// In es, this message translates to:
  /// **'Ya estás en la última sección.'**
  String get resultLastSection;

  /// No description provided for @resultSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get resultSummary;

  /// No description provided for @resultDetailed.
  ///
  /// In es, this message translates to:
  /// **'Descripción detallada'**
  String get resultDetailed;

  /// No description provided for @resultStructure.
  ///
  /// In es, this message translates to:
  /// **'Estructura'**
  String get resultStructure;

  /// No description provided for @resultStructureCount.
  ///
  /// In es, this message translates to:
  /// **'{nodes} nodos y {relations} relaciones.'**
  String resultStructureCount(int nodes, int relations);

  /// No description provided for @resultExploreStructure.
  ///
  /// In es, this message translates to:
  /// **'Explorar estructura'**
  String get resultExploreStructure;

  /// No description provided for @resultDetectedText.
  ///
  /// In es, this message translates to:
  /// **'Texto detectado'**
  String get resultDetectedText;

  /// No description provided for @resultCode.
  ///
  /// In es, this message translates to:
  /// **'Código ({language})'**
  String resultCode(String language);

  /// No description provided for @resultCodeLine.
  ///
  /// In es, this message translates to:
  /// **'Línea {number}: {code}'**
  String resultCodeLine(int number, String code);

  /// No description provided for @resultKeyConcepts.
  ///
  /// In es, this message translates to:
  /// **'Conceptos clave'**
  String get resultKeyConcepts;

  /// No description provided for @resultAiNotice.
  ///
  /// In es, this message translates to:
  /// **'Descripción generada por inteligencia artificial; puede contener errores.'**
  String get resultAiNotice;

  /// No description provided for @resultAsk.
  ///
  /// In es, this message translates to:
  /// **'Hacer una pregunta'**
  String get resultAsk;

  /// No description provided for @resultAskSemantics.
  ///
  /// In es, this message translates to:
  /// **'Hacer una pregunta sobre este material'**
  String get resultAskSemantics;

  /// No description provided for @resultSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar en historial'**
  String get resultSave;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTitle;

  /// No description provided for @historySearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar en el historial'**
  String get historySearch;

  /// No description provided for @historyResultsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin resultados} =1{1 resultado} other{{count} resultados}}'**
  String historyResultsCount(int count);

  /// No description provided for @historyItemSemantics.
  ///
  /// In es, this message translates to:
  /// **'{title}. {subject}, {date}.'**
  String historyItemSemantics(String title, String subject, String date);

  /// No description provided for @historyGroupSemantics.
  ///
  /// In es, this message translates to:
  /// **'{subject}, {count, plural, =1{1 elemento} other{{count} elementos}}'**
  String historyGroupSemantics(String subject, int count);

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsVoiceHeader.
  ///
  /// In es, this message translates to:
  /// **'Voz'**
  String get settingsVoiceHeader;

  /// No description provided for @settingsSpeechRate.
  ///
  /// In es, this message translates to:
  /// **'Velocidad de lectura'**
  String get settingsSpeechRate;

  /// No description provided for @settingsDescriptionHeader.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get settingsDescriptionHeader;

  /// No description provided for @settingsDetailLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de detalle'**
  String get settingsDetailLevel;

  /// No description provided for @detailBrief.
  ///
  /// In es, this message translates to:
  /// **'Breve'**
  String get detailBrief;

  /// No description provided for @detailBriefDescription.
  ///
  /// In es, this message translates to:
  /// **'Resumen y lo principal'**
  String get detailBriefDescription;

  /// No description provided for @detailStandard.
  ///
  /// In es, this message translates to:
  /// **'Estándar'**
  String get detailStandard;

  /// No description provided for @detailStandardDescription.
  ///
  /// In es, this message translates to:
  /// **'Recomendado'**
  String get detailStandardDescription;

  /// No description provided for @detailExhaustive.
  ///
  /// In es, this message translates to:
  /// **'Exhaustivo'**
  String get detailExhaustive;

  /// No description provided for @detailExhaustiveDescription.
  ///
  /// In es, this message translates to:
  /// **'Todo lo visible'**
  String get detailExhaustiveDescription;

  /// No description provided for @settingsAppearanceHeader.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearanceHeader;

  /// No description provided for @settingsTextSizeNote.
  ///
  /// In es, this message translates to:
  /// **'El tamaño del texto se ajusta en la configuración de accesibilidad del teléfono.'**
  String get settingsTextSizeNote;

  /// No description provided for @settingsFeedbackHeader.
  ///
  /// In es, this message translates to:
  /// **'Retroalimentación'**
  String get settingsFeedbackHeader;

  /// No description provided for @settingsVibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get settingsVibration;

  /// No description provided for @settingsAboutHeader.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAboutHeader;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsChanged.
  ///
  /// In es, this message translates to:
  /// **'{setting}: {value}'**
  String settingsChanged(String setting, String value);

  /// No description provided for @settingsOn.
  ///
  /// In es, this message translates to:
  /// **'activada'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In es, this message translates to:
  /// **'desactivada'**
  String get settingsOff;

  /// No description provided for @themeHeader.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeHeader;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Igual que el sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @themeHighContrast.
  ///
  /// In es, this message translates to:
  /// **'Alto contraste'**
  String get themeHighContrast;

  /// No description provided for @pendingStructureTitle.
  ///
  /// In es, this message translates to:
  /// **'Explorar estructura'**
  String get pendingStructureTitle;

  /// No description provided for @pendingChatTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas'**
  String get pendingChatTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
