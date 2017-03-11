//
//  AdminThirdViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AdminThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //profile details of admin
    @IBOutlet weak var tvProfileDetails: UITableView!
    var userid = String()
    var userArray = Array<String>()
    var userInput = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init uitableview
        self.tvProfileDetails.delegate = self
        self.tvProfileDetails.dataSource = self
        
        // Do any additional setup after loading the view.
        if let uid = getUserID(){
            self.userid = uid
            updateUserArray()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserID() -> String?{
        //to check if user is signed in
        guard let userid = FIRAuth.auth()?.currentUser?.uid else{
            return nil
        }
        return userid
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ElementCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = userArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            generateAlert(title: "Name", message: "Please Enter your Name")
        case 1:
            generateAlert(title: "Email", message: "Please Enter your Email")
        case 2:
            generateAlert(title: "Password", message: "Please Enter Password")
        case 3:
            logoutUser()
        default:
            break
        }
    }
    
    //updates name of current user
    func updateName(){
        guard userInput != "" else{
            return
        }
        let ref = FIRDatabase.database().reference(fromURL: "https://connect-cb0b9.firebaseio.com/")
        let userRef = ref.child("users").child(self.userid)
        userRef.updateChildValues(["name": userInput], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
            self.updateUserArray()
        })
    }
    
    //updates email of current user
    func updateEmail(){
        //first update in our database
        guard userInput != "" else{
            return
        }
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let userRef = ref.child("users").child(self.userid)
        userRef.updateChildValues(["email": userInput], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
            self.updateUserArray()
        })
        
        FIRAuth.auth()?.currentUser?.updateEmail(userInput)
    }
    
    //updates password of current user
    func updatePassword(){
        FIRAuth.auth()?.currentUser?.updatePassword(userInput)
    }
    
    func generateAlert(title: String, message: String){
        // alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = title
            switch(title){
            case "Email":
                textField.keyboardType = UIKeyboardType.emailAddress
            case "Password":
                textField.isSecureTextEntry = true
            default:
                break
            }
        }
        
        // Grab the value from the text field, and perform task accordingly
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.userInput = (textField?.text)!
            switch(title){
            case "Name":
                self.updateName()
            case "Email":
                self.updateEmail()
            case "Password":
                self.updatePassword()
            default:
                break
            }
            
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func logoutUser(){
        do{
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "segueAdminLogout", sender: self)
        }catch _{
            generateAlert(title: "Error", message: "Sorry unable to log out")
        }
    }
    
    //update array to be displayed on table view
    func updateUserArray(){
        var email = "Email: "
        var name = "Name: "
        let password = "Change Password"
        let logout = "Logout"
        
        //get database instanct
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        readRef.child("users").child(userid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                for (key, value) in dictionary{
                    switch(key){
                    case "email":
                        email += value as! String
                    case "name":
                        name += value as! String
                    default: break
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.userArray.removeAll()
                self.userArray.append(name)
                self.userArray.append(email)
                self.userArray.append(password)
                self.userArray.append(logout)
                self.tvProfileDetails.reloadData()
            }
        })
    }
    
}
