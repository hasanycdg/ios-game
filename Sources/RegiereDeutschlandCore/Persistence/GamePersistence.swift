import Foundation

public final class GamePersistence {
    public enum PersistenceError: Error {
        case unableToCreateDirectory
    }

    private let fileManager: FileManager
    private let saveURL: URL
    private let runResultsURL: URL

    public init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil
    ) {
        self.fileManager = fileManager
        let directory = baseDirectory ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("RegiereDeutschland", isDirectory: true)
            ?? fileManager.temporaryDirectory.appendingPathComponent("RegiereDeutschland", isDirectory: true)
        self.saveURL = directory.appendingPathComponent("savegame.json")
        self.runResultsURL = directory.appendingPathComponent("run-results.json")
    }

    public var hasSaveGame: Bool {
        fileManager.fileExists(atPath: saveURL.path)
    }

    public func loadSnapshot() -> GameSessionSnapshot? {
        guard let data = try? Data(contentsOf: saveURL) else { return nil }
        return try? JSONDecoder.gameDecoder.decode(GameSessionSnapshot.self, from: data)
    }

    public func saveSnapshot(_ snapshot: GameSessionSnapshot) throws {
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
