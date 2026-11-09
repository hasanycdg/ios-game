# Spielbilder – Prompts

18 Bilder für Ereignis-Szenen, Kabinett und Wahlabend. Die App lädt sie
automatisch, sobald sie in `Sources/RegiereDeutschlandApp/Resources/Assets.xcassets`
unter dem angegebenen **Asset-Namen** liegen (Image Set, Datei als 1x/„Universal“).
Fehlt ein Bild, zeigt die App den gestalteten Platzhalter.

## Regeln für alle Bilder

- **Keine echten Personen**, keine Politiker-Ähnlichkeit, keine Logos, Wappen,
  Parteisymbole oder lesbaren Texte. (Persönlichkeitsrecht, App-Review.)
- **Länderneutral:** Jedes Bild gilt für Deutschland, USA, UK und Frankreich.
  Keine Nationalflaggen, keine erkennbaren Wahrzeichen.
- **Einheitlicher Stil:** immer den Stil-Block unten voranstellen.
- **Kommerzielle Nutzung** muss durch euer Bild-KI-Abo gedeckt sein.
- Prompts sind auf Englisch, weil Bild-KIs damit zuverlässiger arbeiten.

### Stil-Block für Ereignis-Bilder und Wahlabend (immer voranstellen)

```
Cinematic editorial photograph for a serious political strategy game. Moody, high-end
documentary look, shallow depth of field, rich shadows, subtle film grain, muted
desaturated palette with deep navy blacks and warm antique-gold highlights. No
identifiable faces, no real people, no politicians, no text, no letters, no logos, no
flags, no national symbols, no recognizable landmarks. Composition: main subject in the
upper right two-thirds; keep the lower-left third calm and dark, because headline text is
overlaid there.
```

### Stil-Block für Porträts (immer voranstellen)

```
Painted editorial portrait illustration, realistic but clearly illustrated (not a photo),
in the style of a prestige political drama poster. Head and shoulders, centered, facing
slightly toward camera, face filling the middle 60% of the frame so it survives a small
circular crop. Dark charcoal background with a soft colored rim light. Serious,
intelligent, slightly tired expression. Fictional person, no resemblance to any real
politician. No text, no logos, no flags, no lapel pins with symbols.
```

---

## Ereignis-Bilder (10) – Querformat 3:2, z. B. 1536 × 1024

In der App als Streifen von ca. 168 pt Höhe, mittig beschnitten, mit dunklem
Verlauf unten links für die Schlagzeile.

| Asset-Name | Prompt (nach dem Stil-Block) |
|---|---|
| `event-economy` | `A trading floor at dusk, rows of glowing screens with falling and rising market charts as abstract light, a lone figure seen from behind, out of focus, loosened tie. Accent: cool green glow from the screens.` |
| `event-budget` | `Close-up of a government budget folder on a dark wooden desk, stacks of documents, a fountain pen, a calculator and coins, lit by a single warm desk lamp late at night. Accent: warm gold.` |
| `event-society` | `A crowded city square at blue hour seen from above, hundreds of blurred people walking in different directions, warm street lights, a sense of a divided but connected public. Accent: soft blue.` |
| `event-security` | `Night scene of police vehicles with blue and red lights reflected on wet asphalt in front of a modern government building, officers as dark silhouettes, tense atmosphere. Accent: deep red.` |
| `event-energy` | `A high-voltage power line pylon against a dramatic sunset sky, wind turbines and a cooling tower faintly in the hazy distance, sense of transition. Accent: amber orange.` |
| `event-foreignPolicy` | `A long negotiation table in an elegant conference hall, empty chairs, water glasses and closed folders, tall windows with evening light, diplomatic tension. Accent: teal.` |
| `event-digitalization` | `A dim server room corridor with rows of racks and thousands of small status lights, cables, a faint blue haze, a laptop open on a cart in the foreground. Accent: electric blue.` |
| `event-welfare` | `A hospital corridor at night, a nurse as a blurred silhouette walking away, warm and cold light mixing, quiet and humane mood, a wheelchair by the wall. Accent: soft pink-red.` |
| `event-election` | `A ballot box on a table in a school gymnasium used as a polling station, voting booths with curtains, a hand dropping a folded ballot, golden afternoon light. Accent: gold.` |
| `event-historicalEcho` | `An archive room with old newspapers, black-and-white photographs and a vintage typewriter on a desk, dust in a beam of light, sense of history returning. Accent: muted purple.` |

---

## Kabinett-Porträts (7) – quadratisch, 1024 × 1024

In der App als Kreis mit 40–46 pt Durchmesser, Gesicht muss klein noch gut
erkennbar sein. Geschlecht und Rolle gelten in allen vier Ländern gleich; die
Namen in der App unterscheiden sich je Land.

| Asset-Name | Rolle | Prompt (nach dem Stil-Block) |
|---|---|---|
| `advisor-economy` | Finanzministerin | `A woman in her early 50s, sharp grey bob haircut, rimless glasses, dark navy suit, composed and analytical. Rim light: green.` |
| `advisor-security` | Innenminister | `A broad-shouldered man in his late 50s, short grey hair, stern jaw, dark charcoal suit and dark tie, watchful eyes. Rim light: red.` |
| `advisor-foreign` | Außenministerin | `A woman in her mid 40s with dark curly hair pinned back, elegant dark blazer, calm and diplomatic, a faint confident smile. Rim light: teal.` |
| `advisor-energy` | Energieminister | `A man in his early 40s with a short beard, rolled-up shirt sleeves, no tie, energetic and pragmatic. Rim light: amber orange.` |
| `advisor-social` | Sozialministerin | `A woman in her late 30s with dark hair in a low bun, warm and determined expression, simple dark cardigan over a blouse. Rim light: pink.` |
| `advisor-digital` | Digitalminister | `A man in his early 30s, short dark hair, round glasses, dark turtleneck under a blazer, curious and quick. Rim light: electric blue.` |
| `advisor-chief` | Leitung Regierungszentrale | `A woman in her early 60s with silver hair, reading glasses pushed up on her head, dark suit, experienced, unflappable, slightly ironic look. Rim light: gold.` |

Optional länderspezifisch (überschreibt das gemeinsame Porträt nur für dieses
Land): `advisor-<rolle>-<land>`, z. B. `advisor-economy-unitedStates`,
`advisor-security-france`. Länder-Schlüssel: `germany`, `unitedStates`,
`unitedKingdom`, `france`.

---

## Wahlabend (1) – Hochformat 9:19,5, z. B. 1170 × 2532

Liegt mit 35 % Deckkraft hinter dem gesamten Live-Hochrechnungs-Screen; Text
liegt oben und in der Mitte.

| Asset-Name | Prompt (nach dem Stil-Block) |
|---|---|
| `election-night` | `Election night at a party headquarters: a crowd of supporters as dark silhouettes facing a large glowing screen with abstract bar charts, gold and red stage lights, bokeh, haze, anticipation before the result. Vertical composition, keep the center calm and evenly dark so white text stays readable.` |

---

## Export-Checkliste

1. PNG oder JPG, sRGB, keine Transparenz nötig.
2. Exakt den Asset-Namen verwenden (Groß-/Kleinschreibung beachten, z. B. `event-foreignPolicy`).
3. Ereignis-Bilder: Hauptmotiv oben rechts, unten links ruhig und dunkel.
4. Porträts: Gesicht mittig, nichts Wichtiges in den Ecken (Kreisbeschnitt).
5. Mir die Dateien schicken oder direkt in `Assets.xcassets` legen. Ich prüfe sie dann im Simulator.
