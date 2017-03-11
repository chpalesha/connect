//
//  AdminSecondViewController.swift
//  Connect
//
//  Created by Chirag Palesha on 12/4/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import MapKit
import CoreLocation

class AdminSecondViewController: UIViewController, CLLocationManagerDelegate {
    //complains on map
    @IBOutlet weak var mapVIew: MKMapView!
    var complains = [Complain]()
    var otherFlag = [Annotation](), garbageFlag = [Annotation](), lightsFlag = [Annotation](), potholesFlag = [Annotation]();
    var parkingFlag = [Annotation](), railwayFlag = [Annotation](), roadFlag = [Annotation](), strayAnimalFlag = [Annotation]();
    var waterFlag = [Annotation](), trafficFlag = [Annotation]();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         mapVIew.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 32.715738, longitude: -117.16108380000003), 50000, 50000), animated: true)
        fetchComplain()
    }
    
    //fetch all complain and stores in complains array
    func fetchComplain(){
        let url = ""
        FIRDatabase.database().reference(fromURL: url).child("complain").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let complain = Complain()
                complain.setValuesForKeys(dictionary)
                
                self.complains.append(complain)

            }
        })
    }
    //returns annotation object to be placed on map
    func getAnnotation(title: String, subTitle: String, latitude: Double, longitude: Double) -> Annotation{
        let cordinate = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        return Annotation(title: title, subtitle: subTitle, coordinate: cordinate.coordinate)
    }
    
    //displays annotation of specified category
    func showAnnotations(catgory value: String) -> [Annotation]?{
        var plotAnnotations: [Annotation]? = nil
        for complain in complains{
            if complain.category == value{
                let title = complain.category + " | " + complain.desc
                let subtitle = complain.status
                if var plot = plotAnnotations {
                    plot.append(getAnnotation(title: title, subTitle: subtitle, latitude: Double(complain.latitude)!, longitude: Double(complain.longitude)!))
                }else{
                    plotAnnotations = [getAnnotation(title: title, subTitle: subtitle, latitude: Double(complain.latitude)!, longitude: Double(complain.longitude)!)]
                }
            }
        }
        if let plot = plotAnnotations{
            mapVIew.addAnnotations(plot)
            return plot
        }
        return nil
    }
    
    //removes annotation from map
    func removeAnnotations(category: [Annotation]){
        mapVIew.removeAnnotations(category)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //displays/removes annotation of complain according to selection 
    @IBAction func bOther(_ sender: UIButton) {
        if otherFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Other"){
                otherFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_other"), for: .normal)
            }
        }else{
            removeAnnotations(category: otherFlag)
            otherFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "other"), for: .normal)
        }
    }
    
    @IBAction func bWater(_ sender: UIButton) {
        if waterFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Water"){
                waterFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_water"), for: .normal)
            }
        }else{
            removeAnnotations(category: waterFlag)
            waterFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "water"), for: .normal)
        }
    }
    
    @IBAction func bTraffic(_ sender: UIButton) {
        if trafficFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Traffic"){
                trafficFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_traffic"), for: .normal)
            }
        }else{
            removeAnnotations(category: trafficFlag)
            trafficFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "traffic"), for: .normal)
        }
    }
    
    @IBAction func bStrayAnimal(_ sender: UIButton) {
        if strayAnimalFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Stray Animal"){
                strayAnimalFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_animal"), for: .normal)
            }
        }else{
            removeAnnotations(category: strayAnimalFlag)
            strayAnimalFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "animal"), for: .normal)
        }
    }
    
    @IBAction func bRoads(_ sender: UIButton) {
        if roadFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Road"){
                roadFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_road"), for: .normal)
            }
        }else{
            removeAnnotations(category: roadFlag)
            roadFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "road"), for: .normal)
        }
    }
    @IBAction func bGarbage(_ sender: UIButton) {
        if garbageFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Garbage"){
                garbageFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_garbage"), for: .normal)
            }
        }else{
            removeAnnotations(category: garbageFlag)
            garbageFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "garbage"), for: .normal)
        }
    }
    
    @IBAction func bPotholes(_ sender: UIButton) {
        if potholesFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Potholes"){
                potholesFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_potholes"), for: .normal)
            }
        }else{
            removeAnnotations(category: potholesFlag)
            potholesFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "potholes"), for: .normal)
        }
    }
    
    @IBAction func bParking(_ sender: UIButton) {
        if parkingFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Parking"){
                parkingFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_park"), for: .normal)
            }
        }else{
            removeAnnotations(category: parkingFlag)
            parkingFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "park"), for: .normal)
        }
    }
    
    @IBAction func bLights(_ sender: UIButton) {
        if lightsFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Lights"){
                lightsFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_light"), for: .normal)
            }
        }else{
            removeAnnotations(category: lightsFlag)
            lightsFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
        }
    }

    @IBAction func bRailways(_ sender: UIButton) {
        if railwayFlag.count == 0{
            if let annotations = showAnnotations(catgory: "Railways"){
                railwayFlag = annotations
                sender.setBackgroundImage(#imageLiteral(resourceName: "active_railway"), for: .normal)
            }
        }else{
            removeAnnotations(category: railwayFlag)
            railwayFlag.removeAll()
            sender.setBackgroundImage(#imageLiteral(resourceName: "railway"), for: .normal)
        }
    }
}
