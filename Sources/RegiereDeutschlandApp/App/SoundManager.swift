import Foundation
import AVFoundation
import Observation
import SwiftUI

/// Kurze Klänge an den wichtigen Momenten des Spiels.
enum SoundEffect: String {
    case stamp = "sfx-stamp"
    case paper = "sfx-paper"
    case typewriter = "sfx-typewriter"
    /// Fernschreiber-Rattern für dringende Meldungen (Sicherheit, Außenpolitik).
    case teletype = "sfx-teletype"
    case takeOffice = "sting-take-office"
    case electionWon = "sting-election-won"
    case electionLost = "sting-election-lost"
    /// Feierlicher Schlussakkord, wenn eine Epoche endet (2004, 2026, 2050).
    case epochEnd = "sting-epoch-end"

    /// Stinger are music: the background track ducks while they play.
    var isSting: Bool { rawValue.hasPrefix("sting-") }
    var volume: Float { isSting ? 0.75 : 0.9 }
}

enum MusicTrack: String {
    case menu = "music-menu-theme"
    case crisis = "music-crisis-loop"
}

/// Musik und Effekte, getrennt abschaltbar. Nutzt die Kategorie `.ambient`:
/// respektiert den Stummschalter und unterbricht keine Musik anderer Apps.
@MainActor
@Observable
final class SoundManager {
    static let shared = SoundManager()

    var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: Self.musicKey)
            musicEnabled ? resumeMusic() : stopMusic(fade: 0.4, forget: false)
        }
    }
    var effectsEnabled: Bool {
        didSet { UserDefaults.standard.set(effectsEnabled, forKey: Self.effectsKey) }
    }

    private static let musicKey = "soundMusicEnabled"
    private static let effectsKey = "soundEffectsEnabled"
    private static let musicVolume: Float = 0.32
    private static let duckedVolume: Float = 0.08

    @ObservationIgnored private var effectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    @ObservationIgnored private var musicPlayer: AVAudioPlayer?
    @ObservationIgnored private var currentTrack: MusicTrack?
    @ObservationIgnored private var duckTask: Task<Void, Never>?

    private init() {
        let defaults = UserDefaults.standard
        musicEnabled = defaults.object(forKey: Self.musicKey) as? Bool ?? true
        effectsEnabled = defaults.object(forKey: Self.effectsKey) as? Bool ?? true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
    }

    // MARK: Effekte

    func play(_ effect: SoundEffect) {
        guard effectsEnabled, let player = player(for: effect) else { return }
        player.currentTime = 0
        player.volume = effect.volume
        player.play()
        if effect.isSting { duckMusic(for: player.duration) }
    }

    private func player(for effect: SoundEffect) -> AVAudioPlayer? {
        if let cached = effectPlayers[effect] { return cached }
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "m4a"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        effectPlayers[effect] = player
        return player
    }

    // MARK: Musik

    /// Wechselt mit Überblendung zum Titel; derselbe Titel läuft unverändert weiter.
    func playMusic(_ track: MusicTrack) {
        guard currentTrack != track || musicPlayer?.isPlaying != true else { return }
        currentTrack = track
        guard musicEnabled else { return }
        startMusic(track)
    }

    func stopMusic(fade: TimeInterval = 1.0) {
        stopMusic(fade: fade, forget: true)
    }

    private func stopMusic(fade: TimeInterval, forget: Bool) {
        if forget { currentTrack = nil }
        guard let old = musicPlayer else { return }
        musicPlayer = nil
        old.setVolume(0, fadeDuration: fade)
        Task {
            try? await Task.sleep(for: .seconds(fade))
            old.stop()
        }
    }

    private func resumeMusic() {
        if let track = currentTrack { startMusic(track) }
    }

    private func startMusic(_ track: MusicTrack) {
        stopMusic(fade: 1.2, forget: false)
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "m4a"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.play()
        player.setVolume(Self.musicVolume, fadeDuration: 1.5)
        musicPlayer = player
    }

    private func duckMusic(for duration: TimeInterval) {
        guard let music = musicPlayer else { return }
        duckTask?.cancel()
        music.setVolume(Self.duckedVolume, fadeDuration: 0.3)
        duckTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(max(1, duration - 0.5)))
            guard !Task.isCancelled, let self, self.musicPlayer === music else { return }
            music.setVolume(Self.musicVolume, fadeDuration: 1.2)
        }
    }
}

/// Schalter für Musik und Effekte (in Menüs als Häkchen dargestellt).
struct SoundToggles: View {
    @Environment(GamePresentation.self) private var p
    @Bindable private var sound = SoundManager.shared

    var body: some View {
        Toggle(isOn: $sound.musicEnabled) {
            Label(p.pick("Musik", "Music", "Musique"), systemImage: "music.note")
        }
        Toggle(isOn: $sound.effectsEnabled) {
            Label(p.pick("Soundeffekte", "Sound effects", "Effets sonores"), systemImage: "speaker.wave.2.fill")
        }
    }
}
