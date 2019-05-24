//
//  Dashboard.swift
//  SmartCycle
//
//  Created by Yannick Mael Raoumbe on 23/04/2019.
//  Copyright © 2019 ME. All rights reserved.
//

//url to send data :  https://smart-cycle.herokuapp.com/add?id="parmid"&latitute="paramLat"&longitude="paramLongitude"
//to get an id its : https://smart-cycle.herokuapp.com/id
// QUE des GET

import Foundation
import UIKit
import UserNotifications
import CoreLocation
import MessageUI
import RealmSwift

class DashBoardViewController: UIViewController{
    
    var trackingStarted = false
    var currentUser : BycicleUser? = nil
    
    @IBOutlet weak var TrackingButtonOnOrOff: UIButton!
    @IBOutlet weak var CallBackUItextView: UITextView!
    @IBOutlet weak var NbrCheckPoints: UILabel!
    var LastKnownLocation : [(CLLocationDegrees,CLLocationDegrees)] = []
    
    var NbrLocations : Int = 0
    let DDrealm = try! Realm()
    
    @IBOutlet weak var CallButton: UIButton!
    @IBOutlet weak var SendSmsButton: UIButton!
    
    
    @IBAction func StartTheTracking(_ sender: UIButton) {
        let what = "Error"
        if self.CallButton.isHidden == true || self.SendSmsButton.isHidden == true {
            self.CallButton.isHidden = false
            self.SendSmsButton.isHidden = false
        }
        if self.trackingStarted {
            self.TrackingButtonOnOrOff.setTitle("Commencer le Tracking", for: .normal)
            self.CallBackUItextView.text = "\(currentUser?.name ?? what) ,Votre Id est : \(currentUser?.UniqueID ?? 0)"
            self.NbrLocations = 0
            self.NbrCheckPoints.text = "\(NbrLocations)"
            AppDelegate.LocationManager.stopUpdatingLocation()
            self.trackingStarted = !trackingStarted
        }
        else if self.trackingStarted == false {
            self.TrackingButtonOnOrOff.setTitle("Arreter le Tracking", for: .normal)
            AppDelegate.LocationManager.startUpdatingLocation()
            self.trackingStarted = !trackingStarted
        }
    }
    
    @IBAction func CallForHelp(_ sender: UIButton) {
        print("calling for help !")
        guard let number = URL(string: "tel://" + "\(self.currentUser!.numberOne)") else { return }
        print(number)
        UIApplication.shared.open(number)
    }
    
    @IBAction func SendHelpMessage(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            let num1 = (currentUser?.numberOne)!
            let num2 = (currentUser?.numberTwo)!
            let num3 = (currentUser?.numberThree)!
            let DATNAME = (currentUser?.name)!
            let Lati = (self.LastKnownLocation.first?.0)!
            let Longi = (self.LastKnownLocation.first?.1)!
            let DATID = (currentUser?.UniqueID)!
            controller.body = "\(DATNAME) a besoin de votre Aide !\nSes coordonnées sont : Latitude \(Lati) Longitude \(Longi).\n vous pouvez suivre son déplacement sur https://smart-cycle.herokuapp.com/map/\(DATID)"
            controller.recipients = [num1,num2,num3]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func sendDataToserver(Lat: CLLocationDegrees, Long: CLLocationDegrees) {
        let cyclistID = (currentUser?.UniqueID)!
        let LatAsDouble = Float(Lat)
        let LongAsDouble = Float(Long)
        let ServerUrl = URLComponents(string:"https://smart-cycle.herokuapp.com/add?id=\(cyclistID)&latitude=\(LatAsDouble)&longitude=\(LongAsDouble)")!
        print("This is the url i will pass: \(String(describing: ServerUrl.url))")
        var request = URLRequest(url:ServerUrl.url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){data,response,error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200...209) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                return
            }
            let responseString = String(data: data, encoding: .utf8)
            if response.statusCode == 200 {
                print("data Sent!")
            }
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    @IBAction func ParametersHandler(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ToVc", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.LocationManager.delegate = self
        self.NbrCheckPoints.text = "\(self.NbrLocations)"
        if currentUser == nil {
            DispatchQueue.main.async {
                self.currentUser = self.DDrealm.objects(BycicleUser.self).first
                print("who's connected now ? \(String(describing: self.currentUser))")
            }
        }
        print("dash load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("dash will appear")
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("dash appear")
    }
}

extension DashBoardViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]){

       let lalocation =  manager.location!
        self.CallBackUItextView.text = "Long: \(lalocation.coordinate.longitude)\nLat: \(lalocation.coordinate.latitude)\nVitesse: \(lalocation.speed)"
        sendDataToserver(Lat: lalocation.coordinate.latitude, Long: lalocation.coordinate.longitude)
        self.NbrCheckPoints.text = "\(self.NbrLocations)"
        self.LastKnownLocation = [(lalocation.coordinate.latitude,lalocation.coordinate.longitude)]
        self.NbrLocations += 1
        }
}

extension DashBoardViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      controller.dismiss(animated: true)
    }

}
