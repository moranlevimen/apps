//
//  SearchController.swift
//  RestAndEat
//
//  Created by moran levi on 19.3.2017.
//  Copyright © 2017 I. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import GooglePlaces

class SearchController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{
    
    @IBOutlet var RangePopup: UIView!;// view
    @IBOutlet var RangeLbl: UILabel!;//slider label
    @IBOutlet var SliderRange: UISlider!;//slider
    @IBOutlet var restTableView: UITableView!;//view table
    var radius:Int = 500;
    var pref = PrefMngr.getInstance();
    var firRef : FIRDatabaseReference!;
    let session = URLSession.shared
    var placesClient: GMSPlacesClient!;
    var currlocation:CLLocation!;
    private var rests: [Restarent] = []
    let locMngr = CLLocationManager();
    //
    func url(_ loc:CLLocation)->URL{
        return URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(loc.coordinate.latitude),\(loc.coordinate.longitude)&radius=\(radius)&type=restaurant&language=iw&key=AIzaSyBMLm5adCoSzHKWv--0-J9iNL7koCENd7Q")!
    };
    //
    override func viewDidLoad() {
        placesClient = GMSPlacesClient.shared();
        CreateNavButtons();//create navigation buttons on bar
        firRef = FIRDatabase.database().reference();
        navigationController?.navigationBar.isHidden = false;//show navigationbar
        let backItem = UIBarButtonItem();
        backItem.title = "Back";
        navigationItem.backBarButtonItem = backItem;//change label of back to this screen
        self.navigationItem.hidesBackButton = true;
        let userID = FIRAuth.auth()?.currentUser?.uid;  //get current user id
        if userID != nil {
            getUser(userID!);       //if not nil get user name
        }
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        RangePopup.isHidden = true;
        RangePopup.layer.borderWidth = 1;
        locMngr.delegate = self;//connect delegate of location manager
        locMngr.requestWhenInUseAuthorization();
        locMngr.distanceFilter = 10;
        locMngr.startUpdatingLocation();//start taking coords
    }
    //
    override func viewDidAppear(_ animated: Bool) {
        jsonParse();
    }
    //
    override func viewDidDisappear(_ animated: Bool) {
        try? FIRAuth.auth()?.signOut();
    }
    //
    func CreateNavButtons(){
        self.navigationItem.setRightBarButtonItems([TabBarBtn(imgname: "Radar"),TabBarBtn(imgname: "Near Me"),TabBarBtn(imgname: "Map")], animated: true);//navigation bar right side
        self.navigationItem.setLeftBarButton(TabBarBtn(imgname: "Logout"), animated: true);//navigation bar left side
    }
    //
    func TabBarBtn(imgname:String)->UIBarButtonItem{//building button for bar
        let btn = UIButton(type: .custom);//custom button
        btn.setImage(UIImage(named: imgname), for: .normal);//set image for button
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30);//set frame size
        switch imgname.lowercased() {// couldnt user closure because its escaping so used a switch
        case "logout":
            btn.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside);
        case "near me":
            btn.addTarget(self, action: #selector(sendRequest(_:)), for: .touchUpInside);
        case "map":
            btn.addTarget(self, action: #selector(goToMap(_:)), for: .touchUpInside);
        case "radar":
            btn.addTarget(self, action: #selector(setRange(_:)), for: .touchUpInside);
        default:
            print("ERROR");
        }
        return UIBarButtonItem(customView: btn);//return bar button item
    }
    //
    func goToMap(_ sender:UIButton){//action go to map
        let next = storyboard!.instantiateViewController(withIdentifier: "Map") as! MapController;
        next.getRests(rests);
        show(next, sender: self);
    }
    //
    func logout(_ sender:UIButton) {//action logout
        locMngr.stopUpdatingLocation();
        try? FIRAuth.auth()?.signOut();
        pref.logUserOut();
        navigationController!.popViewController(animated: false);
    }
    //
    func sendRequest(_ sender:UIButton){//action send new near me request
        jsonParse();
    }
    //
    func setRange(_ sender:UIButton){//action button show view
        RangePopup.isHidden = false;
    }
    //
    @IBAction func ChangeRange(_ sender: UISlider) {//slider value changed
        RangeLbl.text = String(Int(sender.value))+"M";
    }
    @IBAction func RangeOk(_ sender: UIButton) {//ok button for view
        radius = Int(SliderRange.value);
        jsonParse();
        RangePopup.isHidden = true;
    }
    @IBAction func RangeCancel(_ sender: UIButton) {//cancel button for view
        RangePopup.isHidden = true;
    }
    func jsonParse(){
        rests.removeAll();
        session.dataTask(with: url(currlocation), completionHandler: {(d,r,e) in
            let status = (r as! HTTPURLResponse).statusCode
            if (e == nil && status == 200){
                self.rests.removeAll();
                AsyncTask( backgroundTask: {(d: Data)->Void in
                    if let json = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as! [String:Any]{
                        let results=json["results"] as! [[String:Any]];//
                        for r in results{//
                            let rest=Restarent();//Restaurant of each object in array
                            //set all needed properties
                            rest.set(title:r["name"] as! String)
                                .set(adress:r["vicinity"] as! String)
                                .set(id:r["place_id"] as! String);
                            if (r["opening_hours"] != nil) {        //get opening hours
                                let h = r["opening_hours"] as! [String:Any];
                                rest.set(isOpen:h["open_now"] as! Bool)
                                    .set(hours: h["weekday_text"] as! [String]);
                            }
                            if (r["geometry"] != nil){
                                let g = (r["geometry"] as! [String:Any]);
                                let l = g["location"] as! [String:Any];
                                let c = [l["lat"]as! Double, l["lng"]as! Double];
                                rest.set(location: c);
                            }
                            //and other properties....
                            //here
                            //store to local array
                            self.rests.append(rest);
                        }
                    }
                }, afterTask: {
                    if (self.rests.count > 0){
                        self.restTableView.reloadData();
                    }
                }).execute(d!);
            }
        }).resume();
    }
    //
    func getUser(_ id:String){          //get user by id from database
        firRef.child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            let username = value?["username"] as? String;
            if username != nil{
                self.navigationItem.title = "Hello \(username!)";
            }
        }){ (error) in
            print(error.localizedDescription);
            try? FIRAuth.auth()?.signOut();
            self.navigationController!.popViewController(animated: false);
        }
    }
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("*******************USE LOCATION SERVICE****************************");
        currlocation = locations[locations.count-1];
    }
    //
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }
    //tableview delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rests.count;
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  Bundle.main.loadNibNamed("Cell", owner: self, options: nil)?.first as! CellTableView;
        let r :Restarent = rests[indexPath.row];
        cell.ttl.text = r.getTitle();
        cell.desc.text = r.getAdress();
        if let o = r.getIsOpen() {
            if o {
                cell.img.image = UIImage(named: "open");
            }else{
                cell.img.image = UIImage(named: "closed");
            }
        }
        cell.contentView.layer.borderWidth = 1;
        return cell;
    }
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segway
        let r:Restarent = rests[indexPath.row];
        var info="";
        placesClient.lookUpPlaceID(r.getId()!, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return;
            }
            guard let place = place else {
                print("No place details for \(r.getId()!)")
                return;
            }
            let phone1 = place.phoneNumber;
            let web = place.website;
            let rate = place.rating;
            info.append("rating: \(rate)");
            let popup = UIAlertController(title: r.getTitle(), message: info, preferredStyle: .alert);
            //custom alert
            let webAction = UIAlertAction(title: "Website", style: .default, handler: { (action) in
                if web != nil{
                    print("move to web");
                    UIApplication.shared.open(web!, options: [:], completionHandler: nil)}
            });
            print("**\(phone1)");
            let phoneAction = UIAlertAction(title: "Make A Call", style: .default, handler: { (action) in
                if phone1 != nil{
                    self.callNumber(phoneNumber: phone1!);
                }
            });
            popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
            popup.view.tintColor = UIColor.green;
            popup.view.backgroundColor = UIColor.cyan;
            popup.view.layer.cornerRadius = 30;
            self.present(popup, animated: true, completion: nil);
            popup.addAction(webAction);
            popup.addAction(phoneAction);
        });
        print(info);
    }
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.00;
    }
    //
    private func callNumber(phoneNumber:String) {
        let cleanNumber = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "");
        if let url = URL(string: "telprompt://\(cleanNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                print("calling....");
                UIApplication.shared.open(url,options: [:],completionHandler:nil);
            }
        }
    };
    //
}
