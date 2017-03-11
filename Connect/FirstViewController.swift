//
//  FirstViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FirstViewController: UIViewController {
    //User Rewards
    
    @IBOutlet weak var lPoints: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateScore(of: getUserID())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //inital value of score to display until actual score is being fetched from database
    func updateScore(of uid: String?){
        guard let userid = uid else {
            lPoints.text = "0"
            return
        }
        
        //get database instance
        let url = ""
        let readRef = FIRDatabase.database().reference(fromURL: url)
        readRef.child("users").child(userid).observe(.value, with: { (snapshot) in
            
            let dictionary = snapshot.value as? [String: AnyObject]
            //check if user is admin or not
            if let reward = dictionary?["reward"] as? Int{
                DispatchQueue.main.async {
                    //loads user dashboard
                    self.lPoints.text = String(reward)
                }
            }
        })
    }
    
    func getUserID() -> String?{
        //to check if user is signed in
        guard let userid = FIRAuth.auth()?.currentUser?.uid else{
            return nil
        }
        return userid
    }

}

