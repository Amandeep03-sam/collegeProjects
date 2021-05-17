//
//  ViewController.swift
//  A1_iOS_Amandeep_C0807306
//
//  Created by Amandeep Kaur on 16/05/21.
//



import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
   
    @IBOutlet weak var dircetionBtn: UIButton!
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var transportType: MKDirectionsTransportType!
    
    //destination
    var destination: CLLocationCoordinate2D!
    
    let places = Place.getPlaces()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        map.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotation))
        map.addGestureRecognizer(longPressGesture)
        
        // double tap
        doubleTap()
        
        
        // add overlay
        addAnnotationForPlaces()
               
    }
   func addAnnotationForPlaces(){
    map.addAnnotations(places)
    let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
    map.addOverlays(overlays)
   }






    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
    }
    //Mark: display location function
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String){
        let latDelta: CLLocationDegrees = 0.5
        let longDelta: CLLocationDegrees = 0.5
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        //SET region for map
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
        
    }
    
    //Mark: custom marker
    @objc func addLongPressAnnotation(_ gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        //add annotation
        let annotation = MKPointAnnotation()
        annotation.title = "A"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    func doubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)

    }
    
    @objc func dropPin(_ sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
       
        //add annotation
        let annotation = MKPointAnnotation()
        annotation.title = "B"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        destination = coordinate
        
    }
    
    @IBAction func drawRoute(_ sender: Any) {
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        // direction request
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        
        //transport type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest);     directions.calculate { response, error in
            guard let directionResponse = response else { return }
            // create route
            let route = directionResponse.routes[0]
            //draw polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            
            // define boundary
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100 , bottom: 100, right: 100), animated: true)
        }
    
    }
    
}

extension ViewController: MKMapViewDelegate{
    // Render overlay
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = .green
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
 // view for Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        switch annotation.title{
        case "Your Location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "current location")
            annotationView.markerTintColor = .black
            return annotationView
        case "A":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "1st  Location")
            annotationView.markerTintColor = .brown
            return annotationView
        case "B":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "2nd location")
            annotationView.animatesDrop = true
            annotationView.tintColor = .green
            return annotationView
        default:
        return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "choosen PLace", message: "Welcome!!" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}
    
