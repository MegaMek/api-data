//
//  Application+Testable.swift
//  mul-api
//
//  Created by Richard Hancock on 10/3/24.
//

@testable import App
@testable import XCTVapor

extension XCTApplicationTester {
    public func loginReturningResponse(user: Security.User) throws -> XCTHTTPResponse {
        var request = XCTHTTPRequest(
            method: .POST,
            url: .init(path: "/authentication"),
            headers: [:],
            body: ByteBufferAllocator().buffer(capacity: 0))

        request.headers.basicAuthorization = .init(username: user.username, password: "password")
        return try performTest(request: request)
    }

    public func login(user: Security.User) throws -> String {
        let response = try loginReturningResponse(user: user)
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
        file: StaticString = #file,
        line: UInt = #line,
        beforeRequest: (inout XCTHTTPRequest) throws -> Void = { _ in },
        afterResponse: (XCTHTTPResponse) throws -> Void = { _ in }
    ) throws -> XCTApplicationTester {
        var request = XCTHTTPRequest(
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

            let token = try login(user: userToLogin)
            request.headers.bearerAuthorization = .init(token: token)
        }

        try beforeRequest(&request)

        do {
            let response = try performTest(request: request)
            try afterResponse(response)
        } catch {
            XCTFail("\(error)", file: (file), line: line)
            throw error
        }

        return self
    }
}
