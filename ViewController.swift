//
//  ViewController.swift
//  FinalProject_Jaime
//
//  Created by Jaime Garza on 12/10/23.

import UIKit
import CoreML
import NaturalLanguage

class ViewController: UIViewController {

    let model = TextClassifier()

    // Function to classify text using CoreML
    func classifyText(_ text: String) {
        do {
            let prediction = try model.prediction(text: text)
            handleClassificationResult(prediction.label)
        } catch {
            print("Error in classification: \(error)")
        }
    }

    // Handling classification results
    func handleClassificationResult(_ result: String) {
        switch result {
        case "timer":
            handleTimerInput("example input for timer")
        case "reminder":
            // Handle reminder logic
        case "note":
            // Handle note logic
        default:
            // Handle unknown input logic
        }
    }

    // Handling timer input
    func handleTimerInput(_ input: String) {
        let time = extractTimeFromInput(input)
        // Set a timer
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.notifyUserTimerFinished()
        }
    }

    // Notify user when the timer finishes
    func notifyUserTimerFinished() {
        // Notify user
    }

    // Parsing intent using Natural Language Processing
    func parseIntent(from text: String) {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            let word = text[tokenRange]
            // Analyze each word for intent
            return true
        }
    }

    // Function to receive and process input from the UI
    func receiveInputFromUI(_ input: String) {
        classifyText(input)
        // Additional processing
    }

    // Handling errors and providing user feedback
    func handleError(_ error: Error) {
        // Handle errors and provide feedback
    }

    // Example of performance optimization using GCD
    func performBackgroundTask() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Perform heavy lifting in the background
            DispatchQueue.main.async {
                // Update UI on the main thread
            }
        }
    }

    // Example utility function to extract time from input
    func extractTimeFromInput(_ input: String) -> TimeInterval {
        // Implement the logic to extract time from input
        // For example, you can use regular expressions or other parsing techniques
        return 10 // Replace with the actual extracted time
    }
}

