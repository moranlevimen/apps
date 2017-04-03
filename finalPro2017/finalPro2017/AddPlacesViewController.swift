
import UIKit
import CoreLocation
import FirebaseDatabase
import MapKit

class AddPlacesViewController: UIViewController {
    //this class helps the user to add a new place on the map 
    let ref = FIRDatabase.database().reference()
    var place = Place(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    
    @IBOutlet var uNameLabel: UITextField!
    
    @IBOutlet var Udescription: UITextField!
    
    @IBAction func addBtn(_ sender: UIButton) {
      place.title = uNameLabel.text ?? "place \(Date.timeIntervalBetween1970AndReferenceDate)"
      place.descrp = Udescription.text
        let coordenite : [String:Any] = ["lat" : place.coordinate.latitude,"long" :place.coordinate.longitude , "description" : place.descrp ?? "no decription", "com" : " "]
        ref.child("Places").child(place.title!).setValue(coordenite)
        
        
        
    _ = navigationController?.popViewController(animated: true)
        
    }
   
 
    override func viewDidLoad() {
        super.viewDidLoad()

    print(place.coordinate.latitude.description)
    print(place.coordinate.longitude.description)
        
    }


    deinit {
        ref.removeAllObservers()
    }
    
    }
 


