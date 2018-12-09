//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by macos on 04/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit

class OTMTableViewController: UITableViewController {

    //Outlets
    @IBOutlet weak var pinButton: UIBarButtonItem!
    
    //Properties
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
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let studentsCount = studentsLocation?.count else {
            return 0
        }
        return studentsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OTMTableViewCell
        let firstName = studentsLocation![indexPath.row].firstName ?? "Nil"
        let lastName = studentsLocation![indexPath.row].lastName ?? "Nil"
        cell.nameLabel.text = firstName + " " + lastName
        cell.mediaURLLabel.text = studentsLocation![indexPath.row].mediaURL
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = studentsLocation![indexPath.row].mediaURL {
            if UIApplication.shared.canOpenURL(URL(string: url)!){
                let urlRequest = URLRequest(url: URL(string: url)!)
                self.request = urlRequest
                performSegue(withIdentifier: "segueToWebView", sender: self)
            } else {
                presentUIAlert("Invalid Url", nil, nil)
            }
        }
    }
    
    //MARK: - Segue
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

    @IBAction func refresh(_ sender: UIBarButtonItem) {
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
private extension OTMTableViewController {
    // MARK: - Create UIAlert
    func presentUIAlert(_ title: String?, _ message: String?,_ handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

