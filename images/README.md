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

- Quelldateien (`0*.png`): **1290 × 2796 px** (Portrait). Das ist **keine** der
  von App Store Connect akzeptierten Größen – daher nicht direkt hochladen.
- **Upload-fertig:** `appstore-6.7/` enthält dieselben acht Screenshots auf
  exakt **1284 × 2778 px** (6,7"-Portrait) skaliert – eine der vier zulässigen
  Größen (1242 × 2688, 2688 × 1242, 1284 × 2778, 2778 × 1284). Ohne Alpha-Kanal,
  RGB, direkt in den Screenshot-Slot ladbar. Diese Bilder decken auch den
  6,5"- und 6,9"-Slot ab (Apple skaliert automatisch).
- Verzerrungsfrei erzeugt (uniform auf Breite 1284 skaliert, dann zentriert auf
  2778 px Höhe zugeschnitten – es fällt nur reiner Hintergrund weg):
  `sips --resampleWidth 1284 f.png && sips -c 2778 1284 f.png`
- Die unbearbeiteten Geräte-Screenshots (1206 × 2622, 6,1") liegen nicht im
  Repo; sie lassen sich jederzeit neu aus dem Simulator ziehen.

## Neu erzeugen

Screens im Simulator ansteuern, mit `xcrun simctl io <udid> screenshot` sichern
und mit dem Kompositions-Skript (Pillow) rahmen. Schriften: SF Pro Rounded.
