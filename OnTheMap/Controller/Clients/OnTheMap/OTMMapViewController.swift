//
//  OTMMapViewController.swift
//  OnTheMap
//
//  Created by macos on 03/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // Properties
    let client = OTMClient()
    var request : URLRequest? = nil
    var alert = UIAlertController()
    
    //Property Observers
    var error : Error? =  nil {
        didSet {
            presentUIAlert("Request Failed", error?.localizedDescription, nil)
        }
    }
    var requestError : Int? = nil {
        didSet {
            presentUIAlert("Request Failed", "Your request returned a status code other than 2xx!", nil)
        }
    }
    var studentsLocation : [OTMStudent]? = nil {
        didSet{
            loadMap(studentsLocation!)
        }
    }
    
    // MARK: - MapView Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let annotation = view.annotation, let annotationSubtitle = annotation.subtitle else {
                return
            }
            let url = URL(string: annotationSubtitle!)
            if UIApplication.shared.canOpenURL(url!){
                let urlRequest = URLRequest(url: url!)
                self.request = urlRequest
                performSegue(withIdentifier: "segueToWebView", sender: self)
            } else {
                presentUIAlert("Invalid Url", nil, nil)
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let identifier = "segueToWebView"
        if segue.identifier == identifier {
            guard let navigationController = segue.destination as? UINavigationController, let destination = navigationController.viewControllers.first as? OTMWebViewController else {
                return
            }
            destination.navigationTitle = "Student Media"
            destination.urlRequest = request
        }
    }
    
    @IBAction func toPostingViewController(_ sender: Any) {
        performSegue(withIdentifier: "segueToPosting", sender: sender)
    }
    
    // MARK: - Others
    func loadMap(_ studentLocations: [OTMStudent]){
        
        var annotations = [MKPointAnnotation]()
        
        for student in studentLocations {
            let lat = CLLocationDegrees(exactly: student.latitude ?? 0.0)
            let long = CLLocationDegrees(exactly: student.longitude ?? 0.0)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat ?? 0.0, longitude: long ?? 0.0)
            
            let firstName = student.firstName ?? ""
            let lastName = student.lastName ?? ""
            let mediaURL = student.mediaURL ?? ""
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        DispatchQueue.main.sync {
            self.mapView.addAnnotations(annotations)
        }
    }
  
    @IBAction func logoutButtonPressed(_ sender: Any) {
        client.logoutUser { (data, response, error) in
            guard (error == nil) else {
                self.presentUIAlert("Logout Failed", error?.localizedDescription, nil)
                return
            }
            guard let statusCode = response, statusCode >= 200 && statusCode <= 299 else {
                self.presentUIAlert("Logout Failed", error?.localizedDescription, nil)
                return
            }
            self.presentUIAlert("Logout Successful", nil, { (action) in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    @IBAction func refresh(_ sender: UIBarButtonItem){
        client.getAllStudents { (data, response, error) in
            if let error = error {
                self.presentUIAlert("Request Failed", error.localizedDescription, nil)
            } else {
                if let result = data {
                    OTMStudents.sharedInstance?.removeAll()
                    OTMStudents.sharedInstance = result
                    self.studentsLocation = OTMStudents.sharedInstance
                }
            }
        }
    }
}

//MARK: - UI Config Methods
private extension OTMMapViewController {
    // MARK: - Create UIAlert
    func presentUIAlert(_ title: String?, _ message: String?,_ handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
