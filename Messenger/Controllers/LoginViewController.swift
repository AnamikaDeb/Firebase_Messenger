//
//  ViewController.swift
//  Messenger
//
//  Created by Anamika Deb on 31/8/20.
//  Copyright © 2020 Anamika Deb. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func loginTapped(_ sender: Any) {
        print("Login Tapped")
        guard let emailField = emailField.text, let passwordField = passwordField.text else {
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: emailField, password: passwordField, completion: {authResult, error in
           
            guard let authResult = authResult, error == nil else
            {
                return
            }
            let user = authResult.user
            print("Logged in User: \(user)")
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: emailField)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })

            UserDefaults.standard.set(emailField, forKey: "email")
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        print("Register Tapped")
        
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Login"
        self.navigationItem.hidesBackButton = true
    }
}

