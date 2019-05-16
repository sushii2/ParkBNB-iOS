//
//  HomeVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
import Cosmos

class HomeVC: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var detailView:UIView!
    @IBOutlet var rateView: CosmosView!
    @IBOutlet var descriptionLbl: UILabel!
    
    var annotations:[MKAnnotation] = []
    var parkingModels:[ParkingModel] = []
    
    var currentParking:ParkingModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        detailView.alpha = 0
        
        rateView.didFinishTouchingCosmos = { (rating) in
            var reference = Database.database().reference().child("parkings")
            reference.queryOrdered(byChild: "lat").queryEqual(toValue: self.currentParking!.lat).observe(DataEventType.value, with: { (snapshot) in
                if !snapshot.exists() {return}
                guard let dict = snapshot.value as? NSDictionary else {return}
                guard let key = dict.allKeys.first as? String else {return}
                Database.database().reference().child("parkings").child(key).child("rating").setValue(String(Int(rating)))
                print(dict)
            })
        }
        
        Database.database().reference().child("parkings").observe(DataEventType.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? NSDictionary else {return}
            dictionary.toModel(completion: { (parking:ParkingModel) in
                self.parkingModels.append(parking)
                self.createMarker(parking: parking)
            })
        }
        
        Database.database().reference().child("parkings").observe(DataEventType.childChanged) { (snapshot) in
            guard let dictionary = snapshot.value as? NSDictionary else {return}
            
            dictionary.toModel(completion: { (parking:ParkingModel) in
                guard let index = self.parkingModels.firstIndex(where: { $0.lat == parking.lat }) else {return}
                self.parkingModels[index] = parking
            })
        }
    }
    
    func createMarker(parking:ParkingModel) {
        let pin = MKPointAnnotation()
        pin.title = parking.description
        
        guard let lattitude = Double(parking.lat) else {return}
        guard let longitude = Double(parking.long) else {return}
        
        pin.coordinate = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
        
        pin.accessibilityHint = String(annotations.count)
        
        annotations.append(pin)
        mapView.addAnnotation(pin)
    }
    @IBAction func clk_more(_ sender: UIButton) {
        guard let detail = storyboard?.instantiateViewController(withIdentifier: "ParkingDetailVC") as? ParkingDetailVC else {
            return
        }
        
        present(detail, animated: true, completion: nil)
        detail.parking = currentParking
        
    }
    @IBAction func clk_cancel(_ sender: UIButton) {
        detailView.alpha = 0
        currentParking = nil
    }
    
}

extension HomeVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let pin = view.annotation as? MKPointAnnotation else {return}
        guard let hint = pin.accessibilityHint,let index = Int(hint) else {return}
        
        currentParking = parkingModels[index]
        let rating  = Int(currentParking?.rating ?? "0") ?? 0
        
        rateView.rating = rating == 0 ? Double(5) : Double(rating)
        descriptionLbl.text = currentParking?.description ?? ""
        
        
        detailView.alpha = 1
        
    }
}
