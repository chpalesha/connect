//
//  DetailComplainViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DetailComplainViewController: UIViewController {

    @IBOutlet weak var ivComplain: UIImageView!
    @IBOutlet weak var lStatus: UILabel!
    @IBOutlet weak var bInvalid: UIButton!
    @IBOutlet weak var bProcessing: UIButton!
    @IBOutlet weak var bCompleted: UIButton!
    @IBOutlet weak var lCategory: UILabel!
    @IBOutlet weak var lEmail: UILabel!
    @IBOutlet weak var lGeoCoord: UILabel!
    @IBOutlet weak var tvDesc: UITextView!
    
    var complainID = String()
    var complainDesc = "Description:\n"
    var complainGeoCoord = "GeoCoordinate: "
    var complainCategory = "Category: "
    var status = String()
    var imageForComplain = UIImage()
    var userID = String()
    var email = "Email: "
    var reward = -1
    var flag = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetches reward from firebase, to add or subtract score according to status
        getReward(of: userID)
        //fetch email from firebase
        getEmail(of: self.userID)
        //fetch complain details
        fetchComplain(id: complainID)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initlizes all string, to be displayed for complain details
        initDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //initlizes all string, to be displayed for complain details
    func initDetails(){
        self.complainDesc = "Description:\n"
        self.complainGeoCoord = "GeoCoordinate: "
        self.complainCategory = "Category: "
        
    }
    
    //fetch complain details
    func fetchComplain(id: String){
        //adding listner to cmplain (.value -> updates details in real-time)
        let url = ""
        FIRDatabase.database().reference(fromURL: url).child("complain").child(id).observe( .value, with: { (snapshot) in
            //if successfully we get complain details in snapshot, unwraps snapshot to key:value pair
            if let snap = snapshot.value as? [String: AnyObject] {
                let complain = Complain()
                complain.setValuesForKeys(snap)
                self.initDetails()
                self.complainCategory += complain.category
                self.complainDesc += complain.desc
                self.complainGeoCoord += complain.longitude + " | " + complain.latitude
                self.status = complain.status
                
                DispatchQueue.main.async {
                    //updating labels
                    self.lCategory.text = self.complainCategory
                    self.tvDesc.text = self.complainDesc
                    self.lEmail.text = self.email
                    self.lGeoCoord.text = self.complainGeoCoord
                    //updates button which represents status
                    self.checkStatus()
                    //fetches complain image
                    self.requestImage(from: complain.image)
                }
            }
        })
    }
    
    //fetches complain image
    func requestImage(from url: String){
        let imageURL = URL(string: url)
        //check if image is found
        if let realImageURL = imageURL{
            // request for url
            let request = URLRequest(url: realImageURL)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if error != nil {
                    return
                }
                
                let uiImage = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    //updates uiImage with image fetched
                    self.ivComplain.image = uiImage
                }
            }).resume()
        }
    }
    
    //updates button which represent status
    func checkStatus(){
        // buttons without representing status
        normalButtonColor()
        switch status {
        case "invalid":
            bInvalid.setTitleColor(UIColor.white, for: .normal)
            bInvalid.backgroundColor = UIColor.init(red: 255/255, green: 33/255, blue: 1/255, alpha: 1)
        case "processing":
            bProcessing.setTitleColor(UIColor.white, for: .normal)
            bProcessing.backgroundColor = UIColor.init(red: 255/255, green: 136/255, blue: 1/255, alpha: 1)
            break
        case "completed":
            bCompleted.setTitleColor(UIColor.white, for: .normal)
            bCompleted.backgroundColor = UIColor.init(red: 1/255, green: 132/255, blue: 72/255, alpha: 1)
        default:
            break
        }
    }
    
    // buttons without representing status
    func normalButtonColor(){
        bInvalid.setTitleColor(UIColor.init(red: 255/255, green: 33/255, blue: 1/255, alpha: 1), for: .normal)
        bInvalid.backgroundColor = UIColor.white
        
        bProcessing.setTitleColor(UIColor.init(red: 255/255, green: 136/255, blue: 1/255, alpha: 1), for: .normal)
        bProcessing.backgroundColor = UIColor.white
        
        bCompleted.setTitleColor(UIColor.init(red: 1/255, green: 132/255, blue: 72/255, alpha: 1), for: .normal)
        bCompleted.backgroundColor = UIColor.white
    }

    //update status to invalid
    @IBAction func invalidPressed(_ sender: Any) {
        self.flag = 0
        normalButtonColor()
        bInvalid.setTitleColor(UIColor.white, for: .normal)
        bInvalid.backgroundColor = UIColor.init(red: 255/255, green: 33/255, blue: 1/255, alpha: 1)
        updateStatus(updatedStatus: "invalid")
        updateReward(with: "invalid")
    }
    
    //update status to processing
    @IBAction func processingPressed(_ sender: UIButton) {
        self.flag = 0
        normalButtonColor()
        bProcessing.setTitleColor(UIColor.white, for: .normal)
        bProcessing.backgroundColor = UIColor.init(red: 255/255, green: 136/255, blue: 1/255, alpha: 1)
        updateStatus(updatedStatus: "processing")
        updateReward(with: "processing")
    }
    //update status to complete
    @IBAction func completedPressed(_ sender: Any) {
        self.flag = 0
        normalButtonColor()
        bCompleted.setTitleColor(UIColor.white, for: .normal)
        bCompleted.backgroundColor = UIColor.init(red: 1/255, green: 132/255, blue: 72/255, alpha: 1)
        updateStatus(updatedStatus: "completed")
        updateReward(with: "complete")
    }
    
    //updates status on firebase
    func updateStatus(updatedStatus: String){
        guard status != updatedStatus else{
            return
        }
        registerOldStatus()
        registerStatus(updated: updatedStatus)
        //gets firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let userRef = ref.child("complain").child(self.complainID)
        //updates status value
        userRef.updateChildValues(["status": updatedStatus], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
        })
    }
    
    func registerStatus(updated: String){
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
                    if key == updated {
                        updateProcessingValue = value as! Int
                    }
                }
            }
            //flag to update counter once, because of adding observer there can be multiple calls and multiple updates to count of status.
            flag = flag + 1
            if flag == 1{
                updateProcessingValue = updateProcessingValue + 1
                //update status on firebase
                statusRef.updateChildValues([updated: updateProcessingValue], withCompletionBlock: { (error, ref) in
                    if error != nil{
                        return
                    }
                })
            }
        })
    }
    
    func registerOldStatus(){
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
                    if key == self.status {
                        updateProcessingValue = value as! Int
                    }
                }
            }
            //flag to update counter once, because of adding observer there can be multiple calls and multiple updates to count of status.
            flag = flag + 1
            if flag == 1{
                updateProcessingValue = updateProcessingValue - 1
                //update status on firebase
                statusRef.updateChildValues([self.status: updateProcessingValue], withCompletionBlock: { (error, ref) in
                    if error != nil{
                        return
                    }
                })
            }
        })
    }
    
    //fetches reward from firebase, to add or subtract score according to status
    func getReward(of uid: String){
        //get database instanct
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        guard uid != "" else{
            return
        }
        
        readRef.child("users").child(uid).observe(.value, with: { (snapshot) in
            
            let dictionary = snapshot.value as? [String: AnyObject]
            //check if user is admin or not
            self.reward = (dictionary?["reward"] as? Int)!
        })
    }
    
    //fetch email from firebase
    func getEmail(of uid: String){
        //get database instanct
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        guard uid != "" else{
            return
        }
        
        readRef.child("users").child(uid).observe(.value, with: { (snapshot) in
            
            let dictionary = snapshot.value as? [String: AnyObject]
            //update email label
            self.email = "Email: "
            self.email += (dictionary?["email"] as? String)!
            self.lEmail.text = self.email
        })
    }
    
    func updateReward(with: String){
        var updatedReward = 0
        //check for status updated, accordingly add or subtract
        if with == "invalid"{
            updatedReward = self.reward - 10
        }
        if with == "completed"{
            updatedReward = self.reward + 10
        }
        if updatedReward <= 50{
            updatedReward = 50
        }
        
        //get firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let userRef = ref.child("users").child(self.userID)
        //updates reward into firebase 
        userRef.updateChildValues(["reward": updatedReward], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
        })
    }
    
}
