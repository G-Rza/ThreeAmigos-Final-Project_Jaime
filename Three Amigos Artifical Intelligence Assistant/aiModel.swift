//
//  aiModel.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/12/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import Foundation
import Speech
import CoreML
import NaturalLanguage
import AVFoundation


@available(iOS 15.0, *)
class aiModel {
    
    var speechRecognizer = SpeechRecognizer()
    let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Speech & Classification Functions
    // Bryce's TTS integration function
    func speakOutput(_ output: String) {
        let utterance = AVSpeechUtterance(string: output)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func bagOfWords(text: String) -> [String: Double] {
        var bow = [String: Double]()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        let range = NSRange(location: 0, length: text.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.string = text.lowercased()
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { _, tokenRange, _ in
            let word = (text as NSString).substring(with: tokenRange)
            if bow[word] != nil {
                bow[word]! += 1
            } else {
                bow[word] = 1
            }
        }
        return bow
    }
    
    // Function to classify text using CoreML
    func classifyText(_ text: String) -> String {
        var intent = ""
        let words = bagOfWords(text: text)
        if let model = try? AppleTopicsTC(configuration: MLModelConfiguration()),
           let prediction = try? model.prediction(text: words) {
            intent = prediction.label
        }
        return handleClassificationResult(intent, content: text)
    }
    
    // Handling classification results
    func handleClassificationResult(_ result: String, content: String) -> String {
        switch result {
        case "timer":
            return handleTimerInput(content)
        case "reminder":
            return handleReminderInput(content)
        case "note":
            return handleNoteInput(content)
        default:
            speakOutput("Unknown input. Please provide valid input.")
            return "Unknown input. Please provide a valid input"
        }
    }
    
    // MARK: - Handlers For Our Tasks
    // Handling timer input. the input will always have it set for 'X' minutes, a list or array. In general the 5th word (4th index)
    // "Set a timer for X minutes"
    // Grab input[4] for the value needed
    func handleTimerInput(_ input: String) -> String {
        let words = input.split(separator: " ")
        var time = ""
        if words.count < 6 {
            speakOutput("Sorry, I didn't understand that.")
            return "Sorry, I didn't understand that."
        } else {
            time = String(words[4])
        }
        var timeValue = 0
        switch time {
        case "one":
            timeValue = 1
        case "two":
            timeValue = 2
        case "three":
            timeValue = 3
        case "four":
            timeValue = 4
        case "five":
            timeValue = 5
        case "six":
            timeValue = 6
        case "seven":
            timeValue = 7
        case "eight":
            timeValue = 8
        case "nine":
            timeValue = 9
        default:
            timeValue = Int(time)!
        }
        let final_time = Int(timeValue * 60) // Assuming input is in minutes
        // Set a timer
        let controller = TimerViewController()
        controller.setAndStartTimer(final_time)
        self.speakOutput("Timer started. I will notify you in \(timeValue) minutes.")
        return "Timer started. I will notify you in \(timeValue) minutes."
    }
    // remind me to do something..reminder content and time in Minutes, hours, days.
    // "Remind me that/to <text> in X Y" E.g., "Remind me to make dinner in 4 hours"
    // input[n-2] for value of time, input[n-1] for unit of time
    // Everything from input[3] to input [n-4]  is the reminder content
    func handleReminderInput(_ input: String) -> String {
        let words = input.split(separator: " ")
        guard words.count >= 7 else { self.speakOutput("I'm sorry, I didn't understand that."); return "I'm sorry, I didn't understand that."}
        let reminderContent = words[3..<(words.count - 3)].joined(separator: " ")
        let timeValueString = String(words[words.count - 2])
        var timeUnit = String(words.last!)
        
        if timeUnit.last! != "s" {
            timeUnit += "s"
        }
        
        var timeInSeconds: TimeInterval = 0
        if let timeValue = Double(timeValueString) {
            switch timeUnit {
            case "minutes":
                timeInSeconds = timeValue * 60
            case "hours":
                timeInSeconds = timeValue * 3600
            case "days":
                timeInSeconds = timeValue * 86400
            default:
                self.speakOutput("I'm sorry, I didn't understand that.")
                return "I'm sorry, I didn't understand that."
            }
            
            let reminderDate = Date().addingTimeInterval(timeInSeconds)
            let controller = ReminderViewController()
            controller.saveNewReminder(reminderContent, date: reminderDate)
            self.speakOutput("Reminder to \(reminderContent) in \(words[words.count - 2]) \(words[words.count - 1]) added.")
            return "Reminder to \(reminderContent) in \(words[words.count - 2]) \(words[words.count - 1]) added."
        }
        self.speakOutput("I'm sorry, I ran into an error.")
        return "I'm sorry, I ran into an error."
    }
    
    // "Make a note that <text>"
    // Everything from input[4] onwards in the note
    func handleNoteInput(_ input: String) -> String {
        let words = input.split(separator: " ")
        let noteContent = words.dropFirst(4).joined(separator: " ")
        guard !noteContent.isEmpty else { return "I'm sorry, I ran into an error."}
        notes.append(noteContent)
        UserDefaults.standard.set(notes, forKey: notesKey)
        self.speakOutput("Note created.")
        return "Note created."
    }
    
    // MARK: - Notification Functions
    func notifyUserTimerFinished() {
        DispatchQueue.main.async {
            self.speakOutput("Ring ring, ring ring")
        }
    }
    
    // Notify user when it's time for the reminder
    func notifyUserReminder(_ content: String) {
        // Notify user about the reminder
        DispatchQueue.main.async {
            self.speakOutput("Reminder: \(content)")
        }
    }
}
