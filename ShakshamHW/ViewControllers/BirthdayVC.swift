//
//  BirthdayVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 15/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit

class BirthdayVC: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    
    typealias dateClosure = (Date) -> Void
    var dateAction:dateClosure? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
    }
    
    @IBAction func clk_done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.dateAction?(self.datePicker.date)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
