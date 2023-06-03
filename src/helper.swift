// Copyright (C) 2023 Ethan Uppal. All rights reserved.

enum Helper {
    static let balancedOpenPunctation = "“"
    static let balancedClosePunctation = "”"
    static let endingPunctuation = ".!?"
    static let defaultEndingPunctuationMark = "."
    static let keptPunctuation = endingPunctuation
        + balancedOpenPunctation
        + balancedClosePunctation + ","
    static let ignoredPunctuation = """
 /()\\[{]}];:'|@#$%^&*-—_=+`~<>\n\r

"""

    static func isEndingPunct(_ char: String) -> Bool {
        return endingPunctuation.contains(char.first!)
    }

    static func pluralize(_ word: String, _ n: Int, suffix: String = "s", form: String? = nil) -> String {
        let pluralForm = form ?? (word + suffix)
        return n == 1 ? word : pluralForm
    }
}
