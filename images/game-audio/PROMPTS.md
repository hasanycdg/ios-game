# Spiel-Audio – Prompts

14 Audiodateien, jeweils **10–20 Sekunden** lang. Gedacht für KI-Audio-Generatoren
(z. B. ElevenLabs Sound Effects, Stable Audio, Suno/Udio im Instrumental-Modus).
Kurze Effekte (Stempel, Papier) erzeugst du ebenfalls mit 10 Sekunden; ich
schneide sie danach auf die nutzbare Länge zu. Du musst nichts kürzen.

## Regeln für alle Dateien

- **Rein instrumental bzw. Geräusch:** kein Gesang, keine Sprache, keine Texte.
- **Keine bekannten Melodien:** keine Nationalhymnen, keine Zitate aus Filmmusik,
  keine erkennbaren Songs. Alles muss für alle vier Länder passen.
- **Kommerzielle Nutzung** muss durch euer Abo beim Generator gedeckt sein
  (bei vielen Diensten nur im bezahlten Plan). Bitte bestätigen.
- **Export:** WAV oder M4A, 44,1 kHz, Stereo. Lautstärke grob einheitlich (ca. −14 LUFS);
  ich gleiche den Rest an.
- **Dateiname** exakt wie unten, z. B. `music-menu-theme.wav`. Ablage: einfach mir
  schicken oder in einen Ordner `Sources/RegiereDeutschlandApp/Resources/Audio/` legen.
- Prompts auf Englisch, weil die Generatoren damit verlässlicher arbeiten.

### Stil-Block für Musik (immer voranstellen)

```
Cinematic orchestral underscore for a serious political strategy game, in the style of a
prestige political thriller TV series. Strings, low brass, soft piano, subtle modern
pulse and timpani. Restrained, tense, elegant. Instrumental only, no vocals, no choir
words, no national anthems, no recognizable melodies.
```

---

## Musik (Loops, 20 Sekunden)

Laufen in Schleife. Bitte **nahtlos loopbar** anfordern: gleiches Tempo und gleiche
Tonart vom Anfang bis zum Ende, kein Fade-out, kein Schlussakkord.

| Dateiname | Wo in der App | Prompt (nach dem Stil-Block) |
|---|---|---|
| `music-menu-theme` | Startseite, Onboarding | `Main menu theme, 20 seconds, seamless loop, 90 BPM, D minor. Warm low strings and a slow piano motif, a hint of ambition and responsibility, quietly grand, not dramatic. No ending, no fade.` |
| `music-crisis-loop` | Ereignisse in Krisen (Sicherheit, Krieg, Zukunft 2050) | `Tension underscore, 20 seconds, seamless loop, 110 BPM, C minor. Pulsing low staccato strings, ticking percussion, distant brass swells, a feeling of an emergency cabinet meeting at night. No ending, no fade.` |
| `music-election-night` | Wahlabend / Live-Hochrechnung | `Election night countdown, 20 seconds, seamless loop, 120 BPM, A minor. Driving modern pulse, low synth bass, staccato strings building suspense, soft timpani rolls, like a TV election broadcast waiting for the result. No ending, no fade.` |

---

## Stinger (kurze Musikmomente, 10 Sekunden)

Spielen einmal ab, mit klarem Ende.

| Dateiname | Wo in der App | Prompt (nach dem Stil-Block) |
|---|---|---|
| `sting-take-office` | Amtsausweis im Onboarding, Amtsantritt | `Short ceremonial fanfare, 10 seconds. Solemn brass and timpani rising into a warm major chord, dignified swearing-in moment, then a clean natural decay. Clear ending.` |
| `sting-election-won` | „Wiedergewählt“ | `Victory sting, 10 seconds. Bright triumphant brass and strings, a short rising phrase into a strong major chord, celebratory but not cheesy, natural decay. Clear ending.` |
| `sting-election-lost` | „Abgewählt“ | `Defeat sting, 10 seconds. Low strings and a single muted horn falling into a dark minor chord, quiet, heavy, dignified loss, long decay into silence. Clear ending.` |
| `sting-cliffhanger` | Ende des Prologs („Fortsetzung folgt“) | `Cliffhanger sting, 10 seconds. A tense rising string swell with a ticking clock pulse, ending abruptly on an unresolved suspended chord, like the end of a TV episode before the credits.` |
| `sting-breaking-news` | Neues Ereignis / Eilmeldung | `News bulletin jingle, 10 seconds. Urgent synth pulses and a short brass hit, like a TV breaking-news intro, generic and not resembling any real broadcaster, then silence. Main hit in the first 3 seconds.` |

---

## Soundeffekte (10 Sekunden erzeugen, ich schneide zu)

Bitte **ohne Musik**, nur das Geräusch. Das eigentliche Geräusch sollte gleich am
Anfang kommen.

| Dateiname | Wo in der App | Prompt |
|---|---|---|
| `sfx-stamp` | „BESCHLOSSEN“-Stempel bei jeder Entscheidung | `A single heavy rubber stamp slammed onto paper on a wooden desk, close-up, crisp and satisfying, with a short room reverb, then silence. One stamp only, in the first second.` |
| `sfx-paper` | Neues Ereignis, Blättern | `A single document page being turned and a thin folder opened on a desk, close-up, crisp paper sound, quiet office room tone, then silence.` |
| `sfx-typewriter` | Datum tippt sich im Onboarding-Intro | `Vintage mechanical typewriter typing about twelve keystrokes at a steady pace, close-up, crisp clicks, no bell at the end, then silence.` |
| `sfx-crowd-cheer` | Wahlsieg | `A large indoor crowd of supporters erupting into cheering and applause at a party headquarters, excited, warm, then slowly settling. No words, no chanting of names.` |
| `sfx-crowd-murmur` | Wahlniederlage, schlechte Nachricht | `A large indoor crowd reacting with a disappointed collective groan, then uneasy murmuring, at a party headquarters. No words intelligible.` |
| `sfx-year-end` | Jahresabschluss | `A single deep clock bell strike in a large stone hall, with a long natural reverb tail, followed by silence.` |

---

## Checkliste vor dem Abschicken

1. 14 Dateien, Namen exakt wie oben.
2. Musik-Loops: Anfang und Ende anhören, kein Bruch beim Wiederholen.
3. Kein Gesang, keine Sprache, keine bekannte Melodie.
4. Lizenz für kommerzielle Nutzung geprüft.
5. Mir schicken. Ich schneide, gleiche die Lautstärke an und baue Ton samt
   Schalter „Musik/Effekte aus“ in die Einstellungen ein.
