//
//  Extenstions.swift
//  ShakshamHW
//
//  Created by Bapu on 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

extension NSDictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func toModel<T: Decodable>(completion: @escaping (T) -> ()) {
        do {
            let obj = try JSONDecoder().decode(T.self, from: self.json.data(using: String.Encoding.utf8)!)
            completion(obj)
        } catch {
            print(error) // any decoding error will be printed here!
        }
    }
    
}

extension UITextField {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text ?? "")
    }
    
    func isBlank() -> Bool {
        return self.text?.isEmptyOrWhitespace() ?? true
    }
}

extension Date {
    func formattedDateString() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        
        return "\(String(format: "%02d", day))-\(String(format: "%02d", month))-\(String(describing: year))"
    }
}

extension UIViewController {
    func showMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func checkForCameraPermission(completion:@escaping ((_ permitted:Bool) -> Void)) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                completion(granted)
            })
        }
    }
    
    func checkForGalleryPermission(completion:@escaping ((_ permitted:Bool) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            completion(true)
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            completion(false)
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                completion(newStatus == .authorized)
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
            completion(false)
        }
    }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if(self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
    }
}
