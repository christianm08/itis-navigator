# 📱 ITIS Navigator — Complete User Documentation

**Official guide for students, families, and staff of ITIS E. Majorana, Cassino**

*Documentation version: 1.0 — Supported platform: Android (APK)*

---

![Icon](assets/icon/app_icon.png)


## Table of Contents

1. [What is ITIS Navigator](#1-what-is-itis-navigator)
2. [Installing the app on Android](#2-installing-the-app-on-android)
3. [First launch and initial setup](#3-first-launch-and-initial-setup)
4. [Interface overview](#4-interface-overview)
5. [Main screen (Home)](#5-main-screen-home)
6. [GPS navigation to ITIS](#6-gps-navigation-to-itis)
7. [Real-time weather — Station LAZ543](#7-real-time-weather--station-laz543)
8. [Cotral bus timetables](#8-cotral-bus-timetables)
9. [School information](#9-school-information)
10. [Offline use and connectivity](#10-offline-use-and-connectivity)
11. [Troubleshooting](#11-troubleshooting)
12. [Frequently Asked Questions (FAQ)](#12-frequently-asked-questions-faq)
13. [Credits, licenses, and technical information](#13-credits-licenses-and-technical-information)

---

## 1. What is ITIS Navigator

ITIS Navigator is a free mobile application developed specifically for the school community of **Istituto Tecnico Industriale E. Majorana in Cassino (FR)**. The project was initiated by two students of the institute — **Christian Mascio** and **Vincenzo Riccio** — with the goal of bringing together in a single tool all the practical information a student needs every day to get to school and organize their school day.

The core idea is simple: before leaving home, a student needs to know three fundamental things — what the weather is like at ITIS, when the next bus comes, and how to get to school if they don't know the route or find themselves in an unusual location. ITIS Navigator answers all three of these questions on a single screen, without needing to open multiple different applications.

### Who it's for

The app is designed primarily for **students** attending ITIS Majorana, but it is also useful for **parents** who need to accompany or keep track of their children, for **new enrollees** who don't yet know the routes to reach the school, and for anyone who needs to visit the institute for the first time.

### What ITIS Navigator can do

In summary, the app offers four main macro-functions. The first is **turn-by-turn GPS navigation**: starting from your current location, the app calculates the optimal route to ITIS and guides you step by step with real-time updated instructions, exactly like a traditional navigation device. The second is **hyperlocal weather**: the meteorological data does not come from a generic forecast for the city of Cassino, but from the physical weather station installed inside ITIS itself, which means you are looking at real conditions at the exact place you are headed. The third is **Cotral bus timetable lookup**: the app contains the official scheduled timetables for Cassino stops and shows a real-time countdown to the next bus. The fourth is quick access to the **institute's contact information**, with a direct link to the school's official website.

### Supported platform

ITIS Navigator is available **exclusively for Android** and is installed via APK file. It is not available on the Google Play Store or Apple's App Store.

---

## 2. Installing the app on Android

Since ITIS Navigator is not distributed through the Google Play Store, installation requires an extra step compared to traditional apps: enabling installation from external sources. This is a completely normal and safe procedure when the APK file comes from a trusted source such as the school or the developer's official repository.

### Step 1 — Get the APK file

The ITIS Navigator APK file is distributed directly by the school or can be downloaded from the project's official GitHub page at `github.com/christianm08/itis-navigator`. Always make sure to download the latest available version, which will be named with a version number (e.g. `itis-navigator-v1.0.apk`). Save the file to your Android device's storage, preferably in the Downloads folder so you can find it easily.

### Step 2 — Enable installation from unknown sources

For security reasons, Android blocks the installation of apps that do not come from the Play Store by default. You will need to unlock this option once. The exact path in the settings varies slightly depending on the phone manufacturer and Android version:

On **Android 8 and later** (most modern devices), the permission is tied to the app that opens the file. When you try to open the APK, Android will directly show you a message along the lines of "Your phone is not allowed to install unknown apps from this source." Tap **Settings** in the message, then enable **Allow from this source**. After installation you can leave the permission enabled or disable it again.

On **Android 7 and earlier**, go to **Settings → Security** and enable the **Unknown sources** or **Unknown origins** option.

On **Samsung** devices, the path might be **Settings → Applications → Menu (three dots in the top right) → Special access → Install unknown apps**.

### Step 3 — Install the app

After enabling the permission, open the APK file from the Downloads folder (you can use your phone's file manager or open it directly from the download notification). A confirmation screen will appear with the app name and the permissions required. Tap **Install** and wait a few seconds. When done, tap **Open** to launch ITIS Navigator immediately or **Done** to close the wizard and open it later from the app list.

### Step 4 — Future updates

Since the app does not update automatically like Play Store apps, you will need to repeat the installation process each time a new version is released. Keep an eye on school communications or the project's GitHub page to find out when updates are available. Updates are especially important for the bus timetable section, whose data is manually updated by the developers in line with Cotral's seasonal changes.

### Minimum device requirements

The app requires Android 5.0 (Lollipop) or later, an internet connection (Wi-Fi or mobile data) for the weather and navigation functions, and GPS enabled for the navigation function. There are no special requirements in terms of RAM or processor power: the app is designed to work correctly even on entry-level devices.

---

## 3. First launch and initial setup

On the first launch of the app, Android may show you one or more permission requests. Understanding what is being requested and why will help you make informed choices.

### Location permission (GPS)

This is the most important request. The app needs to know your geographical location for two reasons: to calculate the route from your current position to ITIS during navigation, and to show a precise indicator on the map. Without this permission, GPS navigation will not be available, but all other functions (weather, bus timetables, school information) will continue to work normally.

When Android asks you, you will generally have three options: **"Allow all the time"**, **"Allow only while using the app"**, and **"Deny"**. We recommend choosing **"Allow only while using the app"**, which is the most balanced choice between convenience and battery saving: the app will access GPS only when it is open and visible, not in the background.

### Internet permission

Internet access does not require explicit confirmation on Android: it is granted automatically at the time of installation. It is required for downloading weather data from station LAZ543 and for calculating the route via Google Maps.

### What to do if you denied a permission by mistake

You can modify permissions at any time by going to **System Settings → Apps → ITIS Navigator → Permissions**. From there you can re-enable the location permission without having to reinstall the app.

### No registration required

ITIS Navigator does not require account creation, does not ask for your name, email, or phone number, and does not collect users' personal data. You can use it immediately after installation, with no login procedure.

---

## 4. Interface overview

The interface of ITIS Navigator is designed to be immediate and readable even in a hurry — for example while standing at the bus stop or walking to school. The visual philosophy is that of an information dashboard: all important information is visible on the main screen without having to navigate through menus or subsections.

The app is organized into two main screens. The **Home screen** is what you see as soon as you open the app and contains a summary of all information: clock, weather, quick access to navigation, a preview of bus timetables, and school contacts. The **detail screens** (GPS navigation and bus timetables) open when you tap the respective elements on the Home and provide complete information for each function.

Navigation between screens happens with natural gestures: tap an element to open the detail view, and use Android's **Back** button (or the arrow at the top left) to return to the Home. There are no hidden hamburger menus or tab bars: everything is accessible in at most two taps.

---

## 5. Main screen (Home)

The main screen is the starting point of every session with the app. It is structured vertically with information blocks stacked one on top of the other, each dedicated to a specific function. Let's look at them in detail from top to bottom.

### Dynamic clock and date

At the top of the screen sits a digital clock showing the current time updated to the second, accompanied by the full date with the day of the week, day number, month, and year. This block is not decorative: it has a precise practical function, namely letting you check the time without ever leaving the app — especially useful when you are monitoring the countdown to the next bus and want an immediate time reference on the same screen.

The clock uses your Android device's system time, so it automatically reflects time zone changes and daylight saving time. No configuration is required on your part.

### Weather widget

Just below the clock is the weather block, one of the app's distinctive strengths. Unlike many applications that show generic forecasts based on the city, ITIS Navigator shows data **measured at this very moment by the weather station physically installed inside the institute** (station code: LAZ543). This means that when you read "14°C and clear skies", you are seeing the real conditions in the courtyard of ITIS, not a meteorological interpolation for the Cassino urban area.

The widget is compact but informative: it prominently displays the current temperature with the condition icon (sun, clouds, rain, wind), and immediately below a quick summary of humidity and wind speed. Full detailed data is available in the dedicated section, described in chapter 7.

If the station is unreachable (due to lack of connection or maintenance), the widget clearly signals this with a note and shows realistic simulated data calculated based on the season.

### "Navigate to ITIS" button

At the center of the main screen is a large, clearly visible button labeled "Navigate to ITIS" (or equivalent icon). With a single tap, the app launches the GPS navigation system and shows you the route from your current position to the institute's entrance on Via S. Pertini, Cassino. The button is intentionally prominent because it represents the most common use case: a student who is unsure of the route or finds themselves in an unusual location and needs immediate directions. For full details on navigation, see chapter 6.

### Cotral bus timetable card

In the central-lower part of the Home you will find a card showing a preview of the Cotral bus timetables for the main stops in Cassino. The card displays the next two or three scheduled trips with their respective countdowns, so you can judge at a glance whether you still have time or need to hurry. The countdown is calculated in real time using the device's clock and updates automatically every second while you are looking at the screen.

Tapping the card takes you to the full bus timetable screen, described in chapter 8, where you can select the stop and the specific pole and see the complete list of trips for the day.

### School information block

At the bottom of the main screen is a compact block with the essential contact information for ITIS E. Majorana: physical address, institutional email address, and a link to the official website. Tapping the website link, Android will open the default browser and take you directly to `itiscassino.edu.it`. For details on this section, see chapter 9.

---

## 6. GPS navigation to ITIS

The navigation function is probably the most technically sophisticated in the app. It uses two systems in combination: **Google Maps** for map display and real-time positioning, and **OpenRouteService** for route calculation and step-by-step instruction generation. The result is a navigation experience comparable to that of a dedicated navigation device, but focused on a single destination: ITIS Majorana.

### How to start navigation

From the main screen, tap the **"Navigate to ITIS"** button. The app will immediately check whether location permission has been granted: if so, it will acquire the GPS signal and start calculating the route within a few seconds. If permission has not yet been granted, Android will show the authorization request described in chapter 3.

After tapping the button, it is normal to wait a few seconds before the map loads and the route appears: GPS needs a moment to acquire a stable signal, especially if you have just come out of a building or just turned on your phone.

### The navigation screen in detail

Once the route is ready, a full-screen view opens with several elements overlaid on the map.

**The interactive map** occupies the entire screen area. It shows the surrounding area with streets, buildings, and points of interest loaded from Google Maps. Two main elements are visible on the map: your position indicator (a dot or arrow representing where you are and which direction you are facing) and the route trace, drawn as a colored line that starts from your position and ends at the entrance to ITIS. As you move, the map rotates and pans to keep your position always at the center, exactly as a car navigation device would. You can also touch and drag the map to explore it freely, and use the pinch gesture (bring two fingers together and apart) to zoom in and out.

**The route information panel** is overlaid on the map, generally at the top or bottom of the screen, and shows two key data points: the **total remaining distance** (expressed in kilometers or meters depending on how far away you are) and the **estimated arrival time** (expressed in minutes). Both values update dynamically as you proceed along the route: if you stop, the estimated time will increase; if you speed up or take a shortcut, it will decrease accordingly.

**Step-by-step instructions** appear as a text banner describing the next maneuver to perform: for example "Turn right onto Via Roma", "Continue straight for 300 meters", "You have arrived at your destination." These instructions change automatically as you approach the point where you need to turn. The logic is identical to that of Google Maps or Waze: the app continuously calculates your distance from the next turn point and updates the banner accordingly.

**Automatic position updates** happen in the background without you needing to do anything. The phone's GPS sends your position to the app multiple times per second, and the map updates accordingly. If you accidentally stray from the planned route (for example because you took a different road), the app will detect this and can recalculate a new route starting from your updated position.

### Typical use cases

**New student who doesn't know the way**: if it's your first day at ITIS or you don't know the area well, open the app from home or from the bus stop and start navigation. Follow the step-by-step instructions to the school entrance.

**Student who finds themselves in an unusual location**: if for any reason you find yourself at a point in Cassino you don't know well and need to reach the school, navigation calculates the optimal route from wherever you are at that moment, without needing to manually enter the starting point.

**Parent accompanying their child by car**: the route is also optimized for driving. Start navigation before leaving or while already on the way to get real-time directions.

**Visiting the school for meetings or events**: even non-students who need to go to ITIS for a meeting with teachers or a school event can use the navigation in exactly the same way.

### Tips for optimal navigation

To get the best possible GPS signal, it is preferable to be outdoors or near a window when acquiring the signal. GPS struggles to acquire a precise position inside buildings or in areas with many closely spaced tall buildings. Once acquired, the signal generally remains stable even in difficult conditions.

If the map takes a long time to load, check that you have an active data connection: the map and route calculation require internet. If you are in an area with a weak signal, wait a few extra seconds for everything to appear correctly.

If your phone has the **"High accuracy"** option in the GPS settings (which uses both GPS and Wi-Fi networks and mobile data for location), enable it: it significantly improves the precision and speed of position acquisition.

To save battery during a long navigation session, you can reduce screen brightness to a minimum. Navigation will continue to work normally as GPS data and instructions are calculated in the background.

---

## 7. Real-time weather — Station LAZ543

The weather section of ITIS Navigator is technically the most original part of the app. While almost all weather applications show forecasts based on numerical models or weather stations located even several kilometers from the point of interest, ITIS Navigator connects directly to the **official weather station physically installed inside ITIS E. Majorana**, registered on the MeteoNetwork network with the identification code **LAZ543**.

### Why this station is special

Station LAZ543 is located on the school campus of ITIS Majorana in Cassino. The data it transmits represents the real atmospheric conditions at that precise location, not an interpolation or estimate. When the app shows "10°C with wind at 15 km/h from the northwest", those are the real measurements recorded by the physical instruments installed at the school at the moment you are looking at the screen. This geographical precision is particularly useful in an area like that of Cassino, where weather conditions can vary significantly between the city center, the industrial zone, and the hillside neighborhoods.

### How to access full weather data

The main weather data is always visible directly on the Home screen via the summary widget. To view all available parameters, tap the weather widget on the Home to expand it or access the detailed weather screen.

### All available parameters

Station LAZ543 measures and transmits a series of physical quantities that the app makes available in a readable format. Let's look at each one with a brief explanation of its practical meaning.

**Temperature (°C)** is the most intuitive quantity: the air temperature measured in degrees Celsius. Useful for deciding how to dress before going out. Keep in mind that the temperature may vary between your current location and the school, especially on windy days or in the presence of a temperature inversion.

**Relative humidity (%)** measures how much water vapor is present in the air relative to the maximum that temperature can hold. A high value (above 75–80%) indicates very humid air, which can make the cold feel more biting in winter and the heat more suffocating in summer. A low value (below 40%) indicates dry air. Useful for understanding whether the day will feel "heavy" or fresh beyond just the simple temperature.

**Atmospheric pressure (hPa)** indicates air pressure and is expressed in hectopascals (hPa, equivalent to millibars). Typical values hover around 1013 hPa at sea level and decrease slightly at altitude. A falling pressure over the course of a few hours generally indicates the arrival of unstable weather conditions; a rising pressure indicates improvement. This parameter is more useful for trends over time than for an instantaneous reading.

**Wind speed (km/h)** shows how fast the air is moving. Values below 10 km/h are considered light wind or calm; between 10 and 30 km/h we speak of a breeze; above 50 km/h the wind can cause difficulties when walking. In winter, a sustained wind can make the perceived temperature much lower than the actual one.

**Wind direction** indicates where the wind is coming from, expressed in degrees (0°/360° = North, 90° = East, 180° = South, 270° = West) or with cardinal letters (N, NE, E, SE, etc.). In summer, a wind from the west or north generally brings cooler air; in winter, easterly winds can bring cold continental air.

**Precipitation rate (mm/h)** measures how much rain (or snow, expressed as liquid equivalent) is falling right now, expressed in millimeters per hour. A value of 0 means it is not raining; values between 0.1 and 2 mm/h indicate light rain (a few drops or drizzle); between 2 and 10 mm/h we speak of moderate rain; above 10 mm/h of heavy rain or a storm. If this value is greater than zero, it is definitely time to grab an umbrella.

**Dew point (°C)** is the temperature to which the air would need to cool to reach saturation and cause water vapor to condense. In practice, if the current temperature approaches the dew point, there is fog or it is likely to form. It is also an indicator of perceived humidity: when the dew point exceeds 15°C, the air starts to feel "sticky."

### Update frequency

Data from station LAZ543 is automatically updated by the app each time the weather screen is opened or whenever you return to the Home after a certain interval of time. The station itself transmits data at a frequency of several minutes, so what you see is always updated just a few minutes ago, not hours before.

### What happens when the station is unavailable

The weather station, like any physical instrument, can occasionally undergo maintenance or be temporarily unreachable due to connectivity problems. In these cases, the app does not simply show an error, but automatically switches to a system of **realistic simulated weather data**. This system generates plausible values for the current season and time of day, based on historical climate averages for the Cassino area. The weather card will clearly indicate when this fallback mode is in use, with a visible note below the data.

### Where to see station data outside the app

If you want to consult the measurement history or verify the data in a browser, station LAZ543 has a public page on MeteoNetwork at `meteonetwork.eu/it/weather-station/laz543-stazione-meteorologica-di-itis-majorana-cassino`. The data is available under CC-BY 4.0 license, which means it can be freely viewed and reused by citing the source.

---

## 8. Cotral bus timetables

For most ITIS Majorana students who don't live in the immediate vicinity of the school, the Cotral bus is the main means of transport. ITIS Navigator integrates the **official scheduled timetables** for Cotral services at Cassino stops, making it possible to know immediately when the next bus comes without having to open the Cotral website or consult a physical timetable board.

### How the timetable system works

It is important to understand that the timetables in the app are **static**: they are defined by the developer based on the official timetable boards published by Cotral and are included directly in the app package at the time of installation. This has two practical consequences. The first, positive one, is that the timetables are available even **without an internet connection**: since the data is already on the phone, you can consult them at any time, even in an area without signal. The second, to be aware of, is that the app does not know in real time whether a bus is running late, whether a trip has been cancelled, or whether Cotral has modified its timetables after the last APK version: the timetables shown are always the theoretical scheduled ones.

The **countdown** you see next to each trip is calculated in real time by the app by subtracting the scheduled trip time from the device's current time. If your phone has the exact time, the countdown will be accurate to the minute.

### How to access the bus section

You can access the bus timetables in two ways. The first is to tap the **Cotral bus card** on the main screen, which takes you directly to the stop selection screen. The second is to keep an eye on the countdown in the card itself, which already shows the next trips without needing to navigate to another screen.

### Selecting the right stop

The first thing you will see on the bus screen is a list of available Cotral stops for the Cassino area. The stops are those closest to the institute or commonly used by students. The main stop is **Cassino – Bus Station**, which is the starting and ending point for most trips passing through the city. Other stops are also available in the app: scrolling through the list you will find those closest to where you live or where you normally catch the bus.

If you don't know which stop to use, the safest choice is always the Cassino Bus Station, which is served by the greatest number of trips.

### Selecting the pole

Once you have chosen the stop, the app asks you to select the **pole**. In public transport terminology, a "pole" is a single physical stop point — the post with the timetable sign — which corresponds to a specific direction of travel. A stop can have multiple poles because buses pass in both directions: there will be one pole for buses heading east and one for those heading west, or organized by line. Choose the pole corresponding to the direction from which or towards which you want to travel.

If you are not sure which pole to choose, select them one at a time and look at which trips appear: the line name or the final destination will help you understand if it is the right one.

### Reading the trip list

Once the pole is selected, a list of the next scheduled trips for that stop will appear, ordered chronologically. For each trip, the following are shown: the scheduled passing time at the stop, the countdown in minutes and seconds to the next passing, and the bus line or route.

Trips are dynamically filtered: only future ones relative to the current time are shown, and the list updates automatically as time passes and trips become past ones.

### Tips for making the most of the bus section

The most effective way to use this function is to open the app in the morning before leaving home, check the countdown to the next bus, and plan your departure accordingly. Keeping in mind that the bus may be early or late compared to the scheduled time (something the app cannot know), it is always advisable to arrive at the stop a few minutes before the indicated time.

If you are checking timetables for the return home, remember that afternoon trips may have a different frequency from morning ones: scroll through the entire list to get a complete picture of the available trips.

When Cotral modifies its seasonal timetables (typically in September for the start of the school year and in June for the end), the timetables in the app may not be updated until a new version of the APK is published. During these periods, it is advisable to also check timetables on the official Cotral website or at the Bus Station.

---

## 9. School information

The ITIS information section is accessible directly from the main screen and collects the official institute references. This is static data that does not require an internet connection.

### Institute contact details

The **Main Campus** of ITIS E. Majorana is located at Via S. Angelo, 2 (Loc. Folcara) — 03043 Cassino (FR). The **Branch Campus** is situated at Via S. Angelo (Loc. Folcara) — 03043 Cassino (FR), in the same area. This is also the destination point of the GPS navigation function: when you start navigation, the app will automatically guide you to the institute's main campus.

The **switchboard** can be reached at 0776 312302. The **institutional email address** is `frtf020002@istruzione.it`, while for formal communications requiring legal validity, the **Certified Electronic Mail (PEC)** is available at `frtf020002@pec.istruzione.it`.

### Link to the official website

Tapping the website link in the information section, your device's browser will open directly at `itiscassino.edu.it`. The institute's official website is the place to find official communications, circulars, the school calendar, information on extracurricular activities, access to the electronic register, and all news regarding the school. ITIS Navigator does not replace the official website for these functions: it only provides the quick link to reach it in one tap.

---

## 10. Offline use and connectivity

ITIS Navigator is designed to be functional in different connectivity conditions, with some functions requiring internet and others working completely offline.

### What works without a connection

The **bus timetables** section is completely offline: the timetables are included in the app package and do not require any connection to be displayed. The countdown also works offline, as it is based on the device's clock. **School information** (address, email, phone number) is also static data accessible without internet, although the website link obviously requires a connection to load the page. The **clock and date** on the Home do not require internet.

### What requires a connection

**Weather** requires internet to download real-time data from station LAZ543. Without a connection, the app will automatically show realistic simulated data as described in chapter 7. **GPS navigation** requires internet to load Google Maps tiles and to calculate the route via OpenRouteService. The phone's GPS works even offline (the satellite signal does not go through the internet), but the displayed map and route calculation require a connection. If you had the navigation screen open with an active connection and then lose the signal, the map may only show the portion already downloaded in cache.

### Connectivity tips when on the move

If you use mobile data, keep in mind that loading the Google map can consume a noticeable amount of data, especially if you scroll around the map a lot or zoom in and out. For standard daily use (starting navigation from a fixed point to ITIS and letting it run), consumption is still contained and should not be an issue with most data plans.

---

## 11. Troubleshooting

This section collects the most common problems you might encounter while using ITIS Navigator, with detailed solutions.

### Installation problems

**The APK doesn't install and an "App not installed" error message appears**
This error can have several causes. The most common is that an older or newer version of the app is already installed on the device and you are trying to install an incompatible version. Try uninstalling the previous version from the system app list first, then reinstall the APK. If the error persists, check that the APK file was downloaded completely (verify it is not corrupted by trying to download it again).

**Android says the app is "damaged" or "potentially dangerous"**
Android shows these warnings for any app installed outside the Play Store, regardless of its actual safety. This is a precautionary system warning, not malware detection. If the APK file comes from the school or the developer's official GitHub repository (`github.com/christianm08/itis-navigator`), you can proceed with the installation without concern.

### GPS navigation problems

**The map doesn't load or appears grey**
The problem is almost certainly the internet connection. Check that you are connected to Wi-Fi or have active mobile data and that the signal is sufficient. If you are connected but the map doesn't load, try closing and reopening the app.

**My location on the map is wrong or imprecise**
GPS needs a few seconds (sometimes even a minute) to acquire a precise signal, especially right after turning on the phone or coming out of a building. Wait a few seconds outdoors before starting navigation. In the phone settings, check that the location mode is set to "High accuracy" (GPS + Wi-Fi + mobile network) rather than just "Battery saving" (which uses only mobile network and Wi-Fi, and is much less precise).

**Navigation doesn't start and the app asks for location permission**
You previously denied the location permission. To restore it, go to **Android Settings → Apps → ITIS Navigator → Permissions → Location** and select "Allow only while using the app."

**The step-by-step instructions don't match the road I'm on**
This may be due to a delay in route recalculation after you took a detour. Wait a few seconds: the app will detect that you have moved away from the original route and will automatically recalculate a new itinerary from your updated position.

### Weather problems

**Weather data doesn't update**
Check that you have an active internet connection. If the connection is present but the data seems old, try closing the weather screen and reopening it, or close and reopen the app. If the problem persists, there may be a temporary unavailability of station LAZ543: in this case the app will automatically show simulated data.

**The app shows "simulated data" instead of real data**
This means that station LAZ543 is not reachable at that moment, due to maintenance, connectivity problems of the station itself, or lack of internet on your device. Check your connection first; if it's active, the station may be temporarily offline. Try again in a few minutes.

### Bus timetable problems

**The timetables shown don't match the real timetable board**
This can happen when Cotral has modified its seasonal timetables after the publication of the last APK version. Check whether an updated version of the app is available. In the meantime, check timetables directly on the Cotral website or at the physical stop timetable board.

**I can't find my stop in the list**
The app includes the main stops in the Cassino area closest to ITIS. If your usual stop is not present, use the closest available stop in the list or consult the Cotral website directly for specific trips.

**The countdown shows a negative or unusual value**
This means that your Android device's clock is not correctly synchronized with the real time. Go to **Settings → General management (or System) → Date and time** and enable **Automatic date and time** to sync the clock with network servers.

### General problems

**The app closes unexpectedly (crash)**
Try closing the app from recent apps (square button or swipe gesture from the bottom) and restarting it. If the problem persists, try turning the phone off and back on. If you continue to have repeated crashes, report the problem to the developers through the project's GitHub page, describing what you were doing when the app closed and your phone model.

**The app consumes a lot of battery**
ITIS Navigator's battery consumption is generally contained. The function that has the most impact is **active GPS navigation**, which keeps the GPS running continuously. If you are not navigating, make sure you have exited the navigation screen and are on the Home: the Home consumes much less. If you notice unusual consumption in the background anyway, go to **Settings → Battery → Battery optimization** and add ITIS Navigator to the list of optimized apps.

---

## 12. Frequently Asked Questions (FAQ)

**Is the app free?**
Yes, ITIS Navigator is completely free. It contains no advertising, requires no subscriptions, and has no in-app purchases. It is a project developed by two ITIS students for the benefit of the school community.

**Is ITIS Navigator safe? Does it collect personal data?**
The app does not collect, transmit, or store users' personal data. It requires no registration, has no account, and does not know your identity. Location data is used exclusively in real time for route calculation and is never saved or sent to external servers in a form associated with your person. The source code is publicly available on GitHub and anyone can verify it.

**Why isn't the app on the Play Store?**
Publishing on the Play Store requires a verification procedure by Google and the payment of an annual developer fee. As this is a non-commercial student project, the app is distributed directly via APK, which is a perfectly valid method for applications intended for a specific community.

**Can I use ITIS Navigator on an Android tablet?**
Yes, the app works on any Android 5.0 or later device, including tablets. The interface may not be optimized for very large screens (it is designed primarily for smartphones), but all functions are available and usable.

**Are the bus timetables up to date?**
The timetables in the app correspond to the official Cotral timetable board valid at the time of the release of the last APK version. Cotral typically modifies its timetables in September (start of the school year) and in June (end of the school year). The developer commits to releasing updated versions of the app in line with these changes, but in case of doubt it is always advisable to also check on the official Cotral website.

**Can I use navigation even if I'm already in Cassino but don't know the way on foot?**
Absolutely yes. Navigation works from any point on the map, whether you are by car, bus, or on foot. If you are in the center of Cassino and want to know how to reach the school on foot, start navigation and follow the instructions: the app will adapt to your movement.

**Is the weather shown a forecast or a measurement?**
It is a **real-time measurement**, not a forecast. The data you see is that recorded at this moment by the physical instruments of station LAZ543 installed at ITIS. These are not forecasts for the coming hours, but the current conditions at the moment you are looking at the app.

**Who can I contact if I find a bug or want to suggest a feature?**
You can report problems or suggest new features by opening an "Issue" on the project's GitHub page at `github.com/christianm08/itis-navigator`. The developers are ITIS students and actively follow the project.

---

## 13. Credits, licenses, and technical information

### The developers

ITIS Navigator was conceived and developed by **Christian Mascio** (GitHub: [@christianm08](https://github.com/christianm08)) and **Vincenzo Riccio** (GitHub: [@V1ns533](https://github.com/V1ns533)), both students of ITIS E. Majorana in Cassino. The project was born as a student initiative with the goal of creating a concrete and useful tool for the school community of the institute, while also demonstrating the mobile development skills acquired during and beyond their school studies.

### Technology

The app is developed with **Flutter**, Google's open source framework for creating cross-platform mobile applications using the Dart language. Flutter allows writing the code once and compiling it for both Android and iOS, guaranteeing a fluid and responsive interface on all compatible devices.

### Source code

ITIS Navigator is an **open source** project. The complete source code is publicly available on GitHub at `github.com/christianm08/itis-navigator` and is distributed under the **MIT license**, which allows anyone to view, use, modify, and redistribute it freely, even for commercial purposes, provided the original author's attribution is maintained.

### Third-party services and data

The app makes use of several external services to provide its functions.

**Google Maps Platform** provides the display of interactive maps and GPS positioning on the navigation screen. Google Maps is the world's most widely used mapping service and guarantees accurate and up-to-date road data for the Cassino area.

**OpenRouteService** is the routing engine used to calculate the optimal route and generate step-by-step instructions. It is an open source service based on OpenStreetMap data, available free of charge for non-commercial use.

**MeteoNetwork** is the network of amateur and school weather stations in Italy to which station LAZ543 belongs. Weather data is retrieved via MeteoNetwork's APIs and is distributed under the **CC-BY 4.0 (Creative Commons Attribution)** license, which means it can be freely viewed and reused by citing the source MeteoNetwork and the station code LAZ543.

**Cotral S.p.A.** is the regional public transport company of Lazio that manages the bus lines serving Cassino. The timetables integrated in the app are based on the official timetable boards published by Cotral.

### Institute contacts

**ITIS E. Majorana — Cassino**

Main Campus: Via S. Angelo, 2 (Loc. Folcara) — 03043 Cassino (FR)
Branch Campus: Via S. Angelo (Loc. Folcara) — 03043 Cassino (FR)
Switchboard: 0776 312302
Institutional email: frtf020002@istruzione.it
PEC: frtf020002@pec.istruzione.it
Website: [itiscassino.edu.it](https://itiscassino.edu.it/)

---

*Documentation written for ITIS Navigator — Version 1.0*
*ITIS E. Majorana, Cassino (FR)*
*Developed with Flutter by Christian Mascio and Vincenzo Riccio*
