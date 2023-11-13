//
//  LoginVC.swift
//  FireBaseApp
//
//  Created by Kate on 12/11/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class TasksTVC: UITableViewController {
    
    private var user: User!
    private var tasks = [Task]()
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // достаем текущего user
        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(user.uid).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [weak self] snapshot in
            var tasks = [Task]()
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot,
                      let task = Task(snapshot: snapshot) else { return }
                tasks.append(task)
            }
            self?.tasks = tasks
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func addNewTaskAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Add new task title", preferredStyle: .alert)
        alertController.addTextField()
        /// action 1
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self,
                  let textField = alertController.textFields?.first,
                  let text = textField.text else { return }
            let uid = user.uid
            /// создаем  task
            let task = Task(title: text, userId: uid)
            /// создаем Ref на task
            let taskRef = ref.child(task.title.lowercased())
            /// отправляем на сервер
            taskRef.setValue(task.convertToDictionary())
        }
        /// action 2
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func toggleColetion(cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        cell.textLabel?.text = currentTask.title
        toggleColetion(cell: cell, isCompleted: currentTask.completed)
        return cell
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
