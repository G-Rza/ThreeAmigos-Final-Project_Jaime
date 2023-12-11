//
//  InitialViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import Speech

class InitialViewController: UIViewController {
    
    // MARK: - IBOutlets/Properties/ViewLoad
    @IBOutlet weak var transcriptScrollView: UIScrollView!
    @IBOutlet weak var transcriptTextView: UITextView!
    @IBOutlet weak var dictationButton: UIButton!
   
    private let speechRecognizer = SpeechRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
    
    // MARK: - Methods/Functions
    private func setupButtonActions() {
        dictationButton.addTarget(self, action: #selector(startDictation), for: .touchDown)
        dictationButton.addTarget(self, action: #selector(stopDictation), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc func startDictation() {        Task {
            await speechRecognizer.startTranscribing()
        }
    }

    @objc func stopDictation() {
        Task {
            await speechRecognizer.stopTranscribing()
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
