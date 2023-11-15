//
//  LoginVC.swift
//  FireBaseApp
//
//  Created by Kate on 12/11/2023.
//

import Firebase
import FirebaseAuth
import FirebaseStorage
import UIKit

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
        // наблюдатель за значениями
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
    
    @IBAction func addNewImage(_ sender: UIBarButtonItem) {
        let storageRef = Storage.storage().reference()
        let imageKey = NSUUID().uuidString
        let imageRef = storageRef.child(imageKey)
        guard let imageData = #imageLiteral(resourceName: "image.jpeg").pngData() else { return }
        let uploadTask = imageRef.putData(imageData) { storageMetadata, error in
            print("\nstorageMetadata:\n\(storageMetadata)\n")
            print("\nerror:\n\(error)\n")
            /// тут мы дальше записываем в DB нашего юзера imageKey
            /// тоже самое можно проделать если вы решили использовать Thumbnails
            
            // MARK: - а теперь загрузим картинку
            
            let downloadTask = imageRef.getData(maxSize: 999999999999999) { data, error in
                print("\n data: \n\(data)\n")
                print("\n error:\n\(error)\n")
                let image = UIImage(data: data!)
                print(image)
            }
        }
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
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isComplete = !task.completed
        /// изменим ячейку
        // toggleColetion(cell: cell, isCompleted: isComplete) - в этом нет смысла так как мы имеем ref.observe
        /// запишем данные на сервер
        task.ref.updateChildValues(["completed": isComplete])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let task = tasks[indexPath.row]
        task.ref.removeValue()
    }
}
