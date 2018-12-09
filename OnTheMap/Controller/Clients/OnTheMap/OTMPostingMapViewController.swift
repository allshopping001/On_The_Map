//
//  OTMPostingMapViewController.swift
//  OnTheMap
//
//  Created by macos on 05/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OTMPostingMapViewController: UIViewController, MKMapViewDelegate {
    
    // Properties
    let client = OTMClient()
    let geoCoder = CLGeocoder()
    var mediaURL : String? = nil
    var mapString : String? = nil
    var placeMark : CLPlacemark? = nil {
        didSet{
            loadMap(placeMark!)
        }
    }
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    //MARK: - MapView Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func loadMap(_ placeMark: CLPlacemark){
        guard let coordinate = placeMark.location?.coordinate else {
            
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = placeMark.name
        annotation.subtitle = "\(placeMark.locality ?? "nil"), \(placeMark.country ?? "nil")"
        
        DispatchQueue.main.async {
            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // MARK: - Post Location Method
    @IBAction func finishButtonPressed(_ sender: Any) {
        let user = publicUser()
        client.postAStudent(user) { (result, response, error) in
            guard (error == nil) else {
                self.presentUIAlert("Request Failed", "Couldn't post your request", nil)
                return
            }
            if let statusCode = response, statusCode <= 200 || statusCode >= 299  {
                self.presentUIAlert("Request Failed", "Couldn't post your request", nil)
            } else {
                if result != nil {
                    self.presentUIAlert("Request Successful", "Your request has been posted", { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    // MARK: - Create UIAlert
    func presentUIAlert(_ title: String?, _ message: String?,_ handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Fetch Public User
    func publicUser() -> OTMStudent {
        let publicUser = OTMStudent.init(objectId: nil, uniqueKey:OTMUser.uniqueKey, firstName: OTMUser.firstName, lastName: OTMUser.lastName, mapString: mapString, mediaURL: mediaURL, latitude: Float((placeMark?.location?.coordinate.latitude)!), longitude: Float((placeMark?.location?.coordinate.longitude)!), createdAt: nil, updateAt: nil)
        return publicUser
    }
    
    func configureUI(){
        finishButton.layer.cornerRadius = 5
    }
}

