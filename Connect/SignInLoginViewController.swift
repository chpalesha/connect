//
//  SignInLoginViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var bRegisterLogin: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scRegisterLogin: UISegmentedControl!
    var heightUpdated: Float = 0.0
    
    var uid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tfName.delegate = self
        self.tfEmail.delegate = self
        self.tfPassword.delegate = self
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == tfPassword || textField == tfEmail){
            scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == tfName){
            tfEmail.becomeFirstResponder()
        }
        if(textField == tfEmail){
            tfPassword.becomeFirstResponder()
        }
        if(textField == tfPassword){
            self.view.endEditing(true)
        }
        return false
    }

    
    func checkLoggedIn(){
        //to check if user is signed in
         if let userid = FIRAuth.auth()?.currentUser?.uid{
            uid = userid
            checkUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bRegisterLoginClicked(_ sender: UIButton) {
        if bRegisterLogin.currentTitle == "Register"{
            handleRegister()
            
        }else{
            handleLogin()
        }
        self.tfName.text = ""
        self.tfEmail.text = ""
        self.tfPassword.text = ""
    }
    
    func generateAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentSelected(_ sender: Any) {
        if scRegisterLogin.selectedSegmentIndex == 0{
            //registeration tab
            tfName.isHidden = false
            bRegisterLogin.setTitle("Register", for: .normal)
        }else{
            //login tab
            tfName.isHidden = true
            bRegisterLogin.setTitle("Login", for: .normal)
        }
        
    }
    
    func handleRegister(){
        //register user
        guard let email = tfEmail.text, let password = tfPassword.text, let name=tfName.text else {
            generateAlert(title: "Error", message: "Name/Email/Password not entered")
            return
        }
        
        if name != "" && email != "" && password != "" {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                
                if error != nil{
                    self.generateAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                    return
                }

                //successful in Auth
                guard let uid = user?.uid else {
                    return
                }
                
                let url = ""
                let ref = FIRDatabase.database().reference(fromURL: url)
                let usersRef = ref.child("users").child(uid)
                let values = ["name": name, "email": email, "type": "user", "reward": 100] as [String : Any]
                
                usersRef.updateChildValues(values, withCompletionBlock: {
                    (err, ref) in
                    if err != nil{
                        return
                    }
                })
                
                self.uid = (user?.uid)!
                self.checkLoggedIn()
                self.checkUser()
            })
        }else{
           generateAlert(title: "Error", message: "Name/Email/Password not entered")
        }
        
    }

    func handleLogin(){
        guard let email = tfEmail.text, let password = tfPassword.text else {
            generateAlert(title: "Error", message: "Email/Password not entered")
            return
        }
        if email != "" && password != ""{
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
               self.generateAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                return
            }
            self.uid = (user?.uid)!
            self.checkLoggedIn()
            self.checkUser()
        })
        }else{
            generateAlert(title: "Error", message: "Email/Password not entered")
        }
    }
    
    func checkUser(){
        //get database instanct
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        guard uid != "" else{
            generateAlert(title: "Error", message: "User Unable to Register/Login")
            return
        }
        
        readRef.child("users").child(uid).observe(.value, with: { (snapshot) in
            
            let dictionary = snapshot.value as? [String: AnyObject]
            //check if user is admin or not
            if let type = dictionary?["type"] as? String{
                if type == "user"{
                    DispatchQueue.main.async {
                        //loads user dashboard
                        self.performSegue(withIdentifier: "segueUserDashboard", sender: self)
                    }
                }else{
                    DispatchQueue.main.async {
                        //loads admin dashboard
                        self.performSegue(withIdentifier: "segueAdminDashboard", sender: self)
                    }
                }
            }
        })
    }
}
