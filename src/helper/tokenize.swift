// Copyright (C) 2023 Ethan Uppal. All rights reserved.

extension Helper {
    /// Tokenizes text while keeping some punctuation intact (including them as tokens).
    static func tokenize(text: String) -> [String] {
        var tokens = [String]()
        var acc = ""

        func pushAcc() {
            if !acc.isEmpty {
                tokens.append(acc)
                acc = ""
            }
        }

        for char in text.lowercased() {
            if Helper.keptPunctuation.contains(char) {
                pushAcc()
                acc.append(char)
                pushAcc()
            } else if Helper.ignoredPunctuation.contains(char) {
                pushAcc()
            } else {
                acc.append(char)
            }
        }

        return tokens
    }

}
