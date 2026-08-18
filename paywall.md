# Paywall Design — Regiere Deutschland Pro

Design-Spezifikation für die RevenueCat-Paywall (Paywalls v2 Editor). Sie wird
von `PaywallView()` und `.presentPaywallIfNeeded(...)` gerendert und ist im
Dashboard konfiguriert — **kein App-Update** nötig, um sie zu ändern.

- **Produkt:** `Unlimited` — Einmalkauf (non-consumable / lifetime), **kein Abo**
- **Entitlement:** `Regiere Deutschland Pro`
- **Offering:** `default1` (Identifier im Dashboard; im Code via `Monetization.offeringID`)
- **Ton:** Deutsch, informell (du). Selbstbewusst, staatstragend, kein Hype.

---

## 1. Designprinzipien

1. **Ein Angebot, keine Ablenkung.** Nur ein Kauf-Button. Kein Package-Picker,
   keine Fake-Rabatte, kein Countdown. Der Wert trägt, nicht der Druck.
2. **„Einmal zahlen, für immer regieren."** Der Lifetime-Charakter ist das
   stärkste Verkaufsargument — prominent, nicht kleingedruckt.
3. **Look = App.** Anthrazit-Hintergrund, Gold als einziger Akzent, dezenter
   Schwarz-Rot-Gold-Faden. Die Paywall darf sich nicht wie ein Fremdkörper
   anfühlen.
4. **App-Store-konform.** Preis, „Wiederherstellen", Nutzungsbedingungen und
   Datenschutz sind sichtbar — sonst Ablehnung im Review.

---

## 2. Design-Tokens

Direkt aus [`GameTheme.swift`](Sources/RegiereDeutschlandApp/App/GameTheme.swift) übernommen — 1:1 im Editor eintragen.

### Farben
| Rolle | Hex | Verwendung |
|---|---|---|
| Background top | `#0E0F13` | Seitenverlauf oben |
| Background bottom | `#08080B` | Seitenverlauf unten |
| Surface | `#1D2026` | Karten, Feature-Zeilen |
| Surface elevated | `#262930` | Hervorgehobene Karte / Package |
| Gold | `#DBB052` | Primär-Akzent, CTA-Verlauf (unten) |
| Gold bright | `#F5D16B` | CTA-Verlauf (oben), Krone, Highlights |
| Primary text | `#F2F2F7` | Überschriften, Preis |
| Secondary text | `#ADB3C2` | Fließtext, Feature-Beschreibungen |
| Tertiary text | `#7A808F` | Legal-Zeile, Footnotes |
| Green | `#61C77A` | Häkchen der Feature-Liste |
| Flag red | `#C92924` | dünner Flaggen-Faden (optional) |
| Flag gold | `#F5CC33` | dünner Flaggen-Faden (optional) |

- **CTA-Verlauf:** linear, `#F5D16B` → `#DBB052`, oben-links → unten-rechts.
- **CTA-Text:** `#1F1A0D` (fast schwarz, warm) auf Gold — hoher Kontrast.

### Typografie (SF Pro / System, `rounded` wo möglich)
| Element | Größe / Gewicht |
|---|---|
| Titel | 30–34 pt, Heavy, rounded |
| Subhead | 16 pt, Regular |
| Feature-Titel | 16 pt, Semibold |
| Feature-Text | 13 pt, Regular, secondary |
| Preis | 22 pt, Bold, rounded |
| CTA | 17 pt, Bold |
| Legal | 11 pt, Regular, tertiary |

### Form & Abstand
- Ecken: Karten 16–18 pt, CTA 14 pt (continuous).
- Außenrand: 20 pt. Abstand zwischen Blöcken: 20–24 pt.
- Hairline-Rahmen: `#FFFFFF` @ 8 % Deckkraft.

---

## 3. Layout (oben → unten)

```
┌──────────────────────────────────────────┐
│                  [ ✕ ]                     │  Close-Button (oben rechts)
│                                            │
│                  ╭─────╮                   │
│                  │  ♛  │  Krone, Gold      │  Hero-Icon (crown.fill)
│                  ╰─────╯                   │
│           ▬▬▬ schwarz-rot-gold ▬▬▬         │  dünner Flaggen-Faden
│                                            │
│         Regiere ohne Grenzen               │  Titel (Heavy)
│   Schalte alle Inhalte dauerhaft frei.     │  Subhead
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │ ✓  Eigene Partei gründen             │ │  Feature-Zeile (Surface)
│  │ ✓  Alle Schwierigkeitsgrade          │ │
│  │ ✓  Volle Chronik & Statistiken       │ │
│  │ ✓  Keine Limits, keine Werbung       │ │
│  │ ✓  Zukünftige Updates inklusive      │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  Unlimited            {{ price }}     │ │  Package-Karte (elevated)
│  │  Einmalkauf · für immer               │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │
│  ┃   ✦  Jetzt freischalten              ┃ │  CTA (Gold-Verlauf)
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │
│                                            │
│   Wiederherstellen · AGB · Datenschutz     │  Footer-Links (tertiary)
│   Einmalige Zahlung. Kein Abo.             │  Legal-Zeile
└──────────────────────────────────────────┘
```

### Komponenten-Mapping (Paywalls v2)
| Block | Editor-Komponente | Hinweise |
|---|---|---|
| Close | Paywall-Setting „Show close button" | oder `displayCloseButton: true` im Code (bereits gesetzt) |
| Hero-Icon | **Icon** (`crown`) oder **Image** | Gold-Verlauf, ~40 pt, zentriert |
| Flaggen-Faden | **Image** (3-farbiger Balken) | optional, Höhe 4–5 pt, Breite ~150 pt |
| Titel / Subhead | **Text** | siehe Copy-Deck |
| Feature-Liste | **Stack** (vertikal) aus **Icon + Text** Zeilen | Häkchen `checkmark` in Green |
| Package-Karte | **Package**-Komponente | zeigt `{{ product.store_product_name }}` + `{{ product.price }}` |
| CTA | **Purchase Button** | Gold-Verlauf-Hintergrund, Text „Jetzt freischalten" |
| Footer | **Footer**-Komponente | aktiviert Restore + Terms + Privacy |

---

## 4. Copy-Deck (Deutsch, du)

**Titel**
> Regiere ohne Grenzen

**Subhead**
> Schalte alle Inhalte von *Regiere Deutschland* dauerhaft frei — mit einem
> einzigen Kauf.

**Feature-Liste** (Häkchen + Titel; Beschreibung optional darunter)
| ✓ | Titel | Beschreibung (optional) |
|---|---|---|
| ✓ | Eigene Partei gründen | Name, Farbe, Programm — deine Bewegung. |
| ✓ | Alle Schwierigkeitsgrade | Von „Leicht" bis zur echten Härteprobe. |
| ✓ | Volle Chronik & Statistiken | Jede Amtszeit lückenlos nachvollziehen. |
| ✓ | Keine Limits, keine Werbung | Spielen ohne Unterbrechung. |
| ✓ | Zukünftige Updates inklusive | Einmal kaufen, alles Kommende inklusive. |

> Passe die Liste an die tatsächlich Pro-exklusiven Features an. Aktuell im Code
> gated: **eigene Partei gründen**. Wenn ein Feature nicht wirklich Pro ist, raus
> damit — sonst App-Store-Risiko wegen irreführender Werbung.

**Package-Karte**
> **Unlimited** — `{{ product.price }}`
> Einmalkauf · für immer

**CTA**
> Jetzt freischalten

**Footer-Links**
> Wiederherstellen · Nutzungsbedingungen · Datenschutz

**Legal-Zeile**
> Einmalige Zahlung. Kein Abo, keine automatische Verlängerung.

---

## 5. Zustände

| Zustand | Verhalten |
|---|---|
| **Laden** | RevenueCat zeigt automatisch einen Ladezustand, bis Offering/Preise da sind. Kein eigener Spinner nötig. |
| **Kauf läuft** | Purchase-Button zeigt intern einen Spinner; Interaktion gesperrt. |
| **Erfolg** | Paywall schließt automatisch; `customerInfoStream` setzt `isPro = true` → UI aktualisiert sich von selbst. |
| **Abgebrochen** | Zurück zur Paywall, keine Fehlermeldung. |
| **Fehler** | RevenueCatUI zeigt eine Standard-Fehlermeldung; im eigenen Code landet die Meldung in `PurchaseManager.lastError`. |
| **Bereits Pro** | `.presentPaywallIfNeeded(requiredEntitlementIdentifier:)` zeigt die Paywall gar nicht erst. |

---

## 6. Pflicht für den App-Store-Review

- **Preis sichtbar** direkt am Kauf-Button (über `{{ product.price }}`).
- **„Wiederherstellen"** vorhanden (Footer). Pflicht bei Einmalkauf.
- **Nutzungsbedingungen**-URL: Apples Standard-EULA genügt, sonst eigene.
- **Datenschutz**-URL: erforderlich.
- Keine Abo-Formulierungen („monatlich", „Testphase") — es ist ein Lifetime-Kauf.

URLs im Dashboard unter **Paywall → Footer** hinterlegen.

---

## 7. Lokalisierung

App-Standard ist Deutsch (`de`). Im Paywall-Editor pro Sprache eine Variante:
- **de** (Standard) — obige Copy.
- **en** (optional) — z. B. Titel „Govern without limits", CTA „Unlock now".

Preise **nie** hart eintippen — immer `{{ product.price }}` verwenden, damit
Währung und Betrag pro Store/Region korrekt sind.

---

## 8. Build-Checkliste (RevenueCat-Dashboard)

- [ ] Produkt `Unlimited` als **non-consumable** anlegen (App Store Connect + RevenueCat).
- [ ] Entitlement mit Identifier **`Regiere Deutschland Pro`** anlegen, Produkt zuweisen.
- [ ] Offering **`default1`** anlegen, Produkt als Package hinzufügen (Code lädt es via `Monetization.offeringID`).
- [ ] Paywall (v2) nach dieser Spec bauen, Farben/Copy übernehmen.
- [ ] Footer: Restore + Terms-URL + Privacy-URL aktivieren.
- [ ] Auf iPhone (klein + groß) und iPad in der Vorschau prüfen.
- [ ] Mit **Test Store** durchspielen; vor Release Key auf `appl_…` umstellen.
