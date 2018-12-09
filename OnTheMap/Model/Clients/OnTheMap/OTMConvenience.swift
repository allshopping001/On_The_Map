//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by macos on 28/09/18.
//  Copyright © 2018 macos. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient{
    
    
    // MARK: - Get All Students Method
    func getAllStudents(_ completionHandler: @escaping (_ results: [OTMStudent]?, _ statusCode: Int?, _ error: Error?) ->Void){
        
        let method = OTMClient.Methods.StudentLocation
        let parameters : [String:AnyObject] = [
            OTMClient.ParametersKeys.Limit: 100 as AnyObject, OTMClient.ParametersKeys.Order: "-updatedAt" as AnyObject
        ]
        
        let _ = taskForGetMethod(method, parameters: parameters as [String : AnyObject]) { (data, response, error) in
            guard (error == nil) else {
                completionHandler(nil, nil, error)
                return
            }
            if let statusCode = response, statusCode <= 200 || statusCode >= 299  {
                completionHandler(nil, statusCode, nil)
            } else {
                if let results = data as! OTMRoot? {
                    completionHandler(results.results, nil, nil)
                }
            }
        }
    }
    
    // MARK: - Get a Student Method
    func getAStudent(_ uniqueKey:String, _ completionHandler: @escaping (_ results: OTMStudent?, _ statusCode: Int?, _ error: Error?)-> Void){
       
        let method = Methods.StudentLocation
        let mutableParameter = substituteKeyInMethod(ParametersKeys.UniqueKey, key: URLKeys.UniqueKey, value: uniqueKey)!
        let parameters = [ParametersKeys.Where : mutableParameter]
        
        let _ = taskForGetMethod(method, parameters: parameters as [String : AnyObject]) { (data, response, error) in
            if let error = error {
                completionHandler(nil, response, error)
            } else {
                if let result = data as? OTMRoot  {
                    completionHandler(result.results.first, response, nil)
                    print(result)
                } else {
                    completionHandler(nil, response, nil)
                }
            }
        }
    }
    
    //MARK: - Post a Student Method
    func postAStudent(_ student: OTMStudent, completionHandler: @escaping (_ result: OTMNewStudent?, _ statusCode: Int?, _ error : Error? )-> Void){
        
        let method = Methods.StudentLocation
        let parameters : [String:AnyObject] = [:]
        
        let _ = taskForPOSTMethod(method, parameters: parameters, student: student) { (data, response, error) in
            guard (error == nil) else {
                completionHandler(nil, nil, error)
                return
            }
            if let statusCode = response, statusCode <= 200 || statusCode >= 299  {
                completionHandler(nil, statusCode, nil)
            } else {
                if let results = data as! OTMNewStudent? {
                    completionHandler(results, nil, nil)
                }
            }
        }
    }

    
    //MARK: - Put a Student Method
    func putAStudent(_ objectId: String, _ student: OTMStudent, completionHandler: @escaping (_ result: OTMUpdatedStudent?, _ statusCode: Int?, _ error: Error?) -> Void){
        
        let method = Methods.PutAStudentLocation
        let mutableMethod =  substituteKeyInMethod(method, key: URLKeys.ObjectId, value: objectId)!
        let parameters : [String:AnyObject] = [:]
        
        let _ = taskForPUTMethod(mutableMethod, parameters: parameters, student: student) { (data, response, error) in
            if let error = error {
                completionHandler(nil, response, error)
            } else {
                if let result = data as? OTMUpdatedStudent {
                    completionHandler(result, response, nil)
                } else {
                    completionHandler(nil, response, error)
                }
            }
        }
    }
    
    func getPublicUser(_ userId: String, completionHandler: @escaping (_ result: [String:AnyObject]?, _ statusCode: Int?, _ error : Error? )-> Void) {
        
        let method = Methods.GetPublicData
        let mutableMethod = substituteKeyInMethod(method, key: URLKeys.UserId, value: userId)!
        let parameters : [String:AnyObject] = [:]
      
        let _ = taskForGetPublicUserMethod(mutableMethod, parameters: parameters) { (data, response, error) in
            if let error = error {
                completionHandler(nil, response, error)
            } else {
                if let result = data as? [String:AnyObject] {
                    completionHandler(result, response, nil)
                } else {
                    completionHandler(nil, response, error)
                }
            }
        }
    }
}
