//
//  ViewController.swift
//  FireBaseApp
//
//  Created by Kate on 08/11/2023.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
    
    var ref: DatabaseReference!
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    
    @IBOutlet var warnLbl: UILabel!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warnLbl.alpha = 0
        ref = Database.database().reference(withPath: "users")
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            guard let _ = user else { return }
            self?.performSegue(withIdentifier: "goToTasksTVC", sender: nil)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // читим поля
        emailTF.text = nil
        passwordTF.text = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }
    
    @IBAction func loginAction() {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passwordTF.text, !pass.isEmpty
        else {
            displayWarningLabel(withText: "Info is incorect")
            return
        }
        
        // create new user
        
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "SignIn was incorect \n error = \(error)")
            } else if let _ = user {
//                self?.performSegue(withIdentifier: "goToTasksTVC", sender: nil) /// это не нужно тк у нас есть authStateDidChangeListenerHandle
            } else {
                self?.displayWarningLabel(withText: "No such user")
            }
        }
    }
    
    @IBAction func registrationAction() {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passwordTF.text, !pass.isEmpty
        else {
            displayWarningLabel(withText: "Info is incorect")
            return
        }
        
        // create new user
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "Registration was incorect \n error = \(error)")
            } else if let user = user {
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
        }
    }
    
    private func displayWarningLabel(withText text: String) {
        warnLbl.text = text
        UIView.animate(
            withDuration: 3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.warnLbl.alpha = 1
            }
        ) { [weak self] _ in
            self?.warnLbl.alpha = 0
            self?.warnLbl.text = nil
        }
    }
    
    @objc private func kbWillShow(notification: Notification) {
        view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= (keyboardSize.height / 2)
        }
    }
    
    
    @objc private func kbWillHide() {
        view.frame.origin.y = 0
    }

    deinit {
        print("!!! deinited LoginVC")
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
