// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'VisionDesc';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonVoiceCommand => 'Comando de voz';

  @override
  String get commonVoiceCommandHint => 'Di, por ejemplo, capturar o historial';

  @override
  String get commonInfoPrefix => 'Información';

  @override
  String get commonWarningPrefix => 'Advertencia';

  @override
  String get commonErrorPrefix => 'Error';

  @override
  String adjustDecrease(String label) {
    return 'Disminuir $label';
  }

  @override
  String adjustIncrease(String label) {
    return 'Aumentar $label';
  }

  @override
  String optionPosition(String option, int index, int total) {
    return '$option, $index de $total';
  }

  @override
  String get homeTitle => 'VisionDesc';

  @override
  String get homeTitleSemantics => 'VisionDesc, inicio';

  @override
  String get homeCaptureLabel => 'Capturar';

  @override
  String get homeCaptureHint => 'Fotografía la pizarra o una diapositiva';

  @override
  String get homeImportLabel => 'Importar archivo';

  @override
  String get homeImportHint => 'Imagen, PDF o PowerPoint';

  @override
  String get homeHistoryLabel => 'Historial';

  @override
  String get homeSettingsLabel => 'Ajustes';

  @override
  String get captureTitle => 'Capturar';

  @override
  String get captureGuidance => 'Lista para capturar';

  @override
  String get captureVoiceGuidance => 'Guía por voz';

  @override
  String get captureFlashlight => 'Linterna';

  @override
  String get captureAutoCapture => 'Captura automática';

  @override
  String get captureTakePhoto => 'Tomar foto';

  @override
  String get captureTakePhotoHint => 'Analiza la foto y abre el resultado';

  @override
  String get capturePhotoTaken => 'Foto tomada. Abriendo el resultado.';

  @override
  String get importTitle => 'Importar archivo';

  @override
  String get importImage => 'Imagen de la galería';

  @override
  String get importPdf => 'PDF';

  @override
  String get importPowerPoint => 'Presentación PowerPoint';

  @override
  String get importMaxSize => 'Tamaño máximo: 20 megabytes.';

  @override
  String get resultTitle => 'Diagrama de clases: Sistema de pedidos';

  @override
  String get resultReadingHeader => 'Lectura';

  @override
  String get resultPreviousSection => 'Sección anterior';

  @override
  String get resultNextSection => 'Sección siguiente';

  @override
  String get resultReadSection => 'Leer sección';

  @override
  String get resultReadSectionHint =>
      'El lector de pantalla lee la sección actual';

  @override
  String resultCurrentSection(String section) {
    return 'Sección actual: $section';
  }

  @override
  String get resultSpeed => 'Velocidad';

  @override
  String resultSpeedValue(String rate) {
    return '$rate por';
  }

  @override
  String get resultFirstSection => 'Ya estás en la primera sección.';

  @override
  String get resultLastSection => 'Ya estás en la última sección.';

  @override
  String get resultSummary => 'Resumen';

  @override
  String get resultDetailed => 'Descripción detallada';

  @override
  String get resultStructure => 'Estructura';

  @override
  String resultStructureCount(int nodes, int relations) {
    return '$nodes nodos y $relations relaciones.';
  }

  @override
  String get resultExploreStructure => 'Explorar estructura';

  @override
  String get resultDetectedText => 'Texto detectado';

  @override
  String resultCode(String language) {
    return 'Código ($language)';
  }

  @override
  String resultCodeLine(int number, String code) {
    return 'Línea $number: $code';
  }

  @override
  String get resultKeyConcepts => 'Conceptos clave';

  @override
  String get resultAiNotice =>
      'Descripción generada por inteligencia artificial; puede contener errores.';

  @override
  String get resultAsk => 'Hacer una pregunta';

  @override
  String get resultAskSemantics => 'Hacer una pregunta sobre este material';

  @override
  String get resultSave => 'Guardar en historial';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historySearch => 'Buscar en el historial';

  @override
  String historyResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String historyItemSemantics(String title, String subject, String date) {
    return '$title. $subject, $date.';
  }

  @override
  String historyGroupSemantics(String subject, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$subject, $_temp0';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsVoiceHeader => 'Voz';

  @override
  String get settingsSpeechRate => 'Velocidad de lectura';

  @override
  String get settingsDescriptionHeader => 'Descripción';

  @override
  String get settingsDetailLevel => 'Nivel de detalle';

  @override
  String get detailBrief => 'Breve';

  @override
  String get detailBriefDescription => 'Resumen y lo principal';

  @override
  String get detailStandard => 'Estándar';

  @override
  String get detailStandardDescription => 'Recomendado';

  @override
  String get detailExhaustive => 'Exhaustivo';

  @override
  String get detailExhaustiveDescription => 'Todo lo visible';

  @override
  String get settingsAppearanceHeader => 'Apariencia';

  @override
  String get settingsTextSizeNote =>
      'El tamaño del texto se ajusta en la configuración de accesibilidad del teléfono.';

  @override
  String get settingsFeedbackHeader => 'Retroalimentación';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsAboutHeader => 'Acerca de';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String settingsChanged(String setting, String value) {
    return '$setting: $value';
  }

  @override
  String get settingsOn => 'activada';

  @override
  String get settingsOff => 'desactivada';

  @override
  String get themeHeader => 'Tema';

  @override
  String get themeSystem => 'Igual que el sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeHighContrast => 'Alto contraste';

  @override
  String get pendingStructureTitle => 'Explorar estructura';

  @override
  String get pendingChatTitle => 'Preguntas';
}
