# REGIERE DEUTSCHLAND – CODEX DEVELOPMENT PLAN

## Grundregel für Codex

Bei jedem Schritt gilt:

* Bestehende Architektur zuerst analysieren.
* Keine Funktionen aus späteren Schritten vorweg implementieren.
* Keine unnötigen Dependencies hinzufügen.
* SwiftUI und moderne Swift APIs verwenden.
* Business-/Game-Logik strikt von UI trennen.
* Game Content datengetrieben halten und nicht hart in Views programmieren.
* Nach jeder Änderung Projekt kompilieren.
* Falls Tests vorhanden sind, Tests ausführen.
* Keine bestehende funktionierende Logik ohne Grund umbauen.

---

# SCHRITT 1 – XCODE-PROJEKT UND GRUNDARCHITEKTUR

Erstelle die technische Basis für ein iOS Mobile Game namens:

"Regiere Deutschland: 2000–2026"

Tech Stack:

* Swift
* SwiftUI
* iOS
* zunächst vollständig offline
* kein Login
* kein Backend
* keine externe Datenbank
* historische Game Events später aus lokalen JSON-Dateien
* Spielstände später lokal speichern

Bitte eine skalierbare Feature-/Domain-Struktur verwenden.

Ungefähr:

RegiereDeutschland/
App/
Game/
Models/
Engine/
Data/
Features/
Home/
Game/
Decision/
Election/
GameOver/
Statistics/
Persistence/
Shared/

Erstelle zunächst nur:

* App Entry Point
* Navigation-Grundstruktur
* Home Screen
* Platzhalter Game Screen

Home Screen:

Titel:
"Regiere Deutschland"

Untertitel:
"2000–2026"

Claim:
"Deutschland seit 2000 – aber diesmal entscheidest DU."

Button:
"Neues Spiel"

Noch keine echte Game-Logik implementieren.

Projekt anschließend kompilieren und eventuelle Fehler beheben.

---

# SCHRITT 2 – GAME STATE MODELL

Implementiere jetzt das zentrale GameState-Modell.

Es soll den aktuellen Zustand Deutschlands im Spiel repräsentieren.

Sichtbare Kernwerte von 0–100:

* economy
* budget
* livingStandard
* society
* security
* energy
* internationalRelations
* trust

Zusätzlich:

* currentYear
* governmentApproval

Versteckte langfristige Variablen:

* renewableCapacity
* nuclearCapacity
* russianEnergyDependency
* defenceReadiness
* digitalization
* infrastructureQuality
* integrationCapacity
* labourMarketFlexibility
* welfareStrength
* healthcareResilience
* euRelations
* usRelations
* russiaRelations
* polarization
* fiscalSpace

Außerdem:

* getroffene Entscheidungen
* bisherige Wahlergebnisse
* aktive langfristige Effekte
* historische Flags

Nutze sinnvolle eigene Types statt alles in Dictionaries zu speichern.

GameState soll Codable sein.

Erstelle eine Factory bzw. Initial-State-Konfiguration für Deutschland im Jahr 2000.

Wichtig:
Die Startwerte müssen später einfach angepasst/balanced werden können.

Noch keine UI für die einzelnen Werte bauen.

Unit Tests für:

* korrekte Initialisierung
* Wertebereich 0–100
* Codable Encode/Decode

---

# SCHRITT 3 – EVENT- UND ENTSCHEIDUNGSMODELL

Baue ein vollständig datengetriebenes Event-System.

Wir wollen NICHT später schreiben:

if year == 2011 { Fukushima }

Stattdessen werden Events aus JSON geladen.

Erstelle Modelle für ungefähr:

GameEvent
DecisionOption
GameEffect
HiddenEffect
DelayedEffect
EventCondition
HistoricalContext

Ein GameEvent braucht mindestens:

* id
* year
* title
* category
* headline
* description
* historicalContext
* options
* optional conditions
* optional followUpEvents

Eine DecisionOption:

* id
* title
* description
* immediateEffects
* hiddenEffects
* optional delayedEffects
* optional flagsToSet

Effekte müssen positive und negative Änderungen erlauben.

Implementiere einen EventRepository, der Events aus lokalen JSON-Dateien laden kann.

Lege eine Datei für 2000 an und füge EIN Testevent ein:

Thema:
"Energiepolitik 2000"

Mit drei Optionen:

1. Erneuerbare Energien stark fördern
2. Bestehenden Energiemix beibehalten
3. Atomkraft langfristig stärken

Verwende zunächst plausible Testwerte. Historische Feinabstimmung erfolgt später.

Tests:

* JSON wird korrekt geladen
* Event wird erkannt
* Optionen werden korrekt decoded
* ungültige JSON-Daten verursachen keinen App-Crash

---

# SCHRITT 4 – GAME ENGINE

Implementiere die zentrale GameEngine.

Die GameEngine soll unabhängig von SwiftUI funktionieren.

Verantwortlichkeiten:

* neues Spiel starten
* aktuellen GameState halten
* aktuelles Event bestimmen
* Option auswählen
* Immediate Effects anwenden
* Hidden Effects anwenden
* Flags setzen
* Entscheidung speichern
* Werte auf gültige Grenzen clampen
* nächstes Event auswählen
* Jahr fortschalten

Keine UI-Logik in GameEngine.

Eine View darf NICHT direkt Dinge machen wie:

state.economy += 5

Alles muss über die Engine laufen.

API ungefähr:

startNewGame()
availableEvents()
choose(option:)
advanceGame()

Bitte so strukturieren, dass später Delayed Effects, Wahlen und Bevölkerungsgruppen problemlos ergänzt werden können.

Unit Tests für verschiedene Entscheidungen erstellen.

---

# SCHRITT 5 – ERSTER SPIELBARER GAME LOOP

Verbinde jetzt SwiftUI mit GameEngine.

Game Screen soll anzeigen:

* aktuelles Jahr
* aktuelle wichtigsten Stats
* aktuelles Event
* Event-Beschreibung
* 2–4 Entscheidungsmöglichkeiten

Nach einer Entscheidung:

* Option wird an GameEngine geschickt
* Stats ändern sich
* kurzer Ergebnis-Screen erscheint
* danach kann der Spieler fortfahren

Noch kein Premium-Design.

Bewusst einfache funktionale UI.

Wichtig:
Der Spieler darf Auswirkungen NICHT bereits vor der Entscheidung exakt als "+5 Wirtschaft" sehen.

Vor der Entscheidung nur qualitative Hinweise wie:

"Der Wirtschaftsminister erwartet positive Wachstumsimpulse."

Nach der Entscheidung dürfen direkte Auswirkungen teilweise sichtbar sein.

Wir wollen zunächst nur das Event aus 2000 vollständig spielbar machen.

---

# SCHRITT 6 – JAHR- UND EVENT-FORTSCHRITT

Erweitere das System so, dass mehrere Events in einem Jahr möglich sind.

Ein Jahr kann:

* 0 Events
* 1 Event
* mehrere Events

haben.

Nach dem letzten Event eines Jahres wird das Jahr abgeschlossen.

Implementiere:

YearProgress
EventQueue
AnnualSimulation

Beim Jahreswechsel können Basisentwicklungen angewendet werden.

Beispiel:
Eine gute Wirtschaft kann sich leicht positiv weiterentwickeln.
Hohe Polarisierung kann society langfristig belasten.

Diese jährlichen Simulationen zunächst sehr konservativ halten.

Erstelle Testevents für:

2000
2001
2003
2004
2005

Die Inhalte dürfen zunächst Dummy-/Prototype-Inhalte sein.

Ziel:
Man kann jetzt von 2000 bis 2005 durchspielen.

---

# SCHRITT 7 – DELAYED EFFECTS UND HISTORISCHE ECHOS

Jetzt implementieren wir eines der wichtigsten Systeme des Games.

Entscheidungen sollen Jahre später Konsequenzen haben können.

Beispiel:

2000:
Erneuerbare stark ausbauen.

Effekt:
renewableCapacity steigt.

Später kann ein Event prüfen:

renewableCapacity > X

und dadurch andere Konsequenzen erzeugen.

Implementiere zwei Arten:

1. ScheduledEffect
   Ein Effekt wird z.B. in 3 Jahren ausgelöst.

2. ConditionalModifier
   Ein späteres Event verändert seine Auswirkungen abhängig von alten Entscheidungen oder Stats.

Beispiel:

Wenn renewableCapacity hoch ist,
dann wirkt eine spätere Energiekrise weniger stark.

Füge "Historical Echo"-Events hinzu.

Beispiel:

"Eine Entscheidung aus dem Jahr 2000 wirkt bis heute nach."

Die Engine soll nachvollziehen können, welche frühere Entscheidung die Ursache war.

Tests für:

* verzögerte Effekte
* Bedingungen
* historische Flags
* mehrere zusammenwirkende Entscheidungen

---

# SCHRITT 8 – BEVÖLKERUNGSGRUPPEN UND BELIEBTHEIT

Implementiere jetzt das Approval-System.

Bevölkerungsgruppen:

* Arbeitnehmer
* Rentner
* Familien
* Junge Erwachsene
* Unternehmer/Selbstständige
* Geringverdiener/Arbeitslose
* öffentlicher Dienst

Jede Gruppe hat:

* populationShare
* approval
* unterschiedliche politische Prioritäten

Beispiel:

Unternehmer reagieren stärker auf:

* Wirtschaft
* Steuern
* Energiepreise

Rentner stärker auf:

* Kaufkraft
* Rente/Sozialstaat
* Sicherheit

Government Approval soll aus mehreren Faktoren berechnet werden:

* Approval der Bevölkerungsgruppen
* aktuelle Lage Deutschlands
* Vertrauen
* kurzfristiges Momentum
* Entscheidungen
* ggf. Krisen

Nicht einfach:
approval += X

Implementiere einen ApprovalEngine-Service.

Beliebtheit soll sich mit der Zeit teilweise normalisieren, damit einzelne Entscheidungen nicht dauerhaft +20 bleiben.

Tests für unterschiedliche Bevölkerungsszenarien.

---

# SCHRITT 9 – POLITISCHES GEDÄCHTNIS

Implementiere Decision Memory.

Die Bevölkerung soll vergangene Entscheidungen teilweise vergessen.

Eine politische Entscheidung hat einen PublicMemoryImpact.

Beispiel Decay:

Jahr 1: 100 %
Jahr 2: ca. 75 %
Jahr 3: ca. 55 %
Jahr 5: ca. 25 %

Aber spätere Ereignisse können Entscheidungen reaktivieren.

Beispiel:

2011 Atompolitik
wird 2022 während einer Energiekrise wieder relevant.

Dann kann ein alter Approval-Effekt erneut teilweise aktiviert werden.

Implementiere dies generisch und datengetrieben.

---

# SCHRITT 10 – WAHL-SYSTEM

Jetzt Bundestagswahlen implementieren.

Für die erste Version noch stark vereinfacht.

Eine Wahl wird in definierten Wahljahren ausgelöst.

Das Wahlergebnis hängt ab von:

* Government Approval
* Wirtschaft
* Lebensstandard
* Vertrauen
* gesellschaftlicher Lage
* kurzfristigem Momentum
* ggf. Skandalen
* einem kleinen Zufallsfaktor

Keine völlig zufälligen Ergebnisse.

Wahl-Screen:

"Bundestagswahl"

Anzeige:

* eigene Partei
* wichtigste Opposition
* Ergebnis in Prozent
* Sieg/Niederlage

Wenn der Spieler gewinnt:
Game geht weiter.

Wenn der Spieler verliert:
RUN ENDET SOFORT.

Game Over:

"Deine Regierung wurde abgewählt."

Anzeigen:

* Regierungsdauer
* erreichte Jahre
* wichtigste Entscheidungen
* wichtigste Stats
* Hauptgründe für die Niederlage
* Regierungsstil

Dann:
"Neues Spiel"

Kein Oppositionsmodus.

---

# SCHRITT 11 – 2000 BIS 2005 ALS KOMPLETTER VERTICAL SLICE

Jetzt KEINE neuen Systeme hinzufügen.

Stattdessen die Jahre 2000–2005 als echtes Mini-Game fertigstellen.

Jedes Jahr soll ausgewählte relevante Events enthalten.

Die Events sollen miteinander verbunden sein.

Ziel:
Ein kompletter Run von 2000 bis zur ersten Wahl.

Wir testen:

* Macht das Entscheiden Spaß?
* Sind Auswirkungen verständlich?
* Gibt es offensichtlich immer eine beste Antwort?
* Funktionieren langfristige Effekte?
* Ist Beliebtheit nachvollziehbar, aber nicht komplett vorhersehbar?
* Ist die Wahl spannend?
* Kann man verlieren?
* Gibt es mehrere sinnvolle Spielweisen?

Balancing durchführen.

Erstelle dafür Debug Tools, mit denen Entwickler:

* GameState sehen
* versteckte Werte sehen
* Jahr überspringen
* Stats verändern
* bestimmte Events triggern

Diese Debug Tools dürfen nur in Debug Builds verfügbar sein.

---

# SCHRITT 12 – SAVEGAME

Implementiere lokale Speicherung.

Kein Account.
Kein Backend.

Speichere:

* GameState
* aktuelles Jahr/Event
* Entscheidungen
* Delayed Effects
* Flags
* Population Approval
* Wahlergebnisse

Autosave nach jeder wichtigen Entscheidung und nach Jahreswechsel.

Home Screen:

"Neues Spiel"
"Fortsetzen"

Wenn kein Save vorhanden ist:
"Fortsetzen" nicht anzeigen.

Zusätzlich mehrere vergangene Run-Ergebnisse lokal speichern:

* Startjahr
* Endjahr
* Grund des Endes
* Score
* Regierungsstil

---

# SCHRITT 13 – VOLLSTÄNDIGE HISTORISCHE GAME-DATEN

Erst jetzt das gesamte Spiel 2000–2026 mit den recherchierten historischen Events befüllen.

WICHTIG:

Keine neue Game-Logik bauen, sofern nicht unbedingt nötig.

Die Game Engine existiert bereits.

Jetzt hauptsächlich:

JSON Events
Conditions
Effects
Delayed Effects
Historical Echoes
Event Chains

Jedes wichtige Event muss enthalten:

* historischen Kontext
* Entscheidung
* 2–4 plausible Optionen
* reale historische Entscheidung
* kurzfristige Game Effects
* versteckte Effekte
* mögliche langfristige Konsequenzen
* Bedingungen für spätere Events

Historische Fakten und alternative Simulation strikt trennen.

Jedes Jahr braucht nur spielwürdige Events.
Nicht jedes historische Ereignis muss ins Game.

Qualität vor Quantität.

---

# SCHRITT 14 – HISTORY COMPARE FEATURE

Nach einer Entscheidung kann optional angezeigt werden:

"Was geschah wirklich?"

Beispiel:

DEINE ENTSCHEIDUNG:
Atomkraft länger nutzen.

HISTORISCHE REALITÄT:
Deutschland beschloss 2011 den beschleunigten Atomausstieg.

Wichtig:
Historische Fakten sind statischer redaktioneller Content.
Alternative Auswirkungen sind Simulation.

Diese beiden Bereiche niemals vermischen.

---

# SCHRITT 15 – ENDSCREEN 2026

Wenn Spieler bis 2026 kommt:

"DEIN DEUTSCHLAND 2026"

Anzeige:

* Wirtschaft
* Haushalt
* Lebensstandard
* Sicherheit
* Gesellschaft
* Energie
* internationale Beziehungen
* Vertrauen

Zusätzlich:

* Regierungsstil
* Regierungsdauer
* gewonnene Wahlen
* wichtigste Entscheidungen
* größter Erfolg
* größte Fehlentscheidung
* größter Butterfly Effect
* stärkste Abweichung von der echten Geschichte

Vergleich:

Historische Realität
vs.
Dein Deutschland

Ergebnis soll als visuell attraktiver Share Screen funktionieren.

---

# SCHRITT 16 – FINAL UI / DESIGN SYSTEM

Erst nachdem der komplette Gameplay-Loop stabil ist:

Implementiere das finale Premium-Design.

Visuelle Richtung:

* hochwertige Mobile Strategy Game UI
* Dark Theme
* Schwarz/Anthrazit
* Gold
* Rot
* dezente deutsche Farbgebung
* moderne Karten
* News/Breaking-News-Elemente
* Timeline
* Charts
* dezente Animationen
* keine Behörden-App-Optik

Screens:

Home
Year Overview
Decision
Decision Result
Historical Echo
Election
Game Over
Statistics
End Report

Business Logic darf bei diesem Schritt NICHT verändert werden.

---

# SCHRITT 17 – BALANCING

Baue Simulations-/Debug-Funktionen, mit denen automatisch viele Runs simuliert werden können.

Wir wollen erkennen:

* Welche Optionen sind objektiv zu stark?
* Welche Entscheidungen werden immer gewählt?
* Wie oft erreicht ein Spieler 2026?
* Wie oft verliert man 2005/2009/etc.?
* Welche Stats driften immer Richtung 0 oder 100?
* Gibt es unbesiegbare Strategien?

Ziel:
Keine einzelne politische Strategie darf automatisch gewinnen.

Jede Strategie muss echte Trade-offs besitzen.

---

# SCHRITT 18 – RELEASE-VORBEREITUNG

Final:

* Crash-Sicherheit
* Accessibility
* iPhone Größen testen
* Dark Mode Konsistenz
* Savegame Migration
* App Lifecycle
* Performance
* Offline-Nutzung
* App Icon
* Launch Screen
* Privacy
* Analytics optional vorbereiten

Noch kein Account und kein Backend hinzufügen, sofern nicht notwendig.
