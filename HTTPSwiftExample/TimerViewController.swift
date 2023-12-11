//
//  TimerViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit


class TimerViewController: UIViewController {

    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIDatePicker!  // Date picker to set countdown time

    private var timer: Timer?
    private var remainingTime: Int = 0  // Time in seconds for countdown

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimerLabel()
        countdownPicker.isHidden = false  // Show picker initially
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        startTimer()
        countdownPicker.isHidden = true  // hide picker when timer starts
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopTimer()
        countdownPicker.isHidden = false
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetTimer()
        countdownPicker.isHidden = false  // show picker again when timer is reset
    }

    private func startTimer() {
        _ = Int(countdownPicker.countDownDuration)
        remainingTime = Int(countdownPicker.countDownDuration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        countdownPicker.isHidden = false
    }

    private func resetTimer() {
        stopTimer()
        remainingTime = 0
        updateTimerLabel()
    }

    @objc private func updateTime() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            countdownPicker.isHidden = false  // shows picker when countdown finishes
        }
    }

    // updates our label with time
    private func updateTimerLabel() {
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
