//
//  ViewController.swift
//  SmartCycle
//
//  Created by Yannick Mael Raoumbe on 23/04/2019.
//  Copyright © 2019 ME. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift


class ViewController: UIViewController {
    @IBOutlet weak var NumOneTxtF: UITextField!
    @IBOutlet weak var NumTwoTxtF: UITextField!
    @IBOutlet weak var NumThreeTxtF: UITextField!
    
    @IBOutlet weak var Nom: UITextField!
    @IBOutlet weak var Prenom: UITextField!
    
    @IBOutlet weak var GoToDashBoardButton: UIButton!
    
    
    let Drealm = try! Realm()
    
    @objc func DissmissKeyboard(){
        if Nom.isEditing || Prenom.isEditing || NumOneTxtF.isEditing || NumTwoTxtF.isEditing || NumThreeTxtF.isEditing {
            self.view.endEditing(true)
        }
        checkTextfields()
    }
    
    func GetAnId(finished: @escaping ((_ isSuccess: String)->Void)){
        let ServerUrl = URLComponents(string:"https://smart-cycle.herokuapp.com/id")!
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
                finished(responseString!)
            }
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    func RegisterUserOnce(nom: String, prenom: String,ID: Int,NumberOne: String, NumberTwo: String, NumberThree : String){
        
        let CurrentUser = BycicleUser()
        CurrentUser.name = "\(prenom) \(nom)"
        CurrentUser.numberOne = NumberOne
        CurrentUser.numberTwo = NumberTwo
        CurrentUser.numberThree = NumberThree
        CurrentUser.UniqueID = ID
        
        print(CurrentUser)
        try! Drealm.write {
            Drealm.add(CurrentUser)
        }
    }
    
    func checkTextfields(){
        if self.Nom.text!.isEmpty || self.Prenom.text!.isEmpty || self.NumOneTxtF.text!.isEmpty || self.NumTwoTxtF.text!.isEmpty || self.NumThreeTxtF.text!.isEmpty {
            self.GoToDashBoardButton.isEnabled = false
        } else {
            self.GoToDashBoardButton.isEnabled = true
        }
    }
    
    func GONOW(){

        self.performSegue(withIdentifier: "ToDashboard", sender: self)
        UserDefaults.standard.set("Nomore", forKey:"IsfirstRun")
    }
    
    @IBAction func ToDashBoard(_ sender: UIButton) {
        GetAnId(){Success in
            print(Int(Success)!)
            DispatchQueue.main.async {
                 self.RegisterUserOnce(nom: self.Nom.text!, prenom: self.Prenom.text!, ID: Int(Success)!, NumberOne: self.NumOneTxtF.text!, NumberTwo: self.NumTwoTxtF.text!,NumberThree: self.NumThreeTxtF.text!)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            self.GONOW()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(DissmissKeyboard))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        checkTextfields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
