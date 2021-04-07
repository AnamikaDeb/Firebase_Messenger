//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Anamika Deb on 31/8/20.
//  Copyright © 2020 Anamika Deb. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func registerTapped(_ sender: Any) {
        print("Register Tapped")
        
        guard let firstNameField = firstNameField.text, let lastNameField = lastNameField.text, let emailField = emailField.text, let passwordField = passwordField.text else {
            return
        }
        DatabaseManager.shared.userExists(with: emailField, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else
            {
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: {authResult, error in
                
                guard authResult != nil, error == nil else
                {
                    return
                }
                let chatUser = ChatAppUser(firstName: firstNameField,
                lastName: lastNameField,
                emailAddress: emailField)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imageView.image,
                            let data = image.pngData() else {
                                return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage maanger error: \(error)")
                            }
                        })
                    }                })
                strongSelf.navigationController?.popViewController(animated: true)
            })
        })
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        print("Back Tapped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Register"
    }
}
