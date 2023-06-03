// Copyright (C) 2023 Ethan Uppal. All rights reserved.

import Foundation

enum ReadLineError: Error {
    case message(String)
}

let projectPath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent() // deletes file component
    .deletingLastPathComponent() // deletes src folder component

let narrators = [
    ("Colum McCann", ["chapter1"]),
    ("Ciaran", ["chapter2"]),
    ("Claire", ["chapter3"]),
    ("Lara", ["chapter4"]),
    ("Phillipe", ["chapter5", "chapter9"]),
    ("José?", ["chapter6"]),
    ("The Kid", ["chapter7"]),
    ("Tillie", ["chapter8"]),
    ("Solomon", ["chapter10"]),
    ("Adelita", ["chapter11"]),
    ("Gloria", ["chapter12"]),
    ("Jaslyn", ["chapter13"])
]

let totalNFiles = narrators.reduce(0) { $0 + $1.1.count }
var nFilesLoaded = 0

func formatPercent(_ n: Double) -> String {
    var str = "\((n * 1000).rounded() / 10)"
    str = String(repeating: " ", count: 5 - str.count) + str
    let progressBarLength = 10
    let asInt = Int(n * Double(progressBarLength))
    str += "% [\(String(repeating: "=", count: asInt))\(String(repeating: " ", count: progressBarLength - asInt))]"
    return str
}

do {
    print("Welcome to Ethan's NYC Literature Final Project")
    print("===============================================")
    print()
    let tokensPerNarrator = try narrators.map { (narrator, filenames) -> [String] in
        let fileURLs = filenames.map {
            projectPath
                .appendingPathComponent("chapters")
                .appendingPathComponent("\($0).txt")
        }

        let fullText = try fileURLs.map {
            let contents = try String(contentsOf: $0)

            nFilesLoaded += 1
            let percent = Double(nFilesLoaded) / Double(totalNFiles)
            let percentString = formatPercent(percent)
            print("Loading chapter data... \(percentString)")

            return contents
        }.joined(separator: " ")

        return Helper.tokenize(text: fullText)
    }

    print()
    print("Enter the numbers of the narrators whose styles you wish to combine, separated by spaces.\n")
    var i = 1
    for ((narrator, _), tokens) in zip(narrators, tokensPerNarrator) {
        print("\(i)\t\(narrator) (\(tokens.count) tokens)")
        i += 1
    }

    while true {
        print()
        print(">>> ", terminator: "")
        guard let input = readLine() else {
            throw ReadLineError.message("Failed to read in narrator numbers.")
        }

        if input.isEmpty || input == "q" {
            break
        }

        let indices = input.split(separator: " ")
            .compactMap { Int($0) }
            .map { $0 - 1 }
            .filter { narrators.indices.contains($0) }

        guard !indices.isEmpty else {
            throw ReadLineError.message("No narrator numbers were provided.")
        }

        switch indices.count {
        case 1:
            print("Processing the style of \(narrators[indices[0]].0)...")
        case 2:
            print("Combining and processing the styles of \(narrators[indices[0]].0) and \(narrators[indices[1]].0)...")
        default:
            print("Combining and processing the styles of \(indices[..<(indices.endIndex - 1)].map { narrators[$0].0 }.joined(separator: ", ")), and \(narrators[indices.last!].0)...")
        }
        print()

        let tokens = Array(indices.map { tokensPerNarrator[$0] }.joined())
        let markovChain = MarkovChain(tokens: tokens, order: 2)
        let sentenceWords = markovChain.generate(
            sentenceCount: 8,
            minSentenceLength: 8,
            maxSentenceLength: 24,
            sentenceDecay: 1
        )

        let sentences = Helper.makeSentence(from: sentenceWords, capitalizing: ["I", "Corrigan", "Claire", "Solomon", "Soderberg", "Lara", "Blaise", "Ciaran", "Dublin", "Ireland", "Jazzlyn", "Norbert", "Adelita", "Mexican", "nixon", "manhattan", "albee", "denny", "rodriguez", "gloria", "blaine", "josé"])
        print("\u{1B}[1m\(sentences)\u{1B}[m")
    }

} catch let error as ReadLineError {
    switch error {
    case .message(let msg):
        print("error: \(msg)")
    }
} catch {
    print("\(error)")
}
