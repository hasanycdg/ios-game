# Release-Vorbereitung 1.6 (Build 2)

Stand: 20. Oktober 2026. Es wurde kein Build hochgeladen und keine Apple-Prüfung
angefordert. Die drei Paywalls für Version 1.6 sind ausdrücklich freigegeben
und veröffentlicht.

## Aktueller Prüfstand vom 20. Oktober

- Produktplan `b7d0ad9c-b5f2-4857-a934-03f1946f74fc` nach ausdrücklicher
  Bestätigung angewendet: beide Produkte `apply_status: applied`.
- Frischer Apple-Store-State bestätigt deutsche Anzeigenamen, Beschreibungen,
  englische Prüfanmerkungen und `READY_TO_SUBMIT`. Preise und AT/CH/DE bleiben
  unverändert. Die internen Referenznamen werden beim frischen Lesen weiterhin
  als `one_time_buy_two` und `complett_packet_one` zurückgegeben.
- Beide Prüfbilder sind leere RevenueCat-Platzhalter (gleiche Prüfsumme
  `169d482b4de5ea044be2d4298c23a92e`), keine fertigen Review-Unterlagen.
- 103 Core-Tests erfolgreich. Neuer Regressionstest prüft Fortsetzung desselben
  Spielstands nach Bundle-Kauf an beiden Grenzen 2004 und 2026.
- Erforderlicher UserDefaults-Zugriff (`CA92.1`) im App-Datenschutzmanifest
  ergänzt; Manifest-Lint und Signaturprüfung erfolgreich.
- Signiertes Archiv und App-Store-IPA für 1.6 / Build 2 erfolgreich erstellt:
  `/tmp/regiere-deutschland-release-20261020/RegiereDeutschland-Final.xcarchive`
  und `/tmp/regiere-deutschland-release-20261020/export/RegiereDeutschland.ipa`.
  **Diese erste IPA enthält die danach gewünschte Update-Erinnerung noch nicht.**
- Update-Erinnerung implementiert; Debug-Simulatorbuild ohne Warnungen
  erfolgreich. Neues Release-Archiv und Laufzeittest werden separat geprüft.
- Kostenloser Zukunftstest auf erneuten Nutzerwunsch vollständig aus der App
  entfernt, einschließlich Debug-Startseite und Startmodus. Prolog kostenlos
  bis zur Grenze 2005; Hauptkampagne ab 2005 und Zukunftserweiterung bezahlt.
- Drei Paywalls nach ausdrücklicher Bestätigung am 20. Oktober veröffentlicht:
  Katalog `pw7ebcfec35507450e` Revision 1, Prolog `pw4489ba3e84f64892`
  Revision 3, Zukunft `pwe75b9ecb204b4fe0` Revision 6. Alle validiert.
- Der neue Katalog verwendet ausschließlich Offering `katalog_1_6`
  (`ofrngdab52df28c`). Er ist nicht Current. Bereits veröffentlichte ältere
  App-Versionen behalten ihr Offering `katalog_1_6` und dessen bisherige Paywall.
- Die native Simulator-Steuerung brach mit „native pipe closed“ ab und ließ
  sich bisher nicht wieder verbinden. Zustellung und Antippen der Erinnerung
  sind damit noch nicht als Laufzeittest bestätigt.
- Acht vorhandene App-Store-Screenshots sind in Version 1.6 weiterhin sichtbar.
- Die bedingte Erlaubnis zum Upload und zur Apple-Einreichung liegt vor, sobald
  alle erforderlichen Prüfungen und Review-Unterlagen vollständig sind.

## Einmalige Update-Erinnerung

Die vom Nutzer gewählte Variante ist eine lokale Erinnerung nach dem ersten
Öffnen der neuen Version, keine entfernte Push-Kampagne beim Installieren.

- Nach dem Onboarding wird eine verständliche Opt-in-Karte angeboten.
- iOS-Mitteilungserlaubnis wird erst nach Tippen auf „Einmal erinnern lassen“
  angefragt. Ablehnen oder „Nicht jetzt“ beendet das Angebot ohne neue Anfrage.
- Mit vorhandener Erlaubnis wird direkt einmalig geplant: nach 60 Sekunden,
  keine Wiederholung, kein Badge. Bei aktiver App nur in der Mitteilungszentrale.
- Kennung `future2050.update.1.6`; ein persistenter Abschlusswert verhindert
  wiederholtes Senden bei Neustarts oder weiteren Builds desselben Inhalts.
  Fehlgeschlagene Planung bleibt wiederholbar.
- Text: „Bereit für die Zukunft?“ / „Neue fiktive Weltkrisen, Wiederaufbau und
  Weltordnung: Entdecke Zukunft 2050 in Regiere Deutschland.“
- Antippen öffnet die Übersicht „Zukunft 2050“. Bestehende Zugangsrechte bleiben
  maßgeblich: Fortsetzen bei Besitz beider Kampagnen, sonst passende Angebote.
  Eine zuvor offene Spielansicht wird geschlossen, bevor derselbe Spielstand
  erneut geöffnet werden kann.
- iOS-Fokus, Mitteilungseinstellungen und geplante Zusammenfassungen können die
  tatsächliche Anzeige verzögern oder unterdrücken.

## Bereits gespeichert

- App Store Connect: iOS-Version 1.6 als Entwurf, deutsche Beschreibung,
  Werbetext, Neuerungen, Support-URL und Prüfanmerkungen.
- Manuelle Veröffentlichung der App-Version eingestellt.
- RevenueCat: bestehende Apple-Produkte weiterverwendet, klare interne Namen,
  Entitlements und Packages zugeordnet. Zukunft allein gewährt kein Pro;
  das Komplettpaket gewährt Pro und Zukunft.
- Drei konkrete Einstiege: Startseite `katalog_1_6` mit allen drei Paketen,
  nach Prolog `kampagne_2005` mit Hauptkampagne und Bundle, nach 2026
  `zukunft_2050` mit Erweiterung und Bundle.
- Startseite auf eine gemeinsame Karte „Kampagnen & Pakete“ reduziert.
- Falsche Zuordnung des alten Test-Store-Produkts `lifetime` zu Zukunft und
  Komplettpaket entfernt. Dieser alte Testartikel simuliert nur das Hauptpaket;
  Apple-Sandbox und lokale StoreKit-Datei verwenden die drei echten Produkt-IDs.
- Haupt-Paywall mit drei auswählbaren Paketen (Hauptkampagne, Zukunft,
  Komplettpaket); Zukunft ist als Erweiterung mit Voraussetzung gekennzeichnet.
- Drei gestaltete Paywall-Entwürfe mit dynamischen StoreKit-Preisen,
  Wiederherstellen, Schließen und echten Datenschutz-/EULA-Links gespeichert.
- Bundle-Kauf verlängert denselben Spielstand vom Prolog direkt bis 2050;
  die Fortsetzung hängt nicht von der Reihenfolge einzelner Entitlement-Callbacks ab.
- App: tatsächliche Produkt-IDs, Zugangsrechte, Kauf-/Restore-Callbacks,
  lokalisierte positive Paket-Ersparnis, StoreKit-Testprodukte angepasst.
- Xcode-Version 1.6, Build 2. Kein kostenloser Zukunftstest in der App.

## Preise aus App Store Connect

Alle drei Packages stehen gemeinsam im Offering `katalog_1_6` und sind im
Haupt-Paywall-Entwurf auswählbar. Die gespeicherte Komponenten-Konfiguration
wurde auf genau diese drei Bindungen geprüft; `lifetime3` ist vorausgewählt.

| Package-Identifier | Apple-Produkt-ID | Freigeschalteter Inhalt |
|---|---|---|
| `$rc_lifetime` | `regiere_deutschland_one_time` | Hauptkampagne 2005–2026 und Pro |
| `lifetime2` | `regiere_deutschland_one_time_two` | Zukunft 2026–2050; benötigt Hauptkampagne |
| `lifetime3` | `regiere_deutschland_complett_packet_one` | Beide Kampagnen, beide Entitlements |

| Produkt | Deutschland / Österreich | Schweiz |
|---|---|---|
| Hauptkampagne | 4,99 € | CHF 3 |
| Zukunft 2050 | 6,99 € | CHF 5 |
| Komplettpaket | 9,99 € | CHF 8 |

Die Hauptkampagne ist weltweit verfügbar. Die neuen Produkte sind auf AT/CH/DE
beschränkt. Keine Preise oder Länder wurden geändert.

## Apple-Produktplan – bestätigt und angewendet

Plan `b7d0ad9c-b5f2-4857-a934-03f1946f74fc`, Status `applied`, zwei Produkte geändert,
keine anlegen. Die vollständigen Vorher-/Nachher-Werte stehen in
`store-product-plan-review.json`, die Eingabe in `store-product-desired-state.json`.

| Produkt | Bisheriger Referenzname | Neuer Referenz-/Anzeigename | Neue deutsche Beschreibung |
|---|---|---|---|
| `regiere_deutschland_one_time_two` | `one_time_buy_two` | Zukunft 2050 | Erweitere deine Kampagne von 2026 bis 2050. |
| `regiere_deutschland_complett_packet_one` | `complett_packet_one` | Komplettpaket 2005–2050 | Hauptkampagne und Zukunft 2050 dauerhaft. |

Beide erhalten außerdem englische Prüfanmerkungen: Einmalkauf, Zugangsrechte,
Kauf-/Wiederherstellung über StoreKit/RevenueCat, kein Spielkonto, keine Abos.
Bei Zukunft wird die benötigte Hauptkampagne erläutert, beim Komplettpaket
die Freischaltung beider Kampagnen. Das genehmigte Hauptprodukt bleibt im
Apple Store unverändert.

Zwei Warnungen, jeweils `severity: warning`, Feld
`store_state.review_information.screenshot`: Es fehlt ein Review-Screenshot;
Beim bestätigten Anwenden wurde je Produkt ein leerer Platzhalter hochgeladen.
Diese Platzhalter sind keine fertigen Review-Unterlagen. Vor der Einreichung
müssen echte Screenshots der Kaufansichten eingesetzt werden. Kein Blocker
laut Plan, aber damit noch nicht einreichungsfertig.

[Änderungsplan ansehen](https://app.revenuecat.com/projects/proj4cc080a0/product-catalog/product-editor/review-changes?plan_id=b7d0ad9c-b5f2-4857-a934-03f1946f74fc)

## Vor der Veröffentlichung abschließen

1. Die leeren Review-Platzhalter durch echte Kaufansichten ersetzen.
2. Veröffentlicht sind:
   [Startseite](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw7ebcfec35507450e/builder),
   [Nach Prolog](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw4489ba3e84f64892/builder),
   [Nach 2026](https://app.revenuecat.com/projects/4cc080a0/paywalls/pwe75b9ecb204b4fe0/builder).
   Beide Kaufpunkt-Entwürfe enthalten deutsche Texte unter `en_US`, der
   Prolog-Entwurf zusätzlich `de_DE`; Deutsch als Standard setzen. Editor-Vorschauen zeigen
   teilweise USD-Musterpreise; reale Preise kommen dynamisch aus StoreKit.
3. Alle drei Ansichten im SDK auf iPhone und iPad prüfen; Sandbox-Kauf,
   Kaufabbruch und Restore für Hauptkampagne, Add-on und Komplettpaket testen.
   Die tatsächlich gewährten Entitlements kontrollieren.
4. Echte Screenshots der neuen Kaufansichten für beide neuen Apple-Produkte
   aufnehmen und die leeren Review-Platzhalter ersetzen. Übernommene
   App-Store-Produktscreenshots zusätzlich auf Aktualität prüfen.
5. Das finale signierte Archiv mit Update-Erinnerung fertig prüfen und hochladen; in App Store
   Connect auswählen. Exportfragen anhand des hochgeladenen Builds beantworten.
6. Beide neuen In-App-Käufe mit Version 1.6 zur Apple-Prüfung hinzufügen.
   Upload und Einreichung sind bei vollständiger Bereitschaft durch den Nutzer
   autorisiert; manuelle App-Veröffentlichung bleibt eingestellt.

## Durchgeführte technische Prüfung

- 103 Swift-Core-Tests erfolgreich, einschließlich der vier Zugangs-Kombinationen,
  Währungsvergleich/Ersparnis und Zukunftskampagne.
- Debug-Simulatorbuild erfolgreich. Startseite im Simulator geprüft: eine
  zentrale Kaufkarte mit „Alle Angebote ansehen“, keine separaten Verkaufsflächen.
- Signiertes Release-Archiv und App-Store-Export erfolgreich; Bundle
  `com.regieredeutschland`, Version 1.6 / Build 2 (vor Update-Erinnerung).
- RevenueCat-Offering `katalog_1_6`: Verifikation ohne Katalogprobleme.
- Offerings `katalog_1_6`, `kampagne_2005` und `zukunft_2050`: Paywalls veröffentlicht.
- Alle drei gespeicherten Komponenten-Konfigurationen auf passende Packages,
  Vorauswahl, Schließen und Wiederherstellen geprüft; siehe `paywall-checkpoints.json`.
- Nach 2026 steht beim Bundle „Kein Preisabzug für frühere Käufe“;
  die passende Erweiterung ist vorausgewählt.
- Noch kein Sandbox-Kauf mit den neuen Paywall-Entwürfen verifiziert.
