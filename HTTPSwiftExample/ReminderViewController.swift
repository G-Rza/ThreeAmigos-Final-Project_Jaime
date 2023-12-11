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
class ReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private let remindersKey = "remindersKey"
    private var reminders: [Reminder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadReminders()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = savedReminders
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let reminder = reminders[indexPath.row]
        cell.textLabel?.text = "\(reminder.text) - \(reminder.date.formatted())"
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            reminders.remove(at: indexPath.row)
            saveReminders()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReminder = reminders[indexPath.row]
        showEditReminderViewController(reminder: selectedReminder, index: indexPath)
    }

    // reminders are saved
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }

    // add reminder function
    @IBAction func addReminderTapped(_ sender: UIButton) {
        showEditReminderViewController(reminder: nil, index: nil)
    }

    // shows our modal to create new reminder
    private func showEditReminderViewController(reminder: Reminder?, index: IndexPath?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditReminderViewController") as? EditReminderViewController {
            editVC.reminder = reminder
            editVC.saveAction = { [weak self] updatedReminder in
                if let index = index {
                    self?.reminders[index.row] = updatedReminder
                } else {
                    self?.reminders.append(updatedReminder)
                }
                self?.saveReminders()
                self?.tableView.reloadData()
            }
            present(editVC, animated: true, completion: nil)
        }
    }
}
