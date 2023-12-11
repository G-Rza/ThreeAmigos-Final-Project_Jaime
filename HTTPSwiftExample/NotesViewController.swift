//
//  NotesViewController.swift
//  HTTPSwiftExample
//
//  Created by Hans Soland on 12/10/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private let notesKey = "notesKey"
    private var notes: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set the row height to automatic dimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44  // Change this value based on your average cell height
    }

    // loads our notes
    private func loadNotes() {
        let savedNotes = UserDefaults.standard.array(forKey: notesKey) as? [String] ?? []
        notes = savedNotes
        tableView.reloadData()
    }

    // MARK: - UITableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0  // allows unlimited lines
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = notes[indexPath.row]
        return cell
    }

    // enable swipe to deletes
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            UserDefaults.standard.set(notes, forKey: notesKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - UITableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        presentEditAlert(for: indexPath, with: selectedNote)
    }

    // alert to edit the note
    private func presentEditAlert(for indexPath: IndexPath, with note: String) {
        let alertController = UIAlertController(title: "Edit Note", message: "Edit your note", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = note
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let updatedNote = textField.text else { return }
            self?.updateNote(at: indexPath.row, with: updatedNote)
        }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // update the note in the array and reload the table view
    private func updateNote(at index: Int, with note: String) {
        guard !note.isEmpty else { return }
        notes[index] = note
        UserDefaults.standard.set(notes, forKey: notesKey)
        tableView.reloadData()
    }

    // MARK: - Actions
    // creates new note view
    @IBAction func addNoteButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New Note", message: "Enter your note", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Note"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let noteToAdd = textField.text else { return }
            self?.saveNewNote(noteToAdd)
        }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // saves new note in table
    private func saveNewNote(_ note: String) {
        guard !note.isEmpty else { return }
        notes.append(note)
        UserDefaults.standard.set(notes, forKey: notesKey)
        tableView.reloadData()
    }
}
