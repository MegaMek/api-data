//
//  Application+Testable.swift
//  mul-api
//
//  Created by Richard Hancock on 10/3/24.
//

import Testing
import VaporTesting

@testable import App

extension TestingApplicationTester {
    public func loginReturningResponse(user: Security.User) async throws -> TestingHTTPResponse {
        var request = TestingHTTPRequest(
            method: .POST,
            url: .init(path: "/authentication"),
            headers: [:],
            body: ByteBufferAllocator().buffer(capacity: 0))

        request.headers.basicAuthorization = .init(username: user.username, password: "password")
        return try await performTest(request: request)
    }

    public func login(user: Security.User) async throws -> String {
        let response = try await loginReturningResponse(user: user)
        return try response.content.decode(String.self)
    }

    @discardableResult
    public func test(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        body: ByteBuffer? = nil,
        loggedInRequest: Bool = false,
        loggedInUser: Security.User? = nil,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
        beforeRequest: (inout TestingHTTPRequest) async throws -> Void = { _ in },
        afterResponse: (TestingHTTPResponse) async throws -> Void = { _ in }
    ) async throws -> TestingApplicationTester {
        var request = TestingHTTPRequest(
            method: method,
            url: .init(path: path),
            headers: headers,
            body: body ?? ByteBufferAllocator().buffer(capacity: 0))

        if loggedInRequest || loggedInUser != nil {
            let userToLogin: Security.User

            if let user = loggedInUser {
                userToLogin = user
            } else {
                userToLogin = Security.User(
                    name: "Test User",
                    username: "testUser",
                    email: "test@fasa.games")
                try userToLogin.setPassword("password", confirm: "password")
            }

            let token = try await login(user: userToLogin)
            request.headers.bearerAuthorization = .init(token: token)
        }

        try await beforeRequest(&request)

        do {
            let response = try await performTest(request: request)
            try await afterResponse(response)
        } catch {
            let sourceLocation = Testing.SourceLocation(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column)
            Issue.record("\(error)", sourceLocation: sourceLocation)
            throw error
        }

        return self
    }
}

extension Application {
    fileprivate func withMigratedDatabase<T>(
        _ body: (Application) async throws -> T
    ) async throws -> T {
        try await autoMigrate()
        do {
            let result = try await body(self)
            try await autoRevert()
            return result
        } catch {
            try? await autoRevert()
            throw error
        }
    }
}

/// Creates a configured, migrated `Application` for the duration of `test`, then reverts
/// migrations and shuts the application down, whether or not `test` throws.
public func withTestApp<T>(
    _ test: (Application) async throws -> T
) async throws -> T {
    try await withApp(configure: configure) { app in
        try await app.withMigratedDatabase(test)
    }
}
