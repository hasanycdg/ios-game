# App-Store-Screenshots

Acht fertige Marketing-Screenshots für den App-Store-Eintrag, aus echten
Spielszenen komponiert (Marken-Hintergrund, Schwarz-Rot-Gold-Band, Überschrift).

| Datei | Szene | Überschrift |
|-------|-------|-------------|
| `01_kanzler.png`     | Startbildschirm / Partei-Auswahl | Werde Kanzler:in von Deutschland |
| `02_partei.png`      | Eigene Partei gründen            | Gründe deine eigene Partei |
| `03_wahlsieg.png`    | Lage-Briefing zum Amtsantritt    | Du gewinnst die Wahl |
| `04_koalition.png`   | Koalitionsbildung                | Schmiede deine Koalition |
| `05_verhandlung.png` | Koalitionsgespräche              | Verhandle die Bedingungen |
| `06_entscheiden.png` | Ereignis & Entscheidung          | Entscheide wie ein echter Kanzler |
| `07_folgen.png`      | Ergebnis: Auswirkungen & Historie| Jede Entscheidung zählt |
| `08_parteien.png`    | Politik-Tab: Parteienlandschaft  | Parteien & Wähler im Blick |

## Format

- Größe: **1290 × 2796 px** (Portrait). Passt in den 6,5"/6,7"-Slot von
  App Store Connect; für das 6,9"-Display kann Apple hochskalieren oder du
  renderst mit 1320 × 2868 neu.
- Die unbearbeiteten Geräte-Screenshots (1206 × 2622, 6,1") liegen nicht im
  Repo; sie lassen sich jederzeit neu aus dem Simulator ziehen.

## Neu erzeugen

Screens im Simulator ansteuern, mit `xcrun simctl io <udid> screenshot` sichern
und mit dem Kompositions-Skript (Pillow) rahmen. Schriften: SF Pro Rounded.
