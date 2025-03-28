//
//  String+URLSafeBase64.swift
//
//  URL Conversion for Base64 for Query parameter sanitization
//
//  Created by Richard Hancock on 4/29/23.
//

import Foundation

extension String {
    /// Encodes to a URL Safe base64 String
    func base64URLSafe() -> String {
        self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
