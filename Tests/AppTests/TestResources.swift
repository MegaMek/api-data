//
//  TestResources.swift
//  mul-api
//
//  Created by Richard Hancock on 7/18/26.
//

import Foundation
import NIOCore
import NIOFileSystem

enum TestResources {
    /// Tests/Resources, located relative to this source file rather than the
    /// working directory, which is not the package root when Xcode runs tests.
    private static let directory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // AppTests
        .deletingLastPathComponent()  // Tests
        .appendingPathComponent("Resources")

    static func buffer(for name: String) async throws -> ByteBuffer {
        try await ByteBuffer(
            contentsOf: FilePath(directory.appendingPathComponent(name).path),
            maximumSizeAllowed: .mebibytes(1)
        )
    }
}
