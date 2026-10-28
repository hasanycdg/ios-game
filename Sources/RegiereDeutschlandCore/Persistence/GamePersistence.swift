import Foundation

public final class GamePersistence {
    public enum PersistenceError: Error {
        case unableToCreateDirectory
        case countryMismatch
    }

    private let fileManager: FileManager
    private let saveURL: URL
    private let runResultsURL: URL
    private let achievementsURL: URL
    private let country: GameCountry

    public init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil,
        country: GameCountry = .germany
    ) {
        self.fileManager = fileManager
        self.country = country
        let directory = baseDirectory ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("RegiereDeutschland", isDirectory: true)
            ?? fileManager.temporaryDirectory.appendingPathComponent("RegiereDeutschland", isDirectory: true)
        let campaignDirectory = country == .germany ? directory : directory.appendingPathComponent("UnitedStates", isDirectory: true)
        self.saveURL = campaignDirectory.appendingPathComponent("savegame.json")
        self.runResultsURL = campaignDirectory.appendingPathComponent("run-results.json")
        self.achievementsURL = campaignDirectory.appendingPathComponent("achievements.json")
    }

    public var hasSaveGame: Bool {
        fileManager.fileExists(atPath: saveURL.path)
    }

    public func loadSnapshot() -> GameSessionSnapshot? {
        guard let data = try? Data(contentsOf: saveURL) else { return nil }
        guard let snapshot = try? JSONDecoder.gameDecoder.decode(GameSessionSnapshot.self, from: data),
              snapshot.country == country else { return nil }
        return snapshot
    }

    public func saveSnapshot(_ snapshot: GameSessionSnapshot) throws {
        guard snapshot.country == country else { throw PersistenceError.countryMismatch }
        try ensureDirectoryExists()
        let data = try JSONEncoder.prettyGameEncoder.encode(snapshot)
        try data.write(to: saveURL, options: [.atomic])
    }

    public func deleteSnapshot() throws {
        guard hasSaveGame else { return }
        try fileManager.removeItem(at: saveURL)
    }

    public func loadRunResults() -> [RunResult] {
        guard let data = try? Data(contentsOf: runResultsURL) else { return [] }
        return (try? JSONDecoder.gameDecoder.decode([RunResult].self, from: data)) ?? []
    }

    public func appendRunResult(_ runResult: RunResult) throws {
        try ensureDirectoryExists()
        var results = loadRunResults()
        results.insert(runResult, at: 0)
        results = Array(results.prefix(20))
        let data = try JSONEncoder.prettyGameEncoder.encode(results)
        try data.write(to: runResultsURL, options: [.atomic])
    }

    public func loadUnlockedAchievements() -> Set<String> {
        guard let data = try? Data(contentsOf: achievementsURL) else { return [] }
        return (try? JSONDecoder.gameDecoder.decode(Set<String>.self, from: data)) ?? []
    }

    /// Schaltet die angegebenen Erfolge frei und gibt die *neu* hinzugekommenen zurück.
    @discardableResult
    public func unlockAchievements(_ ids: [String]) throws -> [String] {
        var unlocked = loadUnlockedAchievements()
        let newlyUnlocked = ids.filter { !unlocked.contains($0) }
        guard !newlyUnlocked.isEmpty else { return [] }
        unlocked.formUnion(newlyUnlocked)
        try ensureDirectoryExists()
        let data = try JSONEncoder.prettyGameEncoder.encode(unlocked)
        try data.write(to: achievementsURL, options: [.atomic])
        return newlyUnlocked
    }

    private func ensureDirectoryExists() throws {
        let directory = saveURL.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return
        }
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw PersistenceError.unableToCreateDirectory
        }
    }
}

private extension JSONDecoder {
    static var gameDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

private extension JSONEncoder {
    static var prettyGameEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
