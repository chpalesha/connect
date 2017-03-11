//
//  ThirdViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ThirdViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    //Profile Management
    
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
    
    //update name of user in firebase
    func updateName(){
        guard userInput != "" else{
            return
        }
        //get firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let userRef = ref.child("users").child(self.userid)
        //update name
        userRef.updateChildValues(["name": userInput], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
            //update array to be displayed on tableview
            self.updateUserArray()
        })
    }
    
    //updates email id of current user
    func updateEmail(){
        //first update in our database
        guard userInput != "" else{
            return
        }
        //get firebase reference
        let url = ""
        let ref = FIRDatabase.database().reference(fromURL: url)
        let userRef = ref.child("users").child(self.userid)
        //update email
        userRef.updateChildValues(["email": userInput], withCompletionBlock: { (error, refDB) in
            if error != nil{
                return
            }
            //update array to be displayed on tableview
            self.updateUserArray()
        })
        //update email address of curent user with session
        FIRAuth.auth()?.currentUser?.updateEmail(userInput)
    }
    
    //update password for current user
    func updatePassword(){
        FIRAuth.auth()?.currentUser?.updatePassword(userInput)
    }
    
    func generateAlert(title: String, message: String){
        // alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Adding the text field
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
        
        // Grab the value from the text field, and do task accordingly
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
    
    //stop session of current user
    func logoutUser(){
        do{
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "segueLogout", sender: self)
        }catch _{
            generateAlert(title: "Error", message: "Sorry! Unable to log out.")
        }
    }
    
    //array used to be displayed on tble view
    func updateUserArray(){
        var email = "Email: "
        var name = "Name: "
        let password = "Change Password"
        let logout = "Logout"
        
        //get database instance
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        readRef.child("users").child(userid).observe(.value, with: { (snapshot) in
            //unwrap snaphot to dictionary
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
                //update tableview and array 
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
