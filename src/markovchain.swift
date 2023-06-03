// Copyright (C) 2023 Ethan Uppal. All rights reserved.

/// A generic Markov chain.
class MarkovChain: CustomDebugStringConvertible {
    private let tokens: [String]
    let order: Int
    private let matrix: TransitionMatrix

    var debugDescription: String {
        return "MarkovChain(order: \(order), matrix: \(matrix))"
    }

    init(tokens: [String], order: Int) {
        self.tokens = tokens
        self.order = order
        self.matrix = TransitionMatrix(tokens: tokens, order: order)
    }

    func generate(sentenceCount: Int, minSentenceLength: Int = 3, maxSentenceLength: Int = 100, sentenceDecay: Double = 0.9, seed seedIn: [String]? = nil) -> [String] {
        func randomSeed() -> [String] {
            if order == 0 {
                return []
            }
            let i = Int.random(in: 0 ..< tokens.count - order + 1)
            return Array(tokens[i ..< i + order])
        }

        func choose(from matrix: TransitionMatrix) -> String {
            let probabilities = matrix.asProbabilities()
            let threshold = Double.random(in: 0 ... 1)
            var runningTotal = 0.0
            for (choice, probability) in probabilities {
                runningTotal += probability
                if runningTotal >= threshold {
                    return choice
                }
            }
            fatalError("Probabilities don't add up to 1")
        }

        if let seedIn = seedIn {
            assert(seedIn.count == order, "An order \(order) Markov chain requires an initial state of \(order) \(Helper.pluralize("word", order)).")
        }
        var seed = seedIn ?? randomSeed()

        var result = [String]()
        var currentSentenceCount = 0
        var currentSentenceLength = 0
        var needsClosePunctuation = false
        while currentSentenceCount < sentenceCount {
            let next = choose(from: matrix[seed]!)

            // Prevent empty sentences
            if Helper.isEndingPunct(next) && currentSentenceLength < minSentenceLength {
                seed = randomSeed()
                continue
            }

            // Ensure quotes are matched
            if (!needsClosePunctuation
                    && next == Helper.balancedClosePunctation)
                || (needsClosePunctuation
                    && next == Helper.balancedOpenPunctation) {
                continue
            }

            result.append(next)

            if next == Helper.balancedOpenPunctation {
                needsClosePunctuation = true
            } else if next == Helper.balancedClosePunctation {
                needsClosePunctuation = false
            }

            currentSentenceLength += 1

            seed.append(next)
            seed.removeFirst()

            if currentSentenceLength >= minSentenceLength && Double.random(in: 0 ... 1) > sentenceDecay {
                currentSentenceCount += 1
                currentSentenceLength = 0
                if !Helper.isEndingPunct(next) {
                    result.append(needsClosePunctuation ? Helper.balancedClosePunctation : Helper.defaultEndingPunctuationMark)
                }
                seed.append(Helper.defaultEndingPunctuationMark)
                seed.removeFirst()
                continue
            }

            if Helper.isEndingPunct(next) || currentSentenceLength > maxSentenceLength {
                if needsClosePunctuation {
                    result.append(Helper.balancedClosePunctation)
                }
                currentSentenceCount += 1
                currentSentenceLength = 0
            }
        }
        return result
    }
}
