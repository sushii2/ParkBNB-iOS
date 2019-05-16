//
//  AddParkingVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 15/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase

class AddParkingVC: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var typeTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextView!
    @IBOutlet var featureTxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let place = MKPointAnnotation()
        place.title = "Parking Place"
        place.coordinate = touchMapCoordinate
        mapView.addAnnotation(place)
    }
    
    @IBAction func clk_add(_ sender: UIButton) {
        guard let pin = mapView.annotations.first else {
            showMessage(title: "Oops", message: "Please select any place on map")
            return
        }
        if typeTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter parking type")
        } else if priceTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter parking rent")
        } else if descriptionTxt.text.isEmptyOrWhitespace() {
            showMessage(title: "Oops", message: "Please enter parking description")
        } else if featureTxt.text.isEmptyOrWhitespace() {
            showMessage(title: "Oops", message: "Please enter parking features")
        } else {
            addParking(pin: pin)
        }
    }
    
    func addParking(pin:MKAnnotation) {
        SVProgressHUD.show()
        let ref: DatabaseReference = Database.database().reference().child("parkings").childByAutoId()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
    
        
        ref.setValue(["userId" : userID, "type" : typeTxt.text!,
                                        "price" : priceTxt.text!, "description" : descriptionTxt.text!,
                                        "feature" : featureTxt.text!,
                                        "lat" : String(describing: pin.coordinate.latitude),
                                        "long" : String(describing: pin.coordinate.longitude),
                                        "rating" : "0",
                                        "booking" : "Available"])
        
        SVProgressHUD.dismiss()
        typeTxt.text = ""
        priceTxt.text = ""
        descriptionTxt.text = ""
        featureTxt.text = ""
        mapView.removeAnnotations(mapView.annotations)
        
        showMessage(title: "Wow", message: "Parking is added successfully")
    }
    
}

extension AddParkingVC : MKMapViewDelegate {
    
}
