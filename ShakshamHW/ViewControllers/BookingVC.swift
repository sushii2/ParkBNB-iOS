//
//  BookingVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 15/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BookingVC: UIViewController,UITextFieldDelegate {

    @IBOutlet var fromTxt: UITextField!
    @IBOutlet var toTxt: UITextField!
    
    var fromDate : String = ""
    var toDate : String = ""
    
    var parking : ParkingModel!
    
    typealias bookClosure = (String) -> Void
    var bookAction:bookClosure? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fromTxt.delegate = self
        toTxt.delegate = self
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        guard let datePicker = storyboard?.instantiateViewController(withIdentifier: "BirthdayVC") as? BirthdayVC else {return false}
        present(datePicker, animated: true, completion: nil)
        datePicker.dateAction = { (date) in
            textField.text = date.formattedDateString()
            if textField.isEqual(self.fromTxt) {
                self.fromDate = textField.text!
            } else {
                self.toDate = textField.text!
            }
        }
        return false
    }
    
    @IBAction func clk_book(_ sender: UIButton) {
        if fromDate.isEmptyOrWhitespace() {
            showMessage(title: "Oops", message: "Please select From Date")
        } else if toDate.isEmptyOrWhitespace() {
            showMessage(title: "Oops", message: "Please select to Date")
        } else {
            let reference = Database.database().reference().child("parkings")
            reference.queryOrdered(byChild: "lat").queryEqual(toValue: self.parking.lat).observe(DataEventType.value, with: { (snapshot) in
                if !snapshot.exists() {return}
                guard let dict = snapshot.value as? NSDictionary else {return}
                guard let key = dict.allKeys.first as? String else {return}
                Database.database().reference().child("parkings").child(key).child("booking").setValue("From \(self.fromDate) To \(self.toDate)")
                print(dict)
            })
            self.dismiss(animated: true) {
                self.bookAction?("From \(self.fromDate) To \(self.toDate)")
            }
        }
    }
    @IBAction func clk_cancel(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
            self.bookAction?("Available")
        }
    }
    
}
