//
//  DatabaseSerializedTrait.swift
//
//  Every suite in this target migrates and reverts the full schema of a single,
//  shared Postgres database around each test. Swift Testing schedules suites and
//  their tests concurrently by default, which races those migrations against each
//  other. This trait forces every test tagged with it to run one at a time,
//  process-wide, regardless of which suite it belongs to.
//

import Testing

actor DatabaseTestLock {
    static let shared = DatabaseTestLock()

    private var isLocked = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func acquire() async {
        if !isLocked {
            isLocked = true
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        if waiters.isEmpty {
            isLocked = false
        } else {
            waiters.removeFirst().resume()
        }
    }
}

struct DatabaseSerializedTrait: SuiteTrait, TestTrait, TestScoping {
    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        await DatabaseTestLock.shared.acquire()
        do {
            try await function()
        } catch {
            await DatabaseTestLock.shared.release()
            throw error
        }
        await DatabaseTestLock.shared.release()
    }
}

extension Trait where Self == DatabaseSerializedTrait {
    static var databaseSerialized: Self { DatabaseSerializedTrait() }
}
