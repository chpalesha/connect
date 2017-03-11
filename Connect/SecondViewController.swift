//
//  SecondViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class SecondViewController: UIViewController,CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate{

    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    var userid = String()
    var category = Array<Category>()
    var categoryArray = Array<String>()
    @IBOutlet weak var pvDropDown: UIPickerView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ivForComplain: UIImageView!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initViews()
        
        //check if user is logged in if yes gets its userID
        if let uid = getUserID() {
            self.userid = uid
        }
    }
    
    //initilizes ui elements
    func initViews(){
        tvDescription.layer.borderColor = UIColor.darkText.cgColor
        tvDescription.layer.borderWidth = 1.0;
        tvDescription.layer.cornerRadius = 5.0;
        tvDescription.textColor = UIColor.darkText
        
        tfCategory.layer.borderColor = UIColor.darkText.cgColor
        tfCategory.layer.borderWidth = 1.0;
        tfCategory.layer.cornerRadius = 5.0;
        tfCategory.textColor = UIColor.darkText
        
        self.tvDescription.delegate = self
        self.tfCategory.delegate = self
        
        getLocation()
        getCategories()
    }
    
    //get different categories and updates uipicker
    func getCategories(){
        //gets firebase refernece
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let categoryRef = ref.child("category")
        //adds obserer (.value->updates value in real time)
        categoryRef.observe(.value, with: {(snapshot) in
            //unwraps snapshot to dictionary
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>{
                for (k,_) in dictionary{
                    //appends categoryArray with different category fetched from firebase
                    self.categoryArray.append(k)
                }
            }
            DispatchQueue.main.async {
                //updates category uipicker
                self.pvDropDown.reloadAllComponents()
            }
        })
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.tvDescription.text == "Description" {
            self.tvDescription.text = ""
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.tvDescription.text == "" {
            self.tvDescription.text = "Description"
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    
    
    @IBAction func textFieldStartEdit(_ sender: Any) {
        self.pvDropDown.isHidden = false
        self.ivForComplain.isHidden = true
    }
    
   //if user is logged in returns userid
    func getUserID() -> String?{
        //to check if user is signed in
        guard let userid = FIRAuth.auth()?.currentUser?.uid else{
            generateAlert(title: "Error", message: "Sorry unable to get user id")
            return nil
        }
        return userid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //if tapped on imageview
    @IBAction func selectFromPhotos(_ sender: UITapGestureRecognizer) {
        //open camera to take a picture
        let alert = UIAlertController(title: "Picture", message: "Select from where to upload", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.getImageFromCamera()
        })
        let libAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction!) in
            self.getImageFromLib()
        })
        alert.addAction(cameraAction)
        alert.addAction(libAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getImageFromCamera(){
        //check if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: getImageFromLib)
        }else{
            //else pen phot library to select photo
            getImageFromLib()
        }
    }
    
    //open photo library to get photo
    func getImageFromLib() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //stores complain into firebase and updates ui element fields
    @IBAction func bOKPressed(_ sender: Any) {
        if self.locValue.latitude != 0 && self.locValue.longitude != 0{
            handleComplain()
            self.tfCategory.endEditing(true)
            self.tvDescription.endEditing(true)
            self.tvDescription.text = "Description"
            self.tfCategory.text = ""
            self.ivForComplain.image = #imageLiteral(resourceName: "upload")
        }else{
            generateAlert(title: "Error", message: "Sorry! Unable to get location")
        }
    }
    
    //stores complain details to firebase
    func handleComplain(){
        //check if any entry is nil
        guard let category = self.tfCategory.text, let description = self.tvDescription.text else {
            return
        }
        
        //check if any entry is empty
        guard category != "", description != "Description" else{
            generateAlert(title: "Error", message: "Category/Description field is missing")
            return
        }
        
        //assign name to image randomly and unique
        let imageName = NSUUID().uuidString
        //storage refernece to image
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        //convert ui image to png representation
        if let uploadData = UIImagePNGRepresentation(self.ivForComplain.image!){
            //if successful upload image
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                //if image uploaded successfully imageurl will contain it's url
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    //update values for registering complain
                    let values = ["category": category, "desc": description, "image": imageURL, "uid": self.userid, "latitude": String(self.locValue.latitude), "longitude": String(self.locValue.longitude), "status": "processing"]
                    //update counter in status
                    self.registerStatus()
                    //update counter in category
                    self.registerCategory(of: category)
                    //register complain
                    self.registerComplain(cid: imageName, values: values as [String : AnyObject])
                }
            })
        }
    }
    
    //update counter in status
    func registerStatus(){
        var flag = 0
        var updateProcessingValue = Int()
        //get firebase refernece
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let statusRef = ref.child("status")
        //adding observer on status (.value -> real-time update)
        statusRef.observe(.value, with: {(snapshot) in
            //unwrap snapshot to dictionary
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, value) in dictionary {
                    if key == "processing" {
                        updateProcessingValue = value as! Int
                    }
                }
            }
            //flag to update counter once, because of adding observer there can be multiple calls and multiple updates to count of status.
            flag = flag + 1
            if flag == 1{
                updateProcessingValue = updateProcessingValue + 1
                //update status on firebase
                statusRef.updateChildValues(["processing": updateProcessingValue], withCompletionBlock: { (error, ref) in
                    if error != nil{
                        return
                    }
                })
            }
        })
    }
    
    //update cateogry counter on firebase
    func registerCategory(of category: String){
        var flag = 0
        var updateProcessingValue = Int()
        //get firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let statusRef = ref.child("category")
        //adding observer to cateogry (.value -> to get real-time updates)
        statusRef.observe(.value, with: {(snapshot) in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, value) in dictionary {
                    if key == category {
                        updateProcessingValue = value as! Int
                    }
                }
            }
            //flag to update counter once, because of adding observer there can be multiple calls and multiple updates to count of status.
            flag = flag + 1
            if flag == 1{
                updateProcessingValue = updateProcessingValue + 1
                //update count of category
                statusRef.updateChildValues([category: updateProcessingValue], withCompletionBlock: { (error, ref) in
                    if error != nil{
                        return
                    }
                })
            }
        })
    }
    
    //register complain complain on Firebase
    private func registerComplain(cid:String, values: [String: AnyObject]){
        //get firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let complainRef = ref.child("complain").child(cid)
        
        //add complain to Firebase
        complainRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                return
            }
            //if successfull give user confirmation
            DispatchQueue.main.async {
                self.generateAlert(title: "Success", message: "Your Opinion has been submitted. Thank You !")
            }
        })
    }
    
    //gives dialoguebox with title, message and ok button
    func generateAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            ivForComplain.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }

    //location functions
    //gets current location of user
    func getLocation(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
    }
    
    
    //UIPickerView Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return categoryArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfCategory.text = self.categoryArray[row]
        self.pvDropDown.isHidden = true
        self.ivForComplain.isHidden = false
        self.tvDescription.becomeFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return self.categoryArray[row]
    }
    
}

