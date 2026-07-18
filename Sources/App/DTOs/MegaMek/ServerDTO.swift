//
//  ServerDTO.swift
//  mul-api
//
//  Created by Richard Hancock on 12/29/25.
//

extension MegaMek {
    struct ServerDTO : Codable {
        var port: Int
        var version: String
        var phase: String?
        var passworded: Bool?
        var users: [String]
        var motd: String?
        var key: String?
    }
}
