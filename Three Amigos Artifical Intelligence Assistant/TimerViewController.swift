//
//  TimerViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

@available(iOS 15.0, *)
class TimerViewController: UIViewController {

    // MARK: - IBOutlets/Properties/ViewLoad
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    private var timer: Timer?
    private var remainingTime: Int = 0
    private let timerStartTimeKey = "timerStartTime"
    private let timerDurationKey = "timerDuration"

    override func viewDidLoad() {
        super.viewDidLoad()

        stopButton.layer.cornerRadius = stopButton.bounds.size.height / 2
        resetButton.layer.cornerRadius = resetButton.bounds.size.height / 2

        updateTimerLabel()
        checkAndRestartTimerIfNeeded()
    }
    
    // MARK: - Timer Functions and Button Functions

    func setAndStartTimer(_ duration: Int){
        remainingTime = duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopTimer()
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
        UserDefaults.standard.removeObject(forKey: timerStartTimeKey)
        UserDefaults.standard.removeObject(forKey: timerDurationKey)
    }

    private func resetTimer() {
        stopTimer()
        remainingTime = 0
        updateTimerLabel()
    }

    private func checkAndRestartTimerIfNeeded() {
        guard let startTime = UserDefaults.standard.object(forKey: timerStartTimeKey) as? Date,
              let duration = UserDefaults.standard.integer(forKey: timerDurationKey) as? Int,
              duration > 0 else { return }

        let elapsed = Int(Date().timeIntervalSince(startTime))
        let remaining = duration - elapsed
        if remaining > 0 {
            setAndStartTimer(remaining)
        } else {
            UserDefaults.standard.removeObject(forKey: timerStartTimeKey)
            UserDefaults.standard.removeObject(forKey: timerDurationKey)
        }
    }

    @objc private func updateTime() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            UserDefaults.standard.removeObject(forKey: timerStartTimeKey)
            UserDefaults.standard.removeObject(forKey: timerDurationKey)
            ai_model.notifyUserTimerFinished()
        }
    }

    private func updateTimerLabel() {
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        if timerLabel != nil {
            timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}
