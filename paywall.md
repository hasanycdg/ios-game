# Käufe und Paywalls – Regiere Deutschland

Stand: 18. Oktober 2026. Alle drei Apple-Produkte sind dauerhafte Einmalkäufe
(Non-consumables). Es gibt kein Abonnement und keine automatische Verlängerung.

## Produkte und Zugangsrechte

| Inhalt | Apple-Produkt-ID | RevenueCat-Entitlements | DE/AT | CH |
|---|---|---|---|---|
| Hauptkampagne 2005–2026 und bestehende Pro-Funktionen | `regiere_deutschland_one_time` | `Regiere Deutschland Pro` | 4,99 € | CHF 3 |
| Erweiterung Zukunft 2050 | `regiere_deutschland_one_time_two` | `zukunft_2050` | 6,99 € | CHF 5 |
| Komplettpaket 2005–2050 | `regiere_deutschland_complett_packet_one` | beide Entitlements | 9,99 € | CHF 8 |

Preise aus dem tatsächlichen App Store gelesen; bestehende Preise und
Verfügbarkeiten wurden nicht verändert. Die neuen Produkte sind in Deutschland,
Österreich und der Schweiz verfügbar. Die Hauptkampagne bleibt weltweit verfügbar.

Der Prolog 2000–2004 bleibt kostenlos. `CampaignAccess` berechnet den Zugriff:
Pro allein bis 2026, Pro zusammen mit Zukunft bis 2050. Zukunft allein genügt
nicht, weil die Erweiterung dieselbe historische Kampagne fortsetzt. Das
Komplettpaket gewährt deshalb beide Rechte. Der Kauf der Erweiterung gewährt
kein Pro-Recht.

## RevenueCat-Konfiguration

Projekt `proj4cc080a0`, Apple-App `app3a2551c0d6`.

| Offering | Package-ID im SDK | Apple-Produkt |
|---|---|---|
| `katalog_1_6` | `$rc_lifetime` | Hauptkampagne |
| `katalog_1_6` | `lifetime2` | Zukunft 2050 |
| `katalog_1_6` | `lifetime3` | Komplettpaket |
| `kampagne_2005` | `$rc_lifetime` | Hauptkampagne |
| `kampagne_2005` | `lifetime3` | Komplettpaket |
| `zukunft_2050` | `zukunft_2050` | Zukunft 2050 |
| `zukunft_2050` | `lifetime3` | Komplettpaket |

Mehrere dauerhafte Produkte können in einem Offering stehen. Nur ein Package
verwendet den reservierten Typ `$rc_lifetime`; die übrigen haben eigene
Package-Identifiers. Die vorhandenen Identifiers wurden beibehalten.

Der alte RevenueCat-Test-Store-Artikel `lifetime` bleibt nur am Hauptpaket.
Seine falschen zusätzlichen Zuordnungen zu Zukunft und Komplettpaket wurden
entfernt: Er gewährt ausschließlich Pro und kann diese beiden Käufe nicht
simulieren. Die Apple-Produkte und lokalen StoreKit-Testprodukte sind für
alle drei Pakete getrennt eingerichtet.

## Drei Paywalls nach Einstieg

| Einstieg | Offering | Auswählbare Käufe | Vorauswahl |
|---|---|---|---|
| Startseite: „Kampagnen & Pakete“ → „Alle Angebote ansehen“ | `katalog_1_6` | Hauptkampagne, Zukunft, Komplettpaket | Komplettpaket |
| Nach Prolog 2000–2004 / beim Einstieg 2005 | `kampagne_2005` | Hauptkampagne 2005–2026 oder Komplettpaket | Komplettpaket |
| Nach dem Hauptkampagnen-Finale 2026 | `zukunft_2050` | Zukunft 2026–2050 oder Komplettpaket | Zukunft |

- [Startseite: alle drei Angebote](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw7ebcfec35507450e/builder).
- [Nach dem Prolog: Hauptkampagne oder alles](https://app.revenuecat.com/projects/4cc080a0/paywalls/pw4489ba3e84f64892/builder).
- [Nach 2026: Zukunft oder alles](https://app.revenuecat.com/projects/4cc080a0/paywalls/pwe75b9ecb204b4fe0/builder).

Die drei Paywalls wurden nach ausdrücklicher Bestätigung am 20. Oktober 2026
veröffentlicht. Der neue Katalog wurde aus dem geprüften Entwurf in ein eigenes
Offering `katalog_1_6` kopiert. Ältere App-Versionen verwenden weiterhin
`default1` und dessen bisherige veröffentlichte Paywall. Die neuen Offerings
werden nicht als Current markiert; die App wählt jeden Kaufpunkt ausdrücklich
über seinen Identifier.

Die Startseite zeigt eine zentrale Kaufkarte statt separater Hauptkampagnen-,
Zukunfts- und Pro-Verkaufsflächen. Das gesperrte Pro-Feature „eigene Partei“
verwendet die Hauptkampagnen-Paywall, weil nur Hauptkampagne oder Bundle es
freischalten. Es gibt keinen kostenlosen Zukunfts-Testzugang in der App.

Dunkler Hintergrund, Goldakzente und ein türkisfarbener Kaufbutton verbinden
alle drei Ansichten. Jede Paketkarte zeigt ihren eigenen dynamischen Preis.
Die Zukunfts-Erweiterung ist im Katalog mit „Benötigt Hauptkampagne“ markiert.
Nach 2026 ist die Erweiterung vorausgewählt; beim Bundle steht ausdrücklich,
dass die bereits gekaufte Hauptkampagne enthalten ist und frühere Käufe
keinen Preisabzug bewirken. Es gibt keine automatische Bundle-Anrechnung.
Keine Aussage verspricht alle künftig erscheinenden Erweiterungen kostenlos.

Preise kommen über `{{ product.price }}` aus StoreKit. Die App liefert
`bundle_saving` und `show_bundle_saving` nur bei vergleichbaren Währungen und
positiver Ersparnis und ohne bereits gekaufte Hauptkampagne. Am Kaufpunkt
nach 2026 bleibt der Rabatt ausgeblendet. Ein Erstkäufer spart in DE/AT
1,99 € gegenüber beiden Einzelkäufen; bei CHF 3 + CHF 5 = CHF 8 wird kein
Rabatttext eingeblendet. Musterpreise in der Editor-Vorschau sind kein Beleg für
reale Storepreise und dürfen nicht als echte Kauf-Screenshots eingereicht werden.

- Wiederherstellen: RevenueCat-Aktion `restore_purchases`.
- Datenschutz: https://regieredeutschland-support.lovable.app/datenschutz
- Nutzungsbedingungen: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
- Schließen jederzeit möglich.

`CampaignPaywallView(placement:)` verwendet RevenueCatUI und reagiert auf
Kauf-/Restore-Callbacks sofort mit dem aktuellen `CustomerInfo`.
`CampaignAccess.continuationFinalYear` verlängert denselben Spielstand bis
zum gekauften Ende: vom Prolog mit Hauptkampagne bis 2026, mit Bundle direkt
bis 2050; vom Hauptkampagnen-Finale mit Zukunft oder Bundle bis 2050.
RevenueCatUI führt die Transaktion aus; kein zweiter Kaufaufruf im Callback.
Fehlende Offerings oder noch nicht veröffentlichte Paywalls zeigen einen
verständlichen Fehlerzustand mit erneutem Laden, keine automatisch erzeugte
Ersatz-Paywall mit anderen Angeboten.

## Validierung vor Veröffentlichung

- Core-Tests für Zugriff, Paket-Ersparnis und den Spielverlauf ausführen.
- Nach Veröffentlichung der Entwürfe alle drei Paywalls im echten SDK prüfen,
  einschließlich kleiner iPhones und iPad.
- Sandbox: Hauptkampagne, Add-on nach Hauptkauf, Komplettpaket, Abbruch und
  Wiederherstellung mit passendem Zugriff testen.
- Echte Kaufansichten mit korrekten Storepreisen für den Apple-Review aufnehmen.
- Die beiden Kaufpunkt-Entwürfe enthalten deutsche Texte, ihr Standardschlüssel
  steht derzeit auf `en_US`; der Prolog-Entwurf hat zusätzlich `de_DE`.
  Im Dashboard Deutsch als Standard setzen.

`RegiereDeutschland.storekit` enthält alle drei tatsächlichen Produkt-IDs und
ist im Run-Scheme hinterlegt. Lokale StoreKit-Tests allein ersetzen keine
Verifikation des RevenueCat-Entitlements im Sandbox-Kauf.

### Spielbare Szenarien im Zukunftspaket

Der bestehende Kaufzugang schaltet zusätzlich drei verbundene Kapitel frei:

| Zeitraum | Kapitel | Entscheidungen und Folgen |
|---|---|---|
| 2026–2034 | Der Weg zum dritten Weltkrieg | Diplomatie, Versorgung und Rüstungskontrolle; der Weltkrieg kann verhindert werden. |
| 2035–2042 | Wiederaufbau und was danach kommt | Kriegsfolgen oder friedliche Erneuerung, Finanzierung, Versöhnung und demokratische Kontrolle. |
| 2043–2050 | Die neue Weltordnung | Gemeinsame Regeln, Machtblöcke oder nationale Distanz mit jeweils eigenem Finale. |

`Future2050Scenarios.json` ergänzt die bisherigen 75 Zukunftsereignisse um
227 Ereignisvarianten mit insgesamt 681 Antwortoptionen. Pro vollständigem
Durchlauf werden **200 Szenarioentscheidungen** gespielt: acht pro Jahr von
2026 bis 2050, mit jeweils drei Antwortmöglichkeiten. Davon gehören 72 zum
ersten Kapitel und jeweils 64 zu Wiederaufbau und Weltordnung. Zusammen mit den
75 bisherigen Zukunftsereignissen sind es **275 Entscheidungen** im Add-on.

Die acht Schritte bleiben in fester Reihenfolge erhalten. Kriegs- und
Friedensvarianten werden nach jeder Entscheidung anhand des aktuellen Verlaufs
neu ausgewählt; keine Zufallsauswahl kürzt diese Ketten. Zusätzliche Ereignisse
werden danach gespielt. Die historische Bilanz 2026 wird vor dem Einstieg in
die fiktive Handlung ausgespielt; das Finale 2050 folgt erst auf die sieben
vorbereitenden Schlussentscheidungen. Der jährliche Fortschritt wird angezeigt.

Frühere Entscheidungen beeinflussen spätere Schritte über 32 verknüpfte
Detailentscheidungen, zusätzliche Modifier an den großen Wendepunkten und
20 neue verzögerte Investitionsfolgen. Dazu zählen Schutzplanung,
Evakuierung, transparente Auftragsvergabe, Ausbildung, Entschädigung,
Netzresilienz, verbindliche Finanzierung und die öffentliche Schlussbilanz.

Szenarioflags, verzögerte Folgen und Entscheidungen bleiben im normalen
Spielstand gespeichert. Alle Szenarioereignisse sind als Fiktion gekennzeichnet
und verwenden dasselbe Entitlement `zukunft_2050`; es gibt keine zusätzlichen
Einzelkäufe für die drei Kapitel.


### Kostenpflichtige Zukunftserweiterung

Der kostenlose Zukunftstest wurde auf Nutzerwunsch vollständig aus der App
entfernt, einschließlich des Debug-Einstiegs, des Startmodus und des gesonderten
Speicherzugangs. Auf der Startseite ist nur der Prolog bis zur Grenze 2005
kostenlos; die Hauptkampagne ab 2005 und Zukunft 2050 benötigen die passenden
Käufe. Direkte Szenario-Startfunktionen im Core dienen nur automatisierten
Entwicklungstests und sind in der App nicht erreichbar.
