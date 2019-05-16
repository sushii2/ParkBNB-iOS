//
//  ProfileVC.swift
//  ShakshamHW
//
//  Created by Saksham Saraswat on 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SVProgressHUD

class ProfileVC: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var firstNameTxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var birthDateTxt: UITextField!
    
    var imagePicker : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        birthDateTxt.delegate = self
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImage)))
        
        fetchProfile()
    }
    
    func fetchProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("users/\(userID)")
        SVProgressHUD.show()
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                self.showMessage(title: "Oops", message: "You haven't setup your profile yet!")
                SVProgressHUD.dismiss()
                return
            }
            
            let value = snapshot.value as? NSDictionary
            if let firstname = value?.value(forKey: "firstname") as? String {
                self.firstNameTxt.text = firstname
            }
            if let lastname = value?.value(forKey: "lastname") as? String {
                self.lastNameTxt.text = lastname
            }
            if let birthdate = value?.value(forKey: "birthday") as? String {
                self.birthDateTxt.text = birthdate
            }
            if let profile = value?.value(forKey: "profileimage") as? String {
                self.profileImageView.downloaded(from: profile, contentMode: UIView.ContentMode.scaleAspectFill)
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
        })
    }
    
    @objc func onImage() {
        let alertSheet = UIAlertController(title: "Choose", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (action) in
            self.checkForCameraPermission(completion: { (permitted) in
                if permitted {
                    self.showMediaController(sourceType: UIImagePickerController.SourceType.camera)
                } else {
                    self.showMessage(title: "Oops", message: "Camera permission is not given!")
                }
            })
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) { (action) in
            self.checkForGalleryPermission(completion: { (permitted) in
                if permitted {
                    self.showMediaController(sourceType: UIImagePickerController.SourceType.photoLibrary)
                } else {
                    self.showMessage(title: "Oops", message: "Gallery permission is not given!")
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertSheet.addAction(cameraAction)
        alertSheet.addAction(galleryAction)
        alertSheet.addAction(cancelAction)
        
        present(alertSheet, animated: true, completion: nil)
    }
    
    func showMediaController(sourceType:UIImagePickerController.SourceType) {
        imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            showMessage(title: "Oops", message: "This media type is not supported!")
        }
    }

    @IBAction func clk_update(_ sender: UIButton) {
        let ref: DatabaseReference = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let firstname = firstNameTxt.text,
              !firstNameTxt.isBlank() else {
            showMessage(title: "Oops", message: "Please enter first name")
            return
        }
        guard let lastname = lastNameTxt.text,
                !lastNameTxt.isBlank() else {
            showMessage(title: "Oops", message: "Please enter last name")
            return
        }
        guard let birthdate = birthDateTxt.text,
                !birthDateTxt.isBlank() else {
            showMessage(title: "Oops", message: "Please select birthday")
            return
        }
        guard let profileimage = profileImageView.image else {
            showMessage(title: "Oops", message: "Please select image")
            return
        }
        
        SVProgressHUD.show()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
        guard let imageData = profileimage.jpegData(compressionQuality: 0.5) else {return}
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("/profile/\(imagename).jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                return
            }
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
                ref.child("users").child(userID).setValue(["firstname": firstname,"lastname": lastname,"birthday": birthdate, "profileimage" : url?.absoluteString ?? ""])
            }
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension ProfileVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let datePicker = storyboard?.instantiateViewController(withIdentifier: "BirthdayVC") as? BirthdayVC else {return false}
        present(datePicker, animated: true, completion: nil)
        datePicker.dateAction = { (date) in
            textField.text = date.formattedDateString()
        }
        return false
    }
}

extension ProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = edited
        } else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = original
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
