//
//  ReminderViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import Foundation
import UIKit

struct Reminder: Codable {
    var text: String
    var date: Date
}

@available(iOS 15.0, *)
class ReminderViewController: UIViewController {
    
    private let remindersKey = "remindersKey"
    private var reminders: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReminders()
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = savedReminders
        }
    }

    // MARK: - Reminder Implementation Functions

    // Function to save a new reminder
    public func saveNewReminder(_ reminderText: String, date: Date) {
        guard !reminderText.isEmpty else { return }
        let newReminder = Reminder(text: reminderText, date: date)
        reminders.append(newReminder)
        saveReminders()
    }
    
    // Function to encode and save reminders to UserDefaults
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }
    
    // Shows our modal to create new reminder
    private func showEditReminderViewController(reminder: Reminder?, index: IndexPath?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditReminderViewController") as? EditReminderViewController {
            editVC.reminder = reminder
            editVC.saveAction = { [weak self] updatedReminder in
                if let index = index {
                    self?.reminders[index.row] = updatedReminder
                } else {
                    self?.saveNewReminder(updatedReminder.text, date: updatedReminder.date)
                }
            }
            present(editVC, animated: true, completion: nil)
        }
    }
    
}
