import Foundation

protocol PowerManagementServicing: Sendable {
    func lidSleepDisabled() async throws -> Bool
    func setLidSleepDisabled(_ disabled: Bool) async throws
    func sleepNow() async throws
}

protocol SleepScheduling: Sendable {
    func sleep(for duration: Duration) async throws
}

struct TaskSleepScheduler: SleepScheduling {
    func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}

struct PowerManagementService: PowerManagementServicing {
    private let runner: any ProcessRunning

    init(runner: any ProcessRunning = ProcessRunner()) {
        self.runner = runner
    }

    func lidSleepDisabled() async throws -> Bool {
        let output = try await runner.run(
            "/usr/bin/pmset",
            arguments: ["-g", "custom"]
        )

        return output
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .contains { $0.hasPrefix("disablesleep") && $0.hasSuffix("1") }
    }

    func setLidSleepDisabled(_ disabled: Bool) async throws {
        let value = disabled ? "1" : "0"
        let command = "/usr/bin/pmset -a disablesleep \(value)"
        try await runner.runPrivilegedShellCommand(command)
    }

    func sleepNow() async throws {
        try await runner.runPrivilegedShellCommand("/usr/bin/pmset sleepnow")
    }
}

protocol ProcessRunning: Sendable {
    func run(_ launchPath: String, arguments: [String]) async throws -> String
    func runPrivilegedShellCommand(_ command: String) async throws
}

enum ProcessRunnerError: LocalizedError {
    case nonZeroExit(String)
    case failedToCreateOutput

    var errorDescription: String? {
        switch self {
        case .nonZeroExit(let message):
            message
        case .failedToCreateOutput:
            "Unable to read process output."
        }
    }
}

struct ProcessRunner: ProcessRunning {
    func run(_ launchPath: String, arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let stdout = Pipe()
            let stderr = Pipe()

            process.executableURL = URL(fileURLWithPath: launchPath)
            process.arguments = arguments
            process.standardOutput = stdout
            process.standardError = stderr
            process.terminationHandler = { process in
                let data = stdout.fileHandleForReading.readDataToEndOfFile()
                let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
                let text = String(data: data, encoding: .utf8)
                let errorText = String(data: errorData, encoding: .utf8) ?? ""

                if process.terminationStatus == 0, let text {
                    continuation.resume(returning: text)
                } else if !errorText.isEmpty {
                    continuation.resume(throwing: ProcessRunnerError.nonZeroExit(errorText.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    continuation.resume(throwing: ProcessRunnerError.failedToCreateOutput)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func runPrivilegedShellCommand(_ command: String) async throws {
        let script = #"do shell script "\#(escapeForAppleScript(command))" with administrator privileges"#
        _ = try await run("/usr/bin/osascript", arguments: ["-e", script])
    }

    private func escapeForAppleScript(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
