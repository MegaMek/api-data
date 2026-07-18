//
//  String+URLSafeBase64.swift
//
//  URL Conversion for Base64 for Query parameter sanitization
//
//  Created by Richard Hancock on 4/29/23.
//

import Foundation

/// Adds a helper for producing a URL-safe variant of a base64 string, so it can be
/// safely embedded in a query parameter (e.g. confirmation tokens) without needing
/// percent-encoding.
extension String {
    /// Converts a standard base64 string into its URL-safe form by swapping the
    /// characters that are unsafe in URLs and dropping padding.
    ///
    /// - Returns: The string with `/` replaced with `_`, `+` replaced with `-`, and
    ///   `=` padding removed.
    func base64URLSafe() -> String {
        self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
