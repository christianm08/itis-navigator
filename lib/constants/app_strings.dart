/// Application string constants
class AppStrings {
  AppStrings._();

  // App info
  static const appTitle = 'ITIS Navigator';
  static const appVersion = '1.0.0';

  // School info
  static const schoolName = 'ITIS E. Majorana';
  static const schoolAddress = 'Via S. Angelo, 2 - 03043 Cassino';
  static const schoolEmail = 'frtf020002@istruzione.it';
  static const schoolWebsite = 'https://itiscassino.edu.it/';
  static const schoolWebsiteError = 'Impossibile aprire il sito della scuola';

  // Location
  static const cassinoLat = 41.4849;
  static const cassinoLon = 13.8296;
  static const locationName = 'Cassino';

  // Navigation
  static const navigationTitle = 'Navigazione';
  static const navigationSubtitle = 'Percorso a piedi dalla tua posizione';
  static const schoolNavLabel = 'Vai a Scuola';
  static const schoolNavAccessibility = 'Vai a Scuola — naviga verso ITIS Biennio';
  static const stationNavLabel = 'Vai alla\nStazione';
  static const stationNavAccessibility = 'Vai alla Stazione — naviga verso la Stazione Ferroviaria';
  static const destinationReached = 'Sei arrivato a';
  static const navigationStarted = 'Navigazione avviata verso';
  static const offRouteMessage = 'Sei fuori percorso. Ricalcolo in corso.';
  static const routeRecalculated = 'Percorso ricalcolato';
  static const continueOnRoute = 'Continua sul percorso';
  static const startRoute = 'Parti e segui il percorso';
  static const arriveDestination = 'Sei arrivato a destinazione';
  static const mainRouteContinue = 'Continua sul percorso principale';

  // QR Scanner
  static const qrTitle = 'Percorso QR';
  static const qrSubtitle = 'Scansiona i punti Stazione — ITIS';
  static const qrAccessibility = 'Percorso QR. Scansiona i punti lungo il percorso dalla Stazione all ITIS.';

  // Transport
  static const transportTitle = 'Trasporti';
  static const transportSubtitle = 'Trenitalia · COTRAL · Bus Magni';
  static const transportAccessibility = 'Trasporti. Orari Trenitalia, COTRAL e Bus Magni. Tocca per aprire.';

  // Weather
  static const weatherTitle = 'Meteo a Cassino';
  static const weatherLoading = 'Caricamento...';
  static const weatherWind = 'Vento';
  static const weatherHumidity = 'Umidità';
  static const weatherUnitCelsius = '°C';
  static const weatherUnitKmh = 'km/h';
  static const weatherUnitPercent = '%';

  // Settings
  static const settingsTitle = 'Impostazioni';
  static const settingsAccessibility = 'Apri impostazioni';
  static const themeToggle = 'Tema scuro';
  static const voiceToggle = 'Voce';
  static const speechRate = 'Velocità voce';
  static const resetOnboarding = 'Ricomincia tutorial';

  // Onboarding
  static const onboardingWelcome = 'Benvenuto';
  static const onboardingDone = 'onboarding_done';

  // Permissions
  static const permissionLocationDisabled = 'Attiva i servizi di localizzazione del dispositivo';
  static const permissionLocationDenied = 'Permesso posizione negato';
  static const permissionLocationDeniedForever = 'Permesso posizione negato definitivamente. Apri le impostazioni.';
  static const locationError = 'Errore nel tracciamento posizione';

  // Time
  static const greetingMorning = 'Buongiorno';
  static const greetingAfternoon = 'Buon pomeriggio';
  static const greetingEvening = 'Buonasera';
  static const hoursLabel = 'h';
  static const minutesLabel = 'min';
  static const secondsLabel = 'sec';
  static const metersLabel = 'm';
  static const kilometersLabel = 'km';

  // Distance/Speed thresholds
  static const proximityThreshold = 22.0;
  static const offRouteThreshold = 40.0;
  static const arrivalThreshold = 25.0;
  static const waypointProximity = 40.0;
  static const qrPointProximity = 200.0;
  static const minMovementDistance = 3.0;
  static const gpsDistanceFilter = 5;
  static const headingThreshold = 5.0;
  static const rerouteCooldown = 3;
  static const polylineWindow = 20;

  // Walking speed (meters per second)
  static const walkingSpeed = 1.4;

  // Route defaults
  static const routeTotalDistance = 2751.0;
  static const routeTotalDuration = 1965.0;

  // HTTP timeouts
  static const httpTimeoutSeconds = 10;
  static const osrmTimeoutSeconds = 8;

  // SharedPreferences keys
  static const prefsDarkMode = 'dark_mode';
  static const prefsOnboardingDone = 'onboarding_done';
  static const prefsTtsEnabled = 'tts_enabled';
  static const prefsTtsSpeechRate = 'tts_speech_rate';
  static const prefsQrProgress = 'qr_progress';
}
