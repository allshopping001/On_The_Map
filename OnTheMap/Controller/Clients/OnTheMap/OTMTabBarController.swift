//
//  OTMTabBarController.swift
//  OnTheMap
//
//  Created by macos on 04/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {

    // Properties
    var mapVC : OTMMapViewController? = nil
    var tableVC : OTMTableViewController? = nil
    let client = OTMClient()
    
    //Property Observers
    var studentsLocation : [OTMStudent]? {
        didSet{
            OTMStudents.sharedInstance = studentsLocation!
            mapVC?.studentsLocation = OTMStudents.sharedInstance
            tableVC?.studentsLocation = OTMStudents.sharedInstance
        }
    }
    var requestError : Int? {
        didSet {
            mapVC?.requestError = requestError
            tableVC?.requestError = requestError
        }
    }
    var error : Error? {
        didSet {
            mapVC?.error = error
            tableVC?.error = error
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        instantiateViewControllers()
        getStudentsLocation()
        getPublicUser()
    }
    
    func instantiateViewControllers(){
        guard let viewControllersArray = self.viewControllers, let firstNavigationController = viewControllersArray[0] as? UINavigationController, let secondNavigationController = viewControllersArray[1] as? UINavigationController else {
            return
        }
        mapVC = firstNavigationController.viewControllers.first as? OTMMapViewController
        tableVC = secondNavigationController.viewControllers.first as? OTMTableViewController
    }
    
    // MARK: - Fetch Students Locations
    func getStudentsLocation(){
        client.getAllStudents { (data, response, error) in
            guard ( error == nil ) else {
                self.error = error
                return
            }
            guard (response == nil) else {
                self.requestError = response
                return
            }
            guard let result = data else {
                return
            }
            self.studentsLocation = result
        }
    }
    
    // MARK: - Fetch Public User
    func getPublicUser(){
        client.getPublicUser(OTMUser.uniqueKey!) { (data, response, error) in
            guard ( error == nil ) else {
                self.error = error
                return
            }
            if let statusCode = response, statusCode <= 200 && statusCode >= 299  {
                self.requestError = statusCode
            }
            guard let result = data else {
                return
            }
            guard let user = result["user"], let firstName = user["first_name"], let lastName = user["last_name"] else {
                return
            }
            OTMUser.firstName = firstName as? String; OTMUser.lastName = lastName as? String
        }
    }
}
