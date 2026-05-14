# 📱 ITIS Navigator — Documentazione Utente Completa

**Guida ufficiale per studenti, famiglie e personale dell'ITIS E. Majorana di Cassino**

*Versione documentazione: 1.0 — Piattaforma supportata: Android (APK)*

---

![Icona](assets/icon/app_icon.png)


## Indice generale

1. [Cos'è ITIS Navigator](#1-cosè-itis-navigator)
2. [Installazione dell'app su Android](#2-installazione-dellapp-su-android)
3. [Primo avvio e configurazione iniziale](#3-primo-avvio-e-configurazione-iniziale)
4. [Panoramica dell'interfaccia](#4-panoramica-dellinterfaccia)
5. [Schermata principale (Home)](#5-schermata-principale-home)
6. [Navigazione GPS verso l'ITIS](#6-navigazione-gps-verso-litis)
7. [Meteo in tempo reale — Stazione LAZ543](#7-meteo-in-tempo-reale--stazione-laz543)
8. [Orari bus Cotral](#8-orari-bus-cotral)
9. [Informazioni sulla scuola](#9-informazioni-sulla-scuola)
10. [Utilizzo offline e connettività](#10-utilizzo-offline-e-connettività)
11. [Risoluzione dei problemi](#11-risoluzione-dei-problemi)
12. [Domande frequenti (FAQ)](#12-domande-frequenti-faq)
13. [Crediti, licenze e informazioni tecniche](#13-crediti-licenze-e-informazioni-tecniche)

---

## 1. Cos'è ITIS Navigator

ITIS Navigator è un'applicazione mobile gratuita sviluppata appositamente per la comunità scolastica dell'**Istituto Tecnico Industriale E. Majorana di Cassino (FR)**. Il progetto nasce dall'iniziativa di due studenti dell'istituto — **Christian Mascio** e **Vincenzo Riccio** — con l'obiettivo di raccogliere in un unico strumento tutte le informazioni pratiche di cui uno studente ha bisogno ogni giorno per raggiungere e organizzare la propria giornata scolastica.

L'idea di fondo è semplice: prima di uscire di casa, uno studente ha bisogno di sapere tre cose fondamentali — che tempo fa all'ITIS, quando passa il prossimo bus, e come arrivare a scuola se non conosce la strada o si trova in una posizione insolita. ITIS Navigator risponde a tutte e tre queste domande in una sola schermata, senza dover aprire più applicazioni diverse.

### A chi è rivolta

L'app è pensata principalmente per gli **studenti** che frequentano l'ITIS Majorana, ma risulta utile anche per i **genitori** che devono accompagnare o monitorare i figli, per i **nuovi iscritti** che non conoscono ancora i percorsi per raggiungere la scuola, e per chiunque debba recarsi all'istituto per la prima volta.

### Cosa può fare ITIS Navigator

In sintesi, l'app offre quattro macro-funzionalità principali. La prima è la **navigazione GPS turn-by-turn**: partendo dalla tua posizione attuale, l'app calcola il percorso ottimale verso l'ITIS e ti guida passo dopo passo con indicazioni aggiornate in tempo reale, esattamente come un navigatore tradizionale. La seconda è il **meteo iperlocale**: i dati meteorologici non provengono da una generica previsione per la città di Cassino, ma dalla stazione meteorologica fisica installata all'interno dell'ITIS stesso, il che significa che stai guardando le condizioni reali nel luogo esatto in cui stai andando. La terza è la **consultazione degli orari bus Cotral**: l'app contiene gli orari ufficiali programmati delle corse per le fermate di Cassino e mostra un countdown che scorre in tempo reale verso il prossimo autobus. La quarta è l'accesso rapido alle **informazioni di contatto dell'istituto**, con un collegamento diretto al sito ufficiale della scuola.

### Piattaforma supportata

ITIS Navigator è disponibile **esclusivamente per Android** e si installa tramite file APK. Non è presente sul Google Play Store né sull'App Store di Apple.

---

## 2. Installazione dell'app su Android

Poiché ITIS Navigator non è distribuita tramite il Google Play Store, l'installazione richiede un passaggio aggiuntivo rispetto alle app tradizionali: abilitare l'installazione da sorgenti esterne. Questo è un procedimento del tutto normale e sicuro quando il file APK proviene da una fonte affidabile come la scuola o il repository ufficiale dello sviluppatore.

### Passo 1 — Ottieni il file APK

Il file APK di ITIS Navigator viene distribuito direttamente dalla scuola o è scaricabile dalla pagina ufficiale del progetto su GitHub all'indirizzo `github.com/christianm08/itis-navigator`. Assicurati di scaricare sempre l'ultima versione disponibile, che sarà nominata con un numero di versione (ad esempio `itis-navigator-v1.0.apk`). Salva il file nella memoria del tuo dispositivo Android, preferibilmente nella cartella Download per trovarlo facilmente.

### Passo 2 — Abilita l'installazione da sorgenti sconosciute

Per motivi di sicurezza, Android blocca di default l'installazione di app che non provengono dal Play Store. Dovrai sbloccare questa opzione una sola volta. Il percorso esatto nelle impostazioni varia leggermente a seconda del produttore del telefono e della versione di Android:

Su **Android 8 e versioni successive** (la maggior parte dei dispositivi moderni), il permesso è legato all'app che apre il file. Quando provi ad aprire l'APK, Android ti mostrerà direttamente un messaggio del tipo "Il tuo telefono non è autorizzato a installare app sconosciute da questa sorgente". Tocca **Impostazioni** nel messaggio, poi attiva **Consenti da questa sorgente**. Dopo l'installazione puoi lasciare il permesso attivo o disattivarlo nuovamente.

Su **Android 7 e versioni precedenti**, vai in **Impostazioni → Sicurezza** e attiva la voce **Origini sconosciute** o **Sorgenti sconosciute**.

Su dispositivi **Samsung**, il percorso potrebbe essere **Impostazioni → Applicazioni → Menu (tre puntini in alto a destra) → Accesso speciale → Installa app sconosciute**.

### Passo 3 — Installa l'app

Dopo aver abilitato il permesso, apri il file APK dalla cartella Download (puoi usare il gestore file del tuo telefono oppure aprirlo direttamente dalla notifica di download). Comparirà una schermata di conferma con il nome dell'app e le autorizzazioni richieste. Tocca **Installa** e attendi qualche secondo. Al termine, tocca **Apri** per avviare subito ITIS Navigator oppure **Fine** per chiudere il wizard e aprirla in un secondo momento dall'elenco delle app.

### Passo 4 — Aggiornamenti futuri

Poiché l'app non si aggiorna automaticamente come le app del Play Store, sarà necessario ripetere il processo di installazione ogni volta che viene rilasciata una nuova versione. Tieni d'occhio le comunicazioni della scuola o la pagina GitHub del progetto per sapere quando sono disponibili aggiornamenti. Gli aggiornamenti sono importanti soprattutto per la sezione orari bus, i cui dati vengono aggiornati manualmente dagli sviluppatori in base alle variazioni stagionali di Cotral.

### Requisiti minimi del dispositivo

L'app richiede Android 5.0 (Lollipop) o versioni successive, una connessione a Internet (Wi-Fi o dati mobili) per le funzioni meteo e navigazione, e il GPS attivato per la funzione di navigazione. Non esistono requisiti particolari in termini di RAM o potenza del processore: l'app è progettata per funzionare correttamente anche su dispositivi di fascia entry-level.

---

## 3. Primo avvio e configurazione iniziale

Al primo avvio dell'app, Android potrebbe mostrarti una o più richieste di autorizzazione. Capire cosa viene richiesto e perché ti aiuterà a fare scelte consapevoli.

### Autorizzazione alla posizione (GPS)

Questa è la richiesta più importante. L'app ha bisogno di conoscere la tua posizione geografica per due motivi: calcolare il percorso dalla tua posizione attuale all'ITIS durante la navigazione, e mostrare un indicatore preciso sulla mappa. Senza questo permesso la navigazione GPS non sarà disponibile, ma tutte le altre funzioni (meteo, orari bus, informazioni scuola) continueranno a funzionare regolarmente.

Quando Android ti chiede, avrai generalmente tre opzioni: **"Consenti sempre"**, **"Consenti solo durante l'uso dell'app"** e **"Nega"**. Ti raccomandiamo di scegliere **"Consenti solo durante l'uso dell'app"**, che è la scelta più equilibrata tra comodità e risparmio batteria: l'app accederà al GPS solo quando è aperta e visibile, non in background.

### Autorizzazione a Internet

L'accesso a Internet non richiede una conferma esplicita su Android: viene concesso automaticamente al momento dell'installazione. È necessario per il download dei dati meteo dalla stazione LAZ543 e per il calcolo del percorso tramite le mappe di Google.

### Cosa fare se hai negato un permesso per errore

Puoi modificare le autorizzazioni in qualsiasi momento andando in **Impostazioni di sistema → App → ITIS Navigator → Autorizzazioni**. Da lì puoi riattivare il permesso alla posizione senza dover reinstallare l'app.

### Nessuna registrazione richiesta

ITIS Navigator non richiede la creazione di un account, non chiede nome, email o numero di telefono, e non raccoglie dati personali degli utenti. Puoi usarla immediatamente dopo l'installazione, senza nessuna procedura di login.

---

## 4. Panoramica dell'interfaccia

L'interfaccia di ITIS Navigator è progettata per essere immediata e leggibile anche di fretta, ad esempio mentre si è in piedi alla fermata del bus o si cammina verso la scuola. La filosofia visiva è quella di un cruscotto informativo: tutte le informazioni importanti sono visibili nella schermata principale senza dover navigare tra menu o sottosezioni.

L'app è organizzata in due schermate principali. La **schermata Home** è quella che vedi appena apri l'app e contiene il riepilogo di tutte le informazioni: orologio, meteo, accesso rapido alla navigazione, anteprima degli orari bus e contatti della scuola. Le **schermate di dettaglio** (navigazione GPS e orari bus) si aprono quando tocchi i rispettivi elementi nella Home e forniscono le informazioni complete per ciascuna funzione.

La navigazione tra le schermate avviene con gesti naturali: tocca un elemento per aprire il dettaglio, e usa il tasto **Indietro** di Android (o la freccia in alto a sinistra) per tornare alla Home. Non ci sono menu hamburger nascosti né tab bar: tutto è accessibile in due tocchi al massimo.

---

## 5. Schermata principale (Home)

La schermata principale è il punto di partenza di ogni sessione con l'app. È strutturata verticalmente con blocchi informativi impilati uno sopra l'altro, ciascuno dedicato a una funzione specifica. Vediamoli nel dettaglio dall'alto verso il basso.

### Orologio e data dinamici

In cima alla schermata campeggia un orologio digitale che mostra l'ora corrente aggiornata al secondo, accompagnato dalla data completa con giorno della settimana, numero del giorno, mese e anno. Questo blocco non è decorativo: ha una funzione pratica precisa, ovvero consentirti di controllare l'ora senza mai uscire dall'app, specialmente utile quando stai monitorando il countdown al prossimo bus e vuoi avere un riferimento temporale immediato nello stesso schermo.

L'orologio usa l'ora di sistema del tuo dispositivo Android, quindi riflette automaticamente i cambi di fuso orario e l'ora legale. Non è necessaria alcuna configurazione da parte tua.

### Widget meteo

Subito sotto l'orologio si trova il blocco meteo, uno dei punti di forza distintivi dell'app. A differenza di molte applicazioni che mostrano previsioni generiche basate sulla città, ITIS Navigator mostra i dati **rilevati in questo preciso momento dalla stazione meteorologica fisicamente installata all'interno dell'istituto** (codice stazione: LAZ543). Questo significa che quando leggi "14°C e cielo sereno", stai vedendo le condizioni reali nel cortile dell'ITIS, non un'interpolazione meteorologica per l'area urbana di Cassino.

Il widget è compatto ma informativo: mostra in primo piano la temperatura attuale con l'icona della condizione (sole, nuvole, pioggia, vento), e subito sotto un riepilogo rapido di umidità e velocità del vento. Per i dati completi e dettagliati è disponibile la sezione dedicata, descritta nel capitolo 7.

Se la stazione non è raggiungibile (per assenza di connessione o manutenzione), il widget lo segnala chiaramente con una nota e mostra dati simulati realistici calcolati in base alla stagione.

### Pulsante "Naviga verso ITIS"

Al centro della schermata principale si trova un pulsante grande e ben visibile etichettato "Naviga verso ITIS" (o icona equivalente). Con un singolo tocco, l'app avvia il sistema di navigazione GPS e ti mostra il percorso dalla tua posizione attuale fino all'ingresso dell'istituto in Via S. Pertini, Cassino. Il pulsante è intenzionalmente prominente perché rappresenta lo scenario d'uso più comune: uno studente che non è sicuro del percorso o si trova in una posizione insolita e ha bisogno di indicazioni immediate. Per tutti i dettagli sulla navigazione, vedi il capitolo 6.

### Card orari bus Cotral

Nella parte centrale-bassa della Home trovi una scheda che mostra un'anteprima degli orari degli autobus Cotral per le fermate principali di Cassino. La card visualizza le prossime due o tre corse programmate con i rispettivi countdown, così puoi valutare a colpo d'occhio se hai ancora tempo o se devi affrettarti. Il countdown è calcolato in tempo reale usando l'orologio del dispositivo e si aggiorna automaticamente ogni secondo mentre guardi la schermata.

Toccando la card si accede alla schermata completa degli orari bus, descritta nel capitolo 8, dove puoi selezionare la fermata e la palina specifica e vedere l'elenco completo delle corse del giorno.

### Blocco informazioni scuola

In fondo alla schermata principale è presente un blocco compatto con le informazioni di contatto essenziali dell'ITIS E. Majorana: indirizzo fisico, indirizzo email istituzionale e un collegamento al sito web ufficiale. Toccando il link al sito web, Android aprirà il browser predefinito e ti porterà direttamente su `itiscassino.edu.it`. Per i dettagli su questa sezione, vedi il capitolo 9.

---

## 6. Navigazione GPS verso l'ITIS

La funzione di navigazione è probabilmente la più sofisticata dell'app dal punto di vista tecnico. Utilizza due sistemi in combinazione: **Google Maps** per la visualizzazione della mappa e il posizionamento in tempo reale, e **OpenRouteService** per il calcolo del percorso e la generazione delle indicazioni passo-passo. Il risultato è un'esperienza di navigazione comparabile a quella di un navigatore dedicato, ma focalizzata su un'unica destinazione: l'ITIS Majorana.

### Come avviare la navigazione

Dalla schermata principale, tocca il pulsante **"Naviga verso ITIS"**. L'app verificherà immediatamente se il permesso alla posizione è stato concesso: se sì, acquisirà il segnale GPS e avvierà il calcolo del percorso nel giro di pochi secondi. Se il permesso non è stato ancora concesso, Android mostrerà la richiesta di autorizzazione descritta nel capitolo 3.

Dopo aver toccato il pulsante, è normale attendere qualche secondo prima che la mappa si carichi e il percorso appaia: il GPS ha bisogno di un momento per acquisire un segnale stabile, specialmente se sei appena uscito da un edificio o hai appena acceso il telefono.

### La schermata di navigazione in dettaglio

Una volta che il percorso è pronto, si apre una schermata a tutto schermo con diversi elementi sovrapposti alla mappa.

**La mappa interattiva** occupa l'intera area dello schermo. Mostra il territorio circostante con strade, edifici e punti di riferimento caricati da Google Maps. Sulla mappa sono visibili due elementi principali: il tuo indicatore di posizione (un punto o una freccia che rappresenta dove ti trovi e in quale direzione stai guardando) e il tracciato del percorso, disegnato come una linea colorata che parte dalla tua posizione e arriva all'ingresso dell'ITIS. Man mano che ti muovi, la mappa ruota e trasla per tenere sempre la tua posizione al centro, esattamente come farebbe un navigatore in auto. Puoi anche toccare e trascinare la mappa per esplorarla liberamente, e usare il gesto di pinch (avvicina e allontana due dita) per zoomare in avanti e indietro.

**Il riquadro delle informazioni di percorso** è sovrapposto alla mappa, generalmente in cima o in basso alla schermata, e mostra due dati fondamentali: la **distanza totale rimanente** (espressa in chilometri o metri a seconda di quanto sei lontano) e il **tempo stimato di arrivo** (espresso in minuti). Entrambi i valori si aggiornano dinamicamente man mano che procedi lungo il percorso: se ti fermi, il tempo stimato si allungherà; se acceleri o prendi una scorciatoia, si accorcerà di conseguenza.

**Le indicazioni passo-passo** appaiono come un banner testuale che descrive la prossima manovra da compiere: ad esempio "Gira a destra su Via Roma", "Continua dritto per 300 metri", "Sei arrivato a destinazione". Queste indicazioni cambiano automaticamente quando ti avvicini al punto in cui devi effettuare la svolta. La logica è identica a quella di Google Maps o Waze: l'app calcola continuamente la tua distanza dal prossimo punto di svolta e aggiorna il banner di conseguenza.

**L'aggiornamento automatico della posizione** avviene in background senza che tu debba fare nulla. Il GPS del telefono invia la tua posizione all'app più volte al secondo, e la mappa si aggiorna di conseguenza. Se ti allontani accidentalmente dal percorso pianificato (ad esempio perché hai preso una strada diversa), l'app lo rileverà e potrà ricalcolare un nuovo percorso partendo dalla tua posizione aggiornata.

### Scenari d'uso tipici

**Studente nuovo che non conosce la strada**: se è il tuo primo giorno all'ITIS o non conosci bene la zona, apri l'app da casa o dalla fermata del bus e avvia la navigazione. Segui le indicazioni passo-passo fino all'ingresso della scuola.

**Studente che si trova in una posizione insolita**: se per qualsiasi motivo ti trovi in un punto di Cassino che non conosci bene e devi raggiungere la scuola, la navigazione calcola il percorso ottimale da dove sei in quel momento, senza bisogno di inserire manualmente il punto di partenza.

**Genitore che accompagna il figlio in auto**: il percorso è ottimizzato anche per la guida in auto. Avvia la navigazione prima di partire o mentre sei già in viaggio per avere indicazioni in tempo reale.

**Visita alla scuola per colloqui o eventi**: anche chi non è studente ma deve recarsi all'ITIS per un colloquio con i professori o un evento scolastico può usare la navigazione esattamente allo stesso modo.

### Suggerimenti per una navigazione ottimale

Per ottenere il miglior segnale GPS possibile, è preferibile trovarsi all'aperto o vicino a una finestra al momento dell'acquisizione del segnale. Il GPS fatica ad acquisire una posizione precisa all'interno di edifici o in zone con molti grattacieli ravvicinati. Una volta acquisito, il segnale rimane generalmente stabile anche in condizioni difficili.

Se la mappa impiega molto tempo a caricarsi, verifica di avere una connessione dati attiva: la mappa e il calcolo del percorso richiedono Internet. Se sei in zona con segnale debole, attendi qualche secondo in più prima che tutto appaia correttamente.

Se il tuo telefono ha l'opzione **"Alta precisione"** nelle impostazioni del GPS (che usa sia il GPS che le reti Wi-Fi e i dati mobili per la localizzazione), attivala: migliora notevolmente la precisione e la velocità di acquisizione della posizione.

Per risparmiare batteria durante una navigazione lunga, puoi ridurre la luminosità dello schermo al minimo. La navigazione continuerà a funzionare normalmente poiché i dati GPS e le indicazioni vengono calcolati in background.

---

## 7. Meteo in tempo reale — Stazione LAZ543

La sezione meteo di ITIS Navigator è tecnicamente la più originale dell'app. Mentre quasi tutte le applicazioni meteo mostrano previsioni basate su modelli numerici o stazioni meteorologiche distanti anche diversi chilometri dal punto d'interesse, ITIS Navigator si collega direttamente alla **stazione meteorologica ufficiale installata fisicamente all'interno dell'ITIS E. Majorana**, registrata sulla rete MeteoNetwork con il codice identificativo **LAZ543**.

### Perché questa stazione è speciale

La stazione LAZ543 è posizionata nel campus scolastico dell'ITIS Majorana a Cassino. I dati che trasmette rappresentano le condizioni atmosferiche reali in quel preciso luogo, non un'interpolazione o una stima. Quando l'app mostra "10°C con vento a 15 km/h da nord-ovest", quelle sono le misurazioni reali rilevate dagli strumenti fisici installati alla scuola nel momento in cui stai guardando lo schermo. Questa precisione geografica è particolarmente utile in una zona come quella di Cassino, dove le condizioni meteo possono variare in modo anche significativo tra il centro città, la zona industriale e i quartieri collinari.

### Come accedere ai dati meteo completi

I dati meteo principali sono sempre visibili direttamente nella schermata Home tramite il widget riassuntivo. Per visualizzare tutti i parametri disponibili, tocca il widget meteo nella Home per espanderlo o accedere alla schermata di dettaglio meteo.

### Tutti i parametri disponibili

La stazione LAZ543 misura e trasmette una serie di grandezze fisiche che l'app rende disponibili in formato leggibile. Vediamole una per una con una breve spiegazione del loro significato pratico.

**Temperatura (°C)** è la grandezza più intuitiva: la temperatura dell'aria misurata in gradi Celsius. Utile per decidere come vestirsi prima di uscire. Tieni presente che la temperatura può variare tra la tua posizione attuale e la scuola, specialmente in giornate ventose o in presenza di inversione termica.

**Umidità relativa (%)** misura quanto vapore acqueo è presente nell'aria rispetto al massimo che quella temperatura può contenere. Un valore alto (sopra il 75-80%) indica aria molto umida, che può far sembrare il freddo più pungente d'inverno e il caldo più soffocante d'estate. Un valore basso (sotto il 40%) indica aria secca. Utile per capire se la giornata sarà "pesante" o fresca anche al di là della semplice temperatura.

**Pressione atmosferica (hPa)** indica la pressione dell'aria ed è espressa in ettopascal (hPa, equivalenti ai millibar). I valori tipici si aggirano intorno a 1013 hPa a livello del mare e diminuiscono leggermente in quota. Una pressione in calo nel corso delle ore indica generalmente l'arrivo di condizioni meteo instabili; una pressione in risalita indica miglioramento. Questo parametro è più utile per tendenze nel tempo che per una lettura istantanea.

**Velocità del vento (km/h)** mostra quanto velocemente si muove l'aria. Valori sotto i 10 km/h sono considerati vento debole o calma; tra 10 e 30 km/h si parla di brezza; sopra i 50 km/h il vento può dare fastidio camminando. In inverno, un vento sostenuto può rendere la temperatura percepita molto più bassa di quella effettiva.

**Direzione del vento** indica da dove proviene il vento, espressa in gradi (0°/360° = Nord, 90° = Est, 180° = Sud, 270° = Ovest) o con le lettere cardinali (N, NE, E, SE, ecc.). In estate, un vento da ovest o da nord porta generalmente aria più fresca; in inverno, i venti da est possono portare aria fredda continentale.

**Tasso di precipitazione (mm/h)** misura quanta pioggia (o neve, espressa in equivalente liquido) sta cadendo in questo momento, espressa in millimetri per ora. Un valore di 0 significa che non sta piovendo; valori tra 0.1 e 2 mm/h indicano pioggia leggera (qualche goccia o pioggerellina); tra 2 e 10 mm/h si parla di pioggia moderata; sopra i 10 mm/h di pioggia intensa o temporale. Se questo valore è maggiore di zero, è decisamente il momento di prendere l'ombrello.

**Punto di rugiada (°C)** è la temperatura a cui l'aria dovrebbe raffreddarsi per raggiungere la saturazione e far condensare il vapore acqueo. In pratica, se la temperatura attuale si avvicina al punto di rugiada, c'è nebbia o è probabile che si formi. È anche un indicatore dell'umidità percepita: quando il punto di rugiada supera i 15°C, l'aria inizia a sembrare "appiccicosa".

### Frequenza di aggiornamento

I dati dalla stazione LAZ543 vengono aggiornati automaticamente dall'app ogni volta che viene aperta la schermata meteo o ogni qualvolta si torna alla Home dopo un certo intervallo di tempo. La stazione stessa trasmette i dati con una frequenza di alcuni minuti, quindi quello che vedi è sempre aggiornato a pochissimi minuti fa, non a ore prima.

### Cosa succede quando la stazione non è disponibile

La stazione meteorologica, come qualsiasi strumento fisico, può andare occasionalmente in manutenzione o essere temporaneamente irraggiungibile a causa di problemi di connettività. In questi casi, l'app non mostra semplicemente un errore, ma commuta automaticamente su un sistema di **dati meteo simulati realistici**. Questo sistema genera valori plausibili per la stagione corrente e il momento della giornata, basandosi su medie climatiche storiche per la zona di Cassino. La card meteo indicherà chiaramente quando si sta usando questa modalità di fallback, con una nota visibile sotto i dati.

### Dove vedere i dati della stazione anche fuori dall'app

Se vuoi consultare lo storico delle misurazioni o verificare i dati su un browser, la stazione LAZ543 ha una pagina pubblica su MeteoNetwork all'indirizzo `meteonetwork.eu/it/weather-station/laz543-stazione-meteorologica-di-itis-majorana-cassino`. I dati sono disponibili sotto licenza CC-BY 4.0, il che significa che sono liberamente consultabili e riutilizzabili citando la fonte.

---

## 8. Orari bus Cotral

Per la maggior parte degli studenti dell'ITIS Majorana che non abitano nelle immediate vicinanze della scuola, l'autobus Cotral rappresenta il mezzo di trasporto principale. ITIS Navigator integra gli **orari ufficiali programmati** delle corse Cotral per le fermate di Cassino, permettendo di sapere immediatamente quando passa il prossimo autobus senza dover aprire il sito di Cotral o consultare un tabellone cartaceo.

### Come funziona il sistema degli orari

È importante capire che gli orari presenti nell'app sono **statici**: vengono definiti dallo sviluppatore basandosi sui tabelloni ufficiali pubblicati da Cotral e sono inclusi direttamente nel pacchetto dell'app al momento dell'installazione. Questo ha due conseguenze pratiche. La prima, positiva, è che gli orari sono disponibili anche **senza connessione a Internet**: poiché i dati sono già nel telefono, puoi consultarli in qualsiasi momento, anche in zona senza segnale. La seconda, da tenere presente, è che l'app non sa in tempo reale se un bus è in ritardo, se una corsa è soppressa o se Cotral ha modificato i propri orari dopo l'ultima versione dell'APK: gli orari mostrati sono sempre quelli teorici programmati sul tabellone.

Il **countdown** che vedi accanto a ogni corsa viene calcolato in tempo reale dall'app sottraendo l'orario programmato della corsa dall'ora attuale del dispositivo. Se il tuo telefono ha l'ora esatta, il countdown sarà preciso al minuto.

### Come accedere alla sezione bus

Puoi accedere agli orari bus in due modi. Il primo è toccare la **card bus Cotral** nella schermata principale, che ti porta direttamente alla schermata di selezione della fermata. Il secondo è tenere d'occhio il countdown nella card stessa, che mostra già le prossime corse senza bisogno di navigare in un'altra schermata.

### Selezionare la fermata giusta

La prima cosa che vedrai nella schermata bus è un elenco delle fermate Cotral disponibili per la zona di Cassino. Le fermate sono quelle più vicine all'istituto o comunemente usate dagli studenti. La fermata principale è **Cassino – Autostazione**, che è il punto di partenza e arrivo della maggior parte delle corse che attraversano la città. Nell'app sono disponibili anche altre fermate: scorrendo l'elenco troverai quelle più vicine a dove vivi o a dove prendi abitualmente il bus.

Se non sai quale fermata usare, la scelta più sicura è sempre l'Autostazione di Cassino, che è servita dal maggior numero di corse.

### Selezionare la palina

Una volta scelta la fermata, l'app ti chiede di selezionare la **palina**. Nel gergo del trasporto pubblico, una "palina" è un singolo punto di fermata fisico — il palo con il cartello dell'orario — che corrisponde a una specifica direzione di marcia. Una fermata può avere più paline perché i bus passano in entrambe le direzioni: ci sarà una palina per i bus diretti verso est e una per quelli diretti verso ovest, oppure organizzate per linea. Scegli la palina corrispondente alla direzione da cui o verso cui vuoi viaggiare.

Se non sei sicuro di quale palina scegliere, selezionale una alla volta e guarda quali corse compaiono: il nome della linea o la destinazione finale ti aiuteranno a capire se è quella giusta.

### Leggere la lista delle corse

Una volta selezionata la palina, comparirà l'elenco delle prossime corse programmate per quella fermata, ordinate cronologicamente. Per ogni corsa vengono mostrati l'orario programmato di passaggio alla fermata, il countdown in minuti e secondi al prossimo passaggio, e la linea o il percorso del bus.

Le corse sono filtrate dinamicamente: vengono mostrate solo quelle future rispetto all'ora attuale, e la lista si aggiorna automaticamente man mano che il tempo passa e le corse diventano passate.

### Consigli per usare al meglio la sezione bus

Il modo più efficace di usare questa funzione è aprire l'app la mattina prima di uscire di casa, verificare il countdown del prossimo bus, e pianificare l'uscita di conseguenza. Tenendo presente che il bus potrebbe essere in anticipo o in ritardo rispetto all'orario programmato (cosa che l'app non può sapere), è sempre consigliabile arrivare alla fermata qualche minuto prima dell'orario indicato.

Se stai controllando gli orari per il ritorno a casa, ricorda che le corse del pomeriggio potrebbero avere una frequenza diversa da quelle del mattino: scorri l'intera lista per avere un quadro completo delle corse disponibili.

Quando Cotral modifica gli orari stagionali (tipicamente a settembre per l'inizio dell'anno scolastico e a giugno per la fine), gli orari nell'app potrebbero non essere aggiornati fino alla pubblicazione di una nuova versione dell'APK. In questi periodi, è consigliabile verificare gli orari anche sul sito ufficiale di Cotral o all'Autostazione.

---

## 9. Informazioni sulla scuola

La sezione informazioni dell'ITIS è accessibile direttamente dalla schermata principale e raccoglie i riferimenti ufficiali dell'istituto. Si tratta di dati statici che non richiedono connessione a Internet.

### Dati di contatto dell'istituto

La **Sede Centrale** dell'ITIS E. Majorana si trova in Via S. Angelo, 2 (Loc. Folcara) — 03043 Cassino (FR). La **Sede Succursale** è situata in Via S. Angelo (Loc. Folcara) — 03043 Cassino (FR), nella stessa zona. Questo è anche il punto di destinazione della funzione di navigazione GPS: quando avvii la navigazione, l'app ti guiderà automaticamente verso la sede centrale dell'istituto.

Il **centralino** è raggiungibile al numero 0776 312302. L'**indirizzo email istituzionale** è `frtf020002@istruzione.it`, mentre per le comunicazioni formali che richiedono valore legale è disponibile la **Posta Elettronica Certificata (PEC)** all'indirizzo `frtf020002@pec.istruzione.it`.

### Collegamento al sito ufficiale

Toccando il link al sito web nella sezione informazioni, il browser del tuo dispositivo aprirà direttamente `itiscassino.edu.it`. Il sito ufficiale dell'istituto è il luogo dove trovare comunicazioni ufficiali, circolari, il calendario scolastico, informazioni sulle attività extracurriculari, l'accesso al registro elettronico e tutte le news riguardanti la scuola. ITIS Navigator non sostituisce il sito ufficiale per queste funzioni: fornisce solo il collegamento rapido per raggiungerlo in un tocco.

---

## 10. Utilizzo offline e connettività

ITIS Navigator è progettata per essere funzionale in diverse condizioni di connettività, con alcune funzioni che richiedono Internet e altre che funzionano completamente offline.

### Cosa funziona senza connessione

La sezione **orari bus** è completamente offline: gli orari sono inclusi nel pacchetto dell'app e non richiedono alcuna connessione per essere visualizzati. Anche il countdown funziona offline, poiché si basa sull'orologio del dispositivo. Le **informazioni sulla scuola** (indirizzo, email, numero di telefono) sono anch'esse dati statici accessibili senza Internet, anche se il link al sito web ovviamente richiede connessione per caricare la pagina. L'**orologio e la data** nella Home non richiedono Internet.

### Cosa richiede connessione

Il **meteo** richiede Internet per scaricare i dati in tempo reale dalla stazione LAZ543. Senza connessione, l'app mostrerà automaticamente i dati simulati realistici come descritto nel capitolo 7. La **navigazione GPS** richiede Internet per caricare le tessere della mappa di Google e per calcolare il percorso tramite OpenRouteService. Il GPS del telefono funziona anche offline (il segnale satellitare non passa per Internet), ma la mappa visualizzata e il calcolo del percorso richiedono connessione. Se hai già aperto la schermata di navigazione con la connessione attiva e poi perdi il segnale, la mappa potrebbe mostrare solo la porzione già scaricata in cache.

### Consigli per la connettività in mobilità

Se usi dati mobili, tieni presente che il caricamento della mappa di Google può consumare una quantità apprezzabile di dati, specialmente se scorri molto la mappa o zoomi avanti e indietro. Per un uso quotidiano standard (avviare la navigazione da un punto fisso all'ITIS e lasciarla girare), il consumo è comunque contenuto e non dovrebbe rappresentare un problema con la maggior parte dei piani dati.

---

## 11. Risoluzione dei problemi

Questa sezione raccoglie i problemi più comuni che potresti incontrare durante l'uso di ITIS Navigator, con le relative soluzioni dettagliate.

### Problemi di installazione

**L'APK non si installa e compare un messaggio di errore "App non installata"**
Questo errore può avere diverse cause. La più comune è che sul dispositivo è già installata una versione più vecchia o più nuova dell'app e si sta cercando di installare una versione incompatibile. Prova a disinstallare prima la versione precedente dall'elenco delle app di sistema, poi reinstalla l'APK. Se l'errore persiste, verifica che il file APK sia stato scaricato completamente (controlla che non sia corrotto provando a riscaricare).

**Android dice che l'app è "danneggiata" o "potenzialmente pericolosa"**
Android mostra questi avvisi per qualsiasi app installata al di fuori del Play Store, indipendentemente dalla sua sicurezza reale. Si tratta di un avviso precauzionale di sistema, non di un rilevamento di malware. Se il file APK proviene dalla scuola o dal repository GitHub ufficiale dello sviluppatore (`github.com/christianm08/itis-navigator`), puoi procedere tranquillamente con l'installazione.

### Problemi con la navigazione GPS

**La mappa non si carica o appare grigia**
Il problema è quasi certamente la connessione a Internet. Verifica di essere connesso al Wi-Fi o di avere dati mobili attivi e che il segnale sia sufficiente. Se sei connesso ma la mappa non carica, prova a chiudere e riaprire l'app.

**La mia posizione sulla mappa è sbagliata o imprecisa**
Il GPS ha bisogno di qualche secondo (a volte anche un minuto) per acquisire un segnale preciso, specialmente subito dopo aver acceso il telefono o dopo essere uscito da un edificio. Attendi qualche secondo all'aperto prima di avviare la navigazione. Nelle impostazioni del telefono, verifica che la modalità di localizzazione sia impostata su "Alta precisione" (GPS + Wi-Fi + rete mobile) anziché solo "Risparmio batteria" (che usa solo la rete mobile e il Wi-Fi, ed è molto meno precisa).

**La navigazione non parte e l'app chiede il permesso alla posizione**
Hai negato il permesso alla posizione in precedenza. Per ripristinarlo, vai in **Impostazioni Android → App → ITIS Navigator → Autorizzazioni → Posizione** e seleziona "Consenti solo durante l'uso dell'app".

**Le indicazioni passo-passo non corrispondono alla strada su cui mi trovo**
Potrebbe essere dovuto a un ritardo nel ricalcolo del percorso dopo che hai preso una deviazione. Attendi qualche secondo: l'app rileverà che ti sei allontanato dal percorso originale e ricalcolerà automaticamente un nuovo itinerario dalla tua posizione aggiornata.

### Problemi con il meteo

**I dati meteo non si aggiornano**
Verifica di avere una connessione a Internet attiva. Se la connessione è presente ma i dati sembrano vecchi, prova a chiudere la schermata meteo e riaprirla, oppure chiudi e riapri l'app. Se il problema persiste, potrebbe esserci una temporanea indisponibilità della stazione LAZ543: in questo caso l'app mostrerà automaticamente dati simulati.

**L'app mostra "dati simulati" invece di quelli reali**
Significa che la stazione LAZ543 non è raggiungibile in quel momento, a causa di manutenzione, problemi di connettività della stazione stessa, o assenza di Internet sul tuo dispositivo. Controlla prima la tua connessione; se è attiva, la stazione potrebbe essere temporaneamente offline. Riprova tra qualche minuto.

### Problemi con gli orari bus

**Gli orari mostrati non corrispondono a quelli del tabellone reale**
Questo può succedere quando Cotral ha modificato i propri orari stagionali dopo la pubblicazione dell'ultima versione dell'APK. Controlla se è disponibile una versione aggiornata dell'app. Nel frattempo, verifica gli orari direttamente sul sito di Cotral o al tabellone fisico della fermata.

**Non trovo la mia fermata nell'elenco**
L'app include le fermate principali della zona di Cassino più vicine all'ITIS. Se la tua fermata abituale non è presente, usa la fermata più vicina disponibile nell'elenco oppure consulta direttamente il sito Cotral per le corse specifiche.

**Il countdown mostra un valore negativo o strano**
Significa che l'orologio del tuo dispositivo Android non è sincronizzato correttamente con l'ora reale. Vai in **Impostazioni → Gestione generale (o Sistema) → Data e ora** e attiva **Data e ora automatiche** per sincronizzare l'orologio con i server di rete.

### Problemi generali

**L'app si chiude inaspettatamente (crash)**
Prova a chiudere l'app dalle app recenti (tasto quadrato o gesto di swipe dal basso) e riavviarla. Se il problema persiste, prova a spegnere e riaccendere il telefono. Se continui ad avere crash ripetuti, segnala il problema agli sviluppatori attraverso la pagina GitHub del progetto, descrivendo cosa stavi facendo quando l'app si è chiusa e il modello del tuo telefono.

**L'app consuma molta batteria**
Il consumo di batteria di ITIS Navigator è generalmente contenuto. La funzione che incide di più è la **navigazione GPS attiva**, che mantiene il GPS acceso continuamente. Se non stai navigando, assicurati di essere uscito dalla schermata di navigazione e di trovarti sulla Home: la Home consuma molto meno. Se noti comunque un consumo anomalo in background, vai in **Impostazioni → Batteria → Ottimizzazione batteria** e aggiungi ITIS Navigator all'elenco delle app ottimizzate.

---

## 12. Domande frequenti (FAQ)

**L'app è gratuita?**
Sì, ITIS Navigator è completamente gratuita. Non contiene pubblicità, non richiede abbonamenti e non ha acquisti in-app. È un progetto sviluppato da due studenti dell'ITIS a beneficio della comunità scolastica.

**ITIS Navigator è sicura? Raccoglie dati personali?**
L'app non raccoglie, non trasmette e non conserva dati personali degli utenti. Non richiede registrazione, non ha un account, e non conosce la tua identità. I dati di posizione vengono usati esclusivamente in tempo reale per il calcolo del percorso e non vengono mai salvati o inviati a server esterni in forma associata alla tua persona. Il codice sorgente è pubblicamente disponibile su GitHub e chiunque può verificarlo.

**Perché l'app non è sul Play Store?**
La pubblicazione sul Play Store richiede una procedura di verifica da parte di Google e il pagamento di una quota annuale per gli sviluppatori. Trattandosi di un progetto studentesco non commerciale, l'app viene distribuita direttamente tramite APK, che è un metodo perfettamente valido per applicazioni destinate a una comunità specifica.

**Posso usare ITIS Navigator su un tablet Android?**
Sì, l'app funziona su qualsiasi dispositivo Android 5.0 o superiore, inclusi i tablet. L'interfaccia potrebbe non essere ottimizzata per schermi molto grandi (è progettata principalmente per smartphone), ma tutte le funzioni sono disponibili e utilizzabili.

**Gli orari del bus sono aggiornati?**
Gli orari nell'app corrispondono al tabellone ufficiale Cotral valido al momento del rilascio dell'ultima versione dell'APK. Cotral tipicamente modifica i propri orari a settembre (inizio anno scolastico) e a giugno (fine anno scolastico). Lo sviluppatore si impegna a rilasciare versioni aggiornate dell'app in corrispondenza di questi cambiamenti, ma in caso di dubbio è sempre consigliabile verificare anche sul sito ufficiale di Cotral.

**Posso usare la navigazione anche se sono già a Cassino ma non conosco il percorso a piedi?**
Assolutamente sì. La navigazione funziona da qualsiasi punto della mappa, che tu sia in auto, in bus, o a piedi. Se sei in centro a Cassino e vuoi sapere come raggiungere la scuola a piedi, avvia la navigazione e segui le indicazioni: l'app si adatterà al tuo movimento.

**Il meteo mostrato è una previsione o una misurazione?**
È una **misurazione in tempo reale**, non una previsione. I dati che vedi sono quelli rilevati in questo momento dagli strumenti fisici della stazione LAZ543 installata all'ITIS. Non si tratta di previsioni per le prossime ore, ma delle condizioni attuali nel momento in cui guardi l'app.

**Chi posso contattare se trovo un bug o voglio suggerire una funzione?**
Puoi segnalare problemi o suggerire nuove funzionalità aprendo una "Issue" sulla pagina GitHub del progetto all'indirizzo `github.com/christianm08/itis-navigator`. Gli sviluppatori sono studenti dell'ITIS e seguono attivamente il progetto.

---

## 13. Crediti, licenze e informazioni tecniche

### Gli sviluppatori

ITIS Navigator è stato ideato e sviluppato da **Christian Mascio** (GitHub: [@christianm08](https://github.com/christianm08)) e [@Vincenzo Riccio](https://github.com/V1ns533), entrambi studenti dell'ITIS E. Majorana di Cassino. Il progetto nasce come iniziativa degli studenti con l'obiettivo di creare uno strumento concreto e utile per la comunità scolastica dell'istituto, dimostrando al contempo le competenze di sviluppo mobile acquisite durante e oltre il percorso scolastico.

### Tecnologia

L'app è sviluppata con **Flutter**, il framework open source di Google per la creazione di applicazioni mobile multipiattaforma usando il linguaggio Dart. Flutter permette di scrivere il codice una sola volta e compilarlo sia per Android che per iOS, garantendo un'interfaccia fluida e reattiva su tutti i dispositivi compatibili.

### Codice sorgente

ITIS Navigator è un progetto **open source**. Il codice sorgente completo è disponibile pubblicamente su GitHub all'indirizzo `github.com/christianm08/itis-navigator` ed è distribuito sotto **licenza MIT**, che permette a chiunque di visualizzarlo, usarlo, modificarlo e redistribuirlo liberamente, anche per scopi commerciali, a condizione di mantenere l'attribuzione all'autore originale.

### Servizi e dati di terze parti

L'app si avvale di diversi servizi esterni per fornire le proprie funzionalità.

**Google Maps Platform** fornisce la visualizzazione delle mappe interattive e il posizionamento GPS nella schermata di navigazione. Google Maps è il servizio di mappe più diffuso al mondo e garantisce dati stradali accurati e aggiornati per la zona di Cassino.

**OpenRouteService** è il motore di routing usato per calcolare il percorso ottimale e generare le indicazioni passo-passo. È un servizio open source basato su dati OpenStreetMap, disponibile gratuitamente per usi non commerciali.

**MeteoNetwork** è la rete di stazioni meteorologiche amatoriali e scolastiche italiane alla quale appartiene la stazione LAZ543. I dati meteo vengono recuperati tramite le API di MeteoNetwork e sono distribuiti sotto licenza **CC-BY 4.0 (Creative Commons Attribution)**, il che significa che sono liberamente consultabili e riutilizzabili citando la fonte MeteoNetwork e il codice stazione LAZ543.

**Cotral S.p.A.** è l'azienda di trasporto pubblico regionale del Lazio che gestisce le linee di autobus che servono Cassino. Gli orari integrati nell'app si basano sui tabelloni ufficiali pubblicati da Cotral.

### Contatti dell'istituto

**ITIS E. Majorana — Cassino**

Sede Centrale: Via S. Angelo, 2 (Loc. Folcara) — 03043 Cassino (FR)
Sede Succursale: Via S. Angelo (Loc. Folcara) — 03043 Cassino (FR)
Centralino: 0776 312302
Email istituzionale: frtf020002@istruzione.it
PEC: frtf020002@pec.istruzione.it
Sito web: [itiscassino.edu.it](https://itiscassino.edu.it/)

---

*Documentazione redatta per ITIS Navigator — Versione 1.0*
*ITIS E. Majorana, Cassino (FR)*
*Sviluppato con Flutter da Christian Mascio e Vincenzo Riccio*
