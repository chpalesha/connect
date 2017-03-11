//
//  LoadingViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/13/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class LoadingViewController: UIViewController {

    var uid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLoggedIn(){
        //to check if user is signed in
        if let userid = FIRAuth.auth()?.currentUser?.uid{
            uid = userid
            checkUser()
        }else{
            self.performSegue(withIdentifier: "segueToLoginRegister", sender: self)
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
                        self.performSegue(withIdentifier: "segueToUser", sender: self)
                    }
                }else{
                    DispatchQueue.main.async {
                        //loads admin dashboard
                        self.performSegue(withIdentifier: "segueToAdmin", sender: self)
                    }
                }
            }
        })
    }
    
    func generateAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

}
