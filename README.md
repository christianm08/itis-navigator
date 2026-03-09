# ITIS Navigator

🏫 App di navigazione per l'ITIS E. Majorana - Cassino

## ✨ Caratteristiche

- 🗺️ **Navigazione GPS in tempo reale** dalla tua posizione all'ITIS
- 🌦️ **Meteo in tempo reale** dalla stazione meteorologica ufficiale della scuola (LAZ543)
- 📍 **Indicazioni passo-passo** con aggiornamento automatico della posizione
- 📅 **Orologio dinamico** con data e ora sempre aggiornati
- 🏫 **Informazioni sulla scuola** con link diretto al sito ufficiale

## 🚀 Setup Progetto

### Prerequisiti

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode per sviluppo mobile

### Installazione

1. Clona il repository:
```bash
git clone https://github.com/christianm08/itis-navigator.git
cd itis-navigator
```

2. Installa le dipendenze:
```bash
flutter pub get
```

3. Configura le API keys (vedi sezione sotto)

4. Avvia l'app:
```bash
flutter run
```

## 🔑 Configurazione API Keys

### 1. Google Maps API Key (Navigazione)

L'app usa Google Maps per la visualizzazione della mappa e la navigazione.

**Android:**
1. Vai su [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuovo progetto o seleziona uno esistente
3. Abilita **Maps SDK for Android** e **Directions API**
4. Crea una API key in "Credentials"
5. Modifica `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TUA_GOOGLE_MAPS_API_KEY"/>
```

**iOS:**
1. Abilita **Maps SDK for iOS** nella Google Cloud Console
2. Modifica `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("TUA_GOOGLE_MAPS_API_KEY")
```

### 2. MeteoNetwork API Token (Meteo ITIS)

L'app mostra i dati meteo in tempo reale dalla **stazione meteorologica ufficiale dell'ITIS** (codice stazione: **LAZ543**).

**Come ottenere il token:**

1. **Registrati gratuitamente** su MeteoNetwork:
   - Vai su [https://www.meteonetwork.it](https://www.meteonetwork.it)
   - Clicca su "Registrati" e completa la registrazione

2. **Ottieni il token API:**
   - Leggi la documentazione: [MeteoNetwork API](https://www.meteonetwork.it/supporto/meteonetwork-api/)
   - Usa il metodo `/login` per ottenere il token Bearer:
   
   ```bash
   curl --request POST \
     --url https://api.meteonetwork.it/v3/login \
     --header 'Content-Type: multipart/form-data' \
     --form email=tua-email@example.com \
     --form password=tua-password
   ```
   
   Risposta:
   ```json
   {
     "token": "99|eyhi35h2ui5hi3u45ughwiuhi4h5i23h5i2h35uoi23",
     "type": "bearer"
   }
   ```

3. **Configura il token nell'app:**
   - Apri `lib/config/local_api_keys.dart`
   - Sostituisci `YOUR_METEONETWORK_TOKEN` con il tuo token:
   
   ```dart
   static const String meteoNetworkToken = '99|eyhi35h2ui5hi3u45ughwiuhi4h5i23h5i2h35uoi23';
   ```

**Nota:** Se non configuri il token, l'app userà automaticamente dati meteo simulati realistici.

### 3. OpenRouteService API Key (Routing)

Già configurato nel progetto, ma puoi sostituirlo con il tuo:

1. Registrati su [OpenRouteService](https://openrouteservice.org/dev/#/signup)
2. Crea una API key gratuita
3. Aggiorna `lib/config/local_api_keys.dart`:
```dart
static const String openRouteServiceApiKey = 'TUA_ORS_API_KEY';
```

## 🌦️ Stazione Meteorologica ITIS

L'app si collega alla stazione meteorologica ufficiale installata all'ITIS Majorana:

- **Codice stazione:** LAZ543
- **Nome:** Stazione meteorologica di ITIS Majorana - Cassino (FR)
- **Link pubblico:** [MeteoNetwork LAZ543](https://www.meteonetwork.eu/it/weather-station/laz543-stazione-meteorologica-di-itis-majorana-cassino)
- **Licenza dati:** CC-BY 4.0 (Open Data)

**Dati disponibili:**
- Temperatura (°C)
- Umidità relativa (%)
- Pressione atmosferica (hPa)
- Velocità e direzione del vento (km/h)
- Tasso di precipitazione (mm/h)
- Punto di rugiada (°C)

## 📦 Dipendenze Principali

- `google_maps_flutter` - Mappe e navigazione
- `geolocator` - Geolocalizzazione GPS
- `provider` - State management
- `http` - Chiamate API
- `intl` - Internazionalizzazione e formattazione date
- `url_launcher` - Apertura link esterni

## 📱 Piattaforme Supportate

- ✅ Android
- ✅ iOS

## 👥 Contribuire

Contribuzioni benvenute! Per favore:
1. Fai un fork del progetto
2. Crea un branch per la tua feature (`git checkout -b feature/AmazingFeature`)
3. Committa le modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Pusha il branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📝 Licenza

Questo progetto è distribuito sotto licenza MIT.

I dati meteorologici di MeteoNetwork sono distribuiti sotto licenza **CC-BY 4.0** (Open Data).

## 🏫 Contatti

**ITIS E. Majorana - Cassino**
- Sito web: [itiscassino.edu.it](https://itiscassino.edu.it/)
- Email: fris007004@istruzione.it
- Indirizzo: Via S. Pertini, Cassino (FR)

---

🚀 Sviluppato con ❤️ per l'ITIS Majorana di Cassino
