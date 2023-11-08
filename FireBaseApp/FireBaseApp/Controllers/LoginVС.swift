//
//  ViewController.swift
//  FireBaseApp
//
//  Created by Kate on 08/11/2023.
//

import Firebase
import UIKit

class LoginVC: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet var warnLbl: UILabel!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warnLbl.alpha = 0
        
        ref = Database.database().reference(withPath: "users")
    }
    
    @IBAction func registrationAction() {
        guard let email = emailTF.text,
              let pass = passwordTF.text,
              !email.isEmpty,
              !pass.isEmpty
        else {
            // TODO: - "Info is incorect"
            return
        }
        
        // create new user
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                print(error)
                // TODO: - "Info is incorect"
            } else if let user = user {
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
        }
    }
}
    
