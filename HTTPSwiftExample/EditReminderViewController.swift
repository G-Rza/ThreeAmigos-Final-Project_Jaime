//
//  EditReminderViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/11/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import Foundation
import UIKit

class EditReminderViewController: UIViewController {
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    var reminder: Reminder? // for editing an existing reminder
    var saveAction: ((Reminder) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets up the view with existing reminder data if available
        if let reminder = reminder {
            reminderTextField.text = reminder.text
            datePicker.date = reminder.date
        }
    }

    // saves our note
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let updatedReminder = Reminder(text: reminderTextField.text ?? "", date: datePicker.date)
        saveAction?(updatedReminder)
        dismiss(animated: true, completion: nil)
    }

    // cancles the modal
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
