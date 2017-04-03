//
//  ViewController.swift
//  finalPro2017
//
//  Created by moran levi on 9.1.2017.
//  Copyright © 2017 Moran Levi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    //represtnt the map with location and recommandation
    let locationManger = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    let ref = FIRDatabase.database().reference()
    var places = [Place]()
    var placeToAdd = Place(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManger.startUpdatingLocation()
        }
        
        mapView.showsUserLocation = true
        getPlaces()
    }
  
    @IBAction func longPressAddAnnootion(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .began{
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddPlacesViewController") as? AddPlacesViewController
           let pin = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let pinPlace = Place(pin)
            vc?.place = pinPlace
            self.show(vc!, sender: sender)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       guard annotation is Place else {
            return nil
        }
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "ann")
        if let annView = annView{
            annView.annotation = annotation
        } else {
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ann")
            (annView as? MKPinAnnotationView)?.pinTintColor = .blue
            annView?.canShowCallout = true
            annView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        return annView
    }
    
    func mapView(_ mapView: MKMapView, annotationView annView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        let p = annView.annotation as? Place
        let vc = storyboard?.instantiateViewController(withIdentifier: "Details") as? PlaceDetailsViewController
        vc?.p = p!
        self.show(vc!, sender: control)
    }
  
    func getPlaces(){
        ref.child("Places").observe(.value, with: { (snap : FIRDataSnapshot) in
           // print("\(snap.value)")
            let dict = snap.value as? [String : Any]
            for key in dict!.keys{
                 let coor1 = dict?[key] as? [String : Any]
                 let lat = coor1?["lat"] as? CLLocationDegrees
                 let long = coor1?["long"] as? CLLocationDegrees
                 let coordention = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                 let p = Place(coordention)
                 p.title = key.description
                 p.descrp = coor1?["description"] as? String
                let com = coor1?["com"] as? [String : Any]
                p.comantes = com
            self.places.append(p)
                
            }
            self.mapView.showAnnotations(self.places, animated: true)
         })
    }
 
    @IBAction func add(_ seg: UIStoryboardSegue){
        print("added")
        let coordenite : [String:Any] = ["lat" : placeToAdd.coordinate.latitude,"long" :placeToAdd.coordinate.longitude]
        ref.child("Places").child(placeToAdd.title!).setValue(coordenite)
        mapView.addAnnotation(placeToAdd)
    }
    
    deinit {
        ref.removeAllObservers()
    }
    
}

