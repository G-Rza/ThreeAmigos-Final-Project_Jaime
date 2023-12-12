//
//  InitialViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import Speech
import CoreML
import NaturalLanguage
import AVFoundation

@available(iOS 15.0, *)
class InitialViewController: UIViewController {
    
    // MARK: - IBOutlets/Properties/ViewLoad
    @IBOutlet weak var transcriptScrollView: UIScrollView!
    @IBOutlet weak var transcriptTextView: UITextView!
    @IBOutlet weak var dictationButton: UIButton!
   
    var speechRecognizer = SpeechRecognizer()
    let model = try! AppleTopicsTC(configuration: MLModelConfiguration()).model
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
    
    // Bryce's TTS integration function
    func speakOutput(_ output: String) {
        let utterance = AVSpeechUtterance(string: output)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    // Function to classify text using CoreML
    func classifyText(_ text: String) {
        do {
            let predictor = try NLModel(mlModel: model)
            let predicted_label = predictor.predictedLabel(for: text)!
            handleClassificationResult(predicted_label, content: text)
        } catch {
            speakOutput("Sorry, I ran into an error. Please try again later.")
        }
    }

    // Handling classification results
    func handleClassificationResult(_ result: String, content: String) {
        switch result {
        case "timer":
            handleTimerInput(content)
        case "reminder":
            handleReminderInput(content)
        case "note":
            handleNoteInput(content)
        default:
            speakOutput("Unknown input. Please provide valid input.")
        }
    }

    // Handling timer input. the input will always have it set for 'X' minutes, a list or array. In general the 5th word (4th index)
    // "Set a timer for X minutes"
    // Grab input[4] for the value needed
    func handleTimerInput(_ input: String) {
        let words = input.split(separator: " ")
        guard words.count > 5, let timeValue = Double(words[4]) else { speakOutput("Sorry, I didn't understand that."); return }
        let time = Int(timeValue * 60) // Assuming input is in minutes
        // Set a timer
        let controller = TimerViewController()
        controller.setAndStartTimer(time)
    }
    // remind me to do something..reminder content and time in Minutes, hours, days.
    // "Remind me that/to <text> in X Y" E.g., "Remind me to make dinner in 4 hours"
    // input[n-2] for value of time, input[n-1] for unit of time
    // Everything from input[3] to input [n-4]  is the reminder content
    func handleReminderInput(_ input: String) {
        let words = input.split(separator: " ")
        guard words.count >= 7 else { self.speakOutput("I'm sorry, I didn't understand that."); return }
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
            }
            let controller = ReminderViewController()
            controller.createReminder(input, timeInSeconds)
        }
    }
            
            // "Make a note that <text>"
            // Everything from input[4] onwards in the note
            func handleNoteInput(_ input: String) {
                let words = input.split(separator: " ")
                let noteContent = words.dropFirst(4).joined(separator: " ")
                let controller = NotesViewController()
                controller.saveNewNote(noteContent)
            }
            
            func notifyUserTimerFinished() {
                DispatchQueue.main.async {
                    self.speakOutput("Timer finished.")
                }
            }
            
            
            // Notify user when it's time for the reminder
            func notifyUserReminder(_ content: String) {
                // Notify user about the reminder
                DispatchQueue.main.async {
                    self.speakOutput("Reminder: \(content)")
                }
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
            
            // MARK: - Methods/Functions
            private func setupButtonActions() {
                dictationButton.addTarget(self, action: #selector(startDictation), for: .touchDown)
                dictationButton.addTarget(self, action: #selector(stopDictation), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            }
            
            @objc func startDictation() {
                Task {
                    self.speechRecognizer.startTranscribing()
                }
            }
            
            @objc func stopDictation() {
                Task {
                    self.speechRecognizer.stopTranscribing()
                    updateTranscript(with: self.speechRecognizer.transcript)
                    classifyText(self.speechRecognizer.transcript)
                    self.speechRecognizer.resetTranscript()
                }
            }
            
            func updateTranscript(with text: String) {
                DispatchQueue.main.async { [weak self] in
                    self?.transcriptTextView.text = text
                    self?.scrollToBottom()
                }
            }
            
            private func scrollToBottom() {
                let bottom = max(transcriptTextView.contentSize.height - transcriptTextView.bounds.height, 0)
                if bottom > 0 {
                    transcriptScrollView.scrollRectToVisible(CGRect(x: 0, y: bottom, width: 1, height: 1), animated: true)
                }
            }
        }
