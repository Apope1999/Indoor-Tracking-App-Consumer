//
//  RegisterViewController.swift
//  IndoorTrackingAppConsumer
//
//  Created by Apostolos Pezodromou on 8/5/20.
//  Copyright © 2020 Apostolos Pezodromou. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Firebase Error", message: e.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                } else {
                    self.performSegue(withIdentifier: K.Segues.goMainMenu, sender: self)
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Log Out"
        backItem.tintColor = UIColor.red
        self.navigationItem.backBarButtonItem = backItem
    }
}
