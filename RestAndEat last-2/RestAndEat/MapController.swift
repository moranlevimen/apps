import UIKit
import MapKit
class MapController: UIViewController,MKMapViewDelegate {
    @IBOutlet var myMap:MKMapView!;
    var rests:[Restarent]?;
    //
    override func viewDidLoad() {
        //assign this class's instance as myMap's delegat property
        myMap.delegate=self;
        //show user's current location
        myMap.showsUserLocation=true;
        //Map layer type
        myMap.mapType = .standard;
    }
    //
    override func viewDidAppear(_ animated: Bool) {
        if rests != nil {
            showPlaces(rests!);
        }
    }
    //
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //reset region for each location change
        //        let newPlace=userLocation.coordinate;
        myMap.setRegion(MKCoordinateRegionMakeWithDistance((userLocation.coordinate), 1000, 1000), animated: true);
        if rests != nil {
            showPlaces(rests!);
        }
    }
    //
    func showPlaces(_ places:[Restarent]){
        for r in places{
            let pin = MKPointAnnotation();//marker
            pin.coordinate=CLLocationCoordinate2D(latitude: r.getLoc()![0], longitude: r.getLoc()![1]);
            pin.title=r.getTitle();
            myMap.addAnnotation(pin);//add current marker to map
        }
    }
    //
    func getRests(_ rests:[Restarent]){
        self.rests = rests;
    }
}
