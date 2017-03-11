//
//  AdminFirstViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import QuartzCore

class AdminFirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tvListOfComplain: UITableView!
    var complains = [Complain]()
    var complainsImage = [UIImage]()
    var complainID = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        fetchComplainID()
        
        //uiTable init
        tvListOfComplain.dataSource = self
        tvListOfComplain.delegate = self
        tvListOfComplain.rowHeight = UITableViewAutomaticDimension
        tvListOfComplain.estimatedRowHeight = 44
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //fetch complain id of all complains
    func fetchComplainID(){
        //get firebase refernce and adds observer to complains (.childAddess -> updates data on when child is added)
        let url = ""
        FIRDatabase.database().reference(fromURL: url).child("complain").observe( .childAdded, with: { (snapshot) in
                //appends complainID array
                self.complainID.append(snapshot.key)
                let complain = Complain()
                //appends dummy complain to complains array
                self.complains.append(complain)
                //appends dummy cimage to complainsImage array
                self.complainsImage.append(#imageLiteral(resourceName: "app"))
                self.fetchComplain(id: snapshot.key)
        })
    }
    
    //fetch complain from id
    func fetchComplain(id: String){
        //add observer to complain (.value -> gets real-time update)
        let url = ""
        FIRDatabase.database().reference(fromURL: url ).child("complain").child(id).observe( .value, with: { (snapshot) in
            //unwrapps snapshot to dictionary
            if let snap = snapshot.value as? [String: AnyObject] {
                let complain = Complain()
                complain.setValuesForKeys(snap)
                let loc = self.complainID.index(of: id)!
                //assign complain details according to location of complain id same with image array
                self.complains[loc] = complain
                self.requestImage(from: complain.image, loc: loc)
                DispatchQueue.main.async {
                    //updates table view
                    self.tvListOfComplain.reloadData()
                }
            }
        })
    }
    
    //search complain in complain id and return location
    func search(cid: String) -> Int{
        var loc = 0
        guard complainID.count == 0 else {
            return -1
        }
        for c in complainID{

            if c == cid{
                return loc
            }
            loc += 1
        }
        return -1
    }
    
    func maskRoundedImage(image: UIImage) -> UIImage {
        let square = CGSize(width: min(image.size.width, image.size.height), height: min(image.size.width, image.size.height))
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    //request image of complain
    func requestImage(from url: String, loc: Int){
        let imageURL = URL(string: url)
        if let realImageURL = imageURL{
            //request url
            let request = URLRequest(url: realImageURL)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {

                    return
                }
                //if successful converts data to image
                let uiImage = UIImage(data: data!)
                if let realUIImage = uiImage{
                    //updates uiimage to image fetched

                    self.complainsImage[loc] = self.maskRoundedImage(image: realUIImage)
                }
                
                DispatchQueue.main.async {
                    //updtes table view
                    self.tvListOfComplain.reloadData()
                }
            }).resume()
        }
    }
    
    
    //UITableView Functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.lCategory.text = complains[indexPath.row].category
        cell.lDescription.text = complains[indexPath.row].desc
        cell.lStatus.text = complains[indexPath.row].status
        if indexPath.row < complainsImage.count{
            cell.leftImage.image = complainsImage[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complains.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueAdminComplain", sender: self)
    }

    //detail view if complain selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAdminComplain" {
            let i = (tvListOfComplain.indexPathForSelectedRow?.row)!
            let vc = segue.destination as! DetailComplainViewController
            
            vc.userID = complains[i].uid
            vc.complainID = complainID[i]
        
        }
    }

}
