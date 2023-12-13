//
//  InitialViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit


@available(iOS 15.0, *)
var ai_model = aiModel()

@available(iOS 15.0, *)
class InitialViewController: UIViewController {
    
    // MARK: - IBOutlets/Properties/ViewLoad
    @IBOutlet weak var transcriptScrollView: UIScrollView!
    @IBOutlet weak var transcriptTextView: UITextView!
    @IBOutlet weak var dictationButton: UIButton!
    
    
    @IBOutlet weak var notesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // button UI settings
        dictationButton.layer.cornerRadius = dictationButton.bounds.size.height / 2
        notesButton.layer.cornerRadius = notesButton.bounds.size.height / 2
        
        setupButtonActions()
    }

        // MARK: - ViewController Functions
        private func setupButtonActions() {
            dictationButton.addTarget(self, action: #selector(startDictation), for: .touchDown)
            dictationButton.addTarget(self, action: #selector(stopDictation), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        
        @objc func startDictation() {
            Task {
                ai_model.speechRecognizer.startTranscribing()
            }
        }
        
        @objc func stopDictation() {
            Task {
                ai_model.speechRecognizer.stopTranscribing()
                updateTranscript(with: ai_model.speechRecognizer.transcript + ".")
                updateTranscript(with: ai_model.classifyText(ai_model.speechRecognizer.transcript))
                updateTranscript(with: "")
                ai_model.speechRecognizer.resetTranscript()
            }
        }
        
        func updateTranscript(with text: String) {
            DispatchQueue.main.async { [weak self] in
                self?.transcriptTextView.text += "\n" + text
                print(self!.transcriptTextView.text!)
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
    
