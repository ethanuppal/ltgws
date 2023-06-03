// Copyright (C) 2023 Ethan Uppal. All rights reserved.

import Foundation

extension Helper {
    /// Turns the given tokens into a correctly formatted sentence.
    static func makeSentence(from words: [String], capitalizing: [String] = []) -> String {
        let toCapitalize = capitalizing.map { $0.lowercased() }
        var result = ""
        var newSentence = true
        var openedQuote = false
        for word in words {
            if isEndingPunct(word) {
                newSentence = true
                result += word
                result += " "
            } else if word == Helper.balancedClosePunctation {
                result += word
                if !newSentence {
                    result += " "
                }
            } else if word == Helper.balancedOpenPunctation {
                if !newSentence {
                    result += " "
                }
                result += word
                openedQuote = true
            } else if word == "," {
                result += ","
            } else {
                if newSentence {
                    result += word.capitalized
                    newSentence = false
                } else {
                    if !openedQuote {
                        result += " "
                    }
                    let suffixes = ["’s", "’ve", "’m", "’d"]
                    if toCapitalize.contains(word)
                        || !suffixes.filter({
                            word.hasSuffix($0)
                            && toCapitalize.contains(String(word.dropLast($0.count)))
                        }).isEmpty {
                        result += word.capitalized
                    } else {
                        result += word
                    }
                    openedQuote = false
                }
            }
        }
        while !result.isEmpty, Helper.keptPunctuation.contains(result.first!) {
            result.removeFirst()
        }
        return result
    }
}
