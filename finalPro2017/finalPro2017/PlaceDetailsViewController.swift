//
//  PlaceDetailsViewController.swift
//  finalPro2017
//
//  Created by moran levi on 9.1.2017.
//  Copyright © 2017 Moran Levi. All rights reserved.
//

import UIKit
import CoreLocation

class PlaceDetailsViewController: UIViewController {
    //the class shows all the details/description regarding the selected place

    @IBOutlet weak var placedescritetextview: UITextView!
    
    var p : Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = p?.title
        placedescritetextview.text = p?.descrp
    }
    
    @IBAction func gotocomanets(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "comments") as? PlaceComantsViewController
        vc?.place = p!
        self.show(vc!, sender: sender)
    }
}
