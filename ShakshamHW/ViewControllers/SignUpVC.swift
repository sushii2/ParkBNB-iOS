//
//  SignUpVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpVC: UIViewController {

    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var confirmPasswordTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clk_login(_ sender: UIButton) {
        guard let login = storyboard?.instantiateViewController(withIdentifier: "LoginVC") else {return}
        present(login, animated: true, completion: nil)
    }
    @IBAction func clk_sign_up(_ sender: UIButton) {
        if emailTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter email")
        } else if !emailTxt.isValidEmail() {
            showMessage(title: "Oops", message: "Please enter valid email")
        } else if passwordTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter password")
        } else if confirmPasswordTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter confirmation password")
        } else if passwordTxt.text != confirmPasswordTxt.text {
            showMessage(title: "Oops", message: "Password and confirm password does not match")
        } else {
            signUp()
        }
    }
    
    func signUp() {
        FirebaseHelper.signUp(email: emailTxt.text!, password: passwordTxt.text!) { (error) in
            guard let errmessage = error?.localizedDescription else {return}
            self.showMessage(title: "Oops", message: errmessage)
        }
    }

}
