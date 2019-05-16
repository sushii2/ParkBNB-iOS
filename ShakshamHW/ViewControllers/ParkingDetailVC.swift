//
//  ParkingDetail.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 15/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ParkingDetailVC: UIViewController {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var featureLbl: UILabel!
    @IBOutlet var bookingLbl: UILabel!
    @IBOutlet var bookingBtn: UIButton!
    
    var parking:ParkingModel? = nil {
        didSet {
            if let data = parking {
                typeLbl.text = "Type: \(data.type)"
                priceLbl.text = "Price: \(data.price)/Hour"
                descriptionLbl.text = "Description: \(data.description)"
                featureLbl.text = "Feature: \(data.feature)"
                bookingLbl.text = "Booking: \(data.booking)"
                
                if (data.booking == "Available") {
                    bookingBtn.setTitle("Book Parking", for: UIControl.State.normal)
                } else {
                    bookingBtn.setTitle("Cancel Booking", for: UIControl.State.normal)
                }
                
                
                let userId = data.userId
                    let ref = Database.database().reference().child("users/\(userId)")
                    ref.observeSingleEvent(of: .value, with: { snapshot in
                        
                        if !snapshot.exists() { return }
                        
                        let value = snapshot.value as? NSDictionary
                        if let firstname = value?.value(forKey: "firstname") as? String {
                            self.userNameLbl.text = "Hosted By: \(firstname)"
                        }
                        if let profile = value?.value(forKey: "profileimage") as? String {
                            self.profileImage.downloaded(from: profile, contentMode: UIView.ContentMode.scaleAspectFill)
                        }
                    })

                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func clk_booking(_ sender: UIButton) {
        if (parking!.booking == "Available") {
            let booking = storyboard?.instantiateViewController(withIdentifier: "BookingVC") as! BookingVC
            present(booking, animated: true, completion: nil)
            booking.parking = parking
            booking.bookAction = { status in
                self.bookingLbl.text = "Booking: " + status
                self.parking?.booking = status
                if let homeVC = (self.presentingViewController as? UITabBarController)?.selectedViewController as? HomeVC {
                    homeVC.detailView.alpha = 0
                }
            }
        } else {
            let reference = Database.database().reference().child("parkings")
            reference.queryOrdered(byChild: "lat").queryEqual(toValue: self.parking!.lat).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                if !snapshot.exists() {return}
                guard let dict = snapshot.value as? NSDictionary else {return}
                guard let key = dict.allKeys.first as? String else {return}
                Database.database().reference().child("parkings").child(key).child("booking").setValue("Available")
                if let homeVC = (self.presentingViewController as? UITabBarController)?.selectedViewController as? HomeVC {
                    homeVC.detailView.alpha = 0
                }
                self.parking?.booking = "Available"
            }
        }
        
    }
    @IBAction func clk_close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
