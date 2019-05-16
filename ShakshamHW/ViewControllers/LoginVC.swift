//
//  ViewController.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController {

    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTxt.text = "test@gmail.com"
        passwordTxt.text = "123456"
    }
    @IBAction func clk_sign_up(_ sender: UIButton) {
        guard let signUp = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") else {return}
        present(signUp, animated: true, completion: nil)
    }
    @IBAction func clk_login(_ sender: UIButton) {
        if emailTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter email")
        } else if !emailTxt.isValidEmail() {
            showMessage(title: "Oops", message: "Please enter valid email")
        } else if passwordTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter password")
        } else {
            login()
        }
    }
    
    func loginSuccess() {
        guard let homeTab = storyboard?.instantiateViewController(withIdentifier: "HomeTab") else {return}
        present(homeTab, animated: true, completion: nil)
    }
    
    func login() {
        FirebaseHelper.login(email: emailTxt.text!, password: passwordTxt.text!) { (error) in
            guard let errmessage = error?.localizedDescription else {
                
                self.loginSuccess()
                return
            }
            self.showMessage(title: "Oops", message: errmessage)
        }
    }

}

