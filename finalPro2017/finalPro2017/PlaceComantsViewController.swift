//
//  PlaceComantsViewController.swift
//  finalPro2017
//
//  Created by moran levi on 23.1.2017.
//  Copyright © 2017 Moran Levi. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase

class PlaceComantsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    //show all commants on selected place

    @IBOutlet weak var userComment: UITextField!
    var ref = FIRDatabase.database().reference()
    
    @IBAction func addBtn(_ sender: UIButton) {
        if !(userComment.text?.isEmpty)!{
        var str = Date().timeIntervalSince1970.description
        str.removeDot()
        print(str)
        ref.child("Places").child(place.title!).child("com").child(str).setValue(userComment.text)
        userComment.text = " "
        }
    }
    @IBOutlet weak var tableViewComments: UITableView!
    var place = Place(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    var arr2 : [String] = []
    

    @IBAction func closrKeybord(_ sender: UITapGestureRecognizer) {
        userComment.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = place.title! + " comments"
        getComents()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arr2.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell")
        c?.textLabel?.text = arr2[indexPath.row].description
        return c!
    }

    func getComents(){
        ref.child("Places").child(place.title!).observe(.value, with: {(snap : FIRDataSnapshot) in
            //print("this is snap "+"\(snap.value)")
            self.arr2 = []
            let dict = snap.value as! [String:Any]
            if let com = dict["com"] as? [String:Any]{
                for key in com.keys{
                    print(com[key] as? String ?? "error")
                   self.arr2.append(com[key] as! String)
        }
           self.tableViewComments.reloadData()
            }
        })
    }

    deinit {
        ref.removeAllObservers()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
