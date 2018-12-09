//
//  OTMClient.swift
//  OnTheMap
//
//  Created by macos on 28/09/18.
//  Copyright © 2018 macos. All rights reserved.
//

import Foundation

class OTMClient: NSObject{
 
    // Properties
    var session = URLSession.shared
    var sessionID: String? = nil
    
    //MARK: - Login Method
    func taskForLoginUser(username: String, password: String, _ completionHandlerForLogin: @escaping (_ result: [String:AnyObject]?, _ statusCode: Int?, _ error: Error?)-> Void){
        
        let parameters = ["udacity": ["username": "\(username)", "password": "\(password)"]]
        var bodyParameters = Data()
        
        do {
            bodyParameters = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
        } catch {
            print("couldnt build parameters")
        }
        
        let url = "\(OTMClient.Constants.AuthorizationURL)"
        var request = URLRequest(url: URL(string: "\(url)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyParameters
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            // Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForLogin(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                completionHandlerForLogin(nil, statusCode, nil)
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            
            var json = [String:AnyObject]()
            do {
                json = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("couldnt serialize data")
            }
            completionHandlerForLogin(json, statusCode, nil)
            
            guard let userAccount = json["account"], let userKey = userAccount["key"] else {
                return
            }
            print(String(data: newData, encoding: .utf8)!)
            // Save User Id to a Shares Instance
            OTMUser.uniqueKey = userKey as? String
            }
        
        task.resume()
    }
    
    //MARK: - Logout Method
    func logoutUser(_ completionHandlerForLogout: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?)-> Void){
        let url = "\(OTMClient.Constants.AuthorizationURL)"
        var request = URLRequest(url: URL(string: "\(url)")!)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForLogout(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            //print(String(data: newData, encoding: .utf8)!)
            completionHandlerForLogout(newData, statusCode, nil)
        }
        task.resume()
    }
    
    //MARK: - Put Method
    func taskForPUTMethod(_ method: String, parameters: [String:AnyObject], student: OTMStudent, completionHandlerForPut: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: createURLFromMethod(method, parameters: parameters))
        request.httpMethod = "PUT"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParametersKeys.ApplicationID)
        request.addValue(Constants.ApiKey, forHTTPHeaderField: ParametersKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request)
        
        let encoder = JSONEncoder()
        do {
            let editedStudentAsJson = try encoder.encode(student)
            request.httpBody =  editedStudentAsJson
        } catch {
            print(error)
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForPut(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                completionHandlerForPut(nil, statusCode, nil)
                return
            }
            self.parseJSON("taskForPutMethod", data, completionHandlerForData: completionHandlerForPut)
        }
        task.resume()
        return task
    }
    
    //MARK: - Post Method
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], student: OTMStudent, completionHandlerForPost: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: createURLFromMethod(method, parameters: parameters))
        request.httpMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParametersKeys.ApplicationID)
        request.addValue(Constants.ApiKey, forHTTPHeaderField: ParametersKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let newStudentAsJson = try encoder.encode(student)
            request.httpBody = newStudentAsJson
        } catch {
            print(error)
        }
       
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForPost(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                completionHandlerForPost(nil, statusCode, nil)
                return
            }
            self.parseJSON("taskForPostMethod", data, completionHandlerForData: completionHandlerForPost)
        }
        task.resume()
        return task
    }
    
    //MARK: - Get Public Data Method
    func taskForGetPublicUserMethod(_ method: String, parameters: [String:AnyObject], _ completionHandlerForPublicData: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?)-> Void) -> URLSessionDataTask {
        
        let request = URLRequest(url: createURLFromMethod(method, parameters: parameters))

        let task = session.dataTask(with: request) { (data, response, error) in
            //Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForPublicData(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            
            self.parseJSON("taskForGetPublicUserMethod", newData, completionHandlerForData: completionHandlerForPublicData)
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Get Method
    func taskForGetMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGet: @escaping (_ result: Any?, _ statusCode: Int?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: createURLFromMethod(method, parameters: parameters))
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            //Print Error Or Bad Status Code
            func sendError(error: Error?, response: URLResponse?) {
                print("Error: \(error.debugDescription)", "\nResponse: \(response.debugDescription)")
                completionHandlerForGet(nil, (response as? HTTPURLResponse)?.statusCode, error)
            }
            /* GUARD: Error */
            guard (error == nil) else {
                sendError( error: error, response: nil)
                return
            }
            /* GUARD: Response */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: nil, response: response)
                return
            }
            /* GUARD: Data */
            guard let data = data else {
                return
            }
            self.parseJSON("taskForGetMethod", data, completionHandlerForData: completionHandlerForGet)
        }
        task.resume()
        return task
    }
    
    // MARK: - Convert Data Method
    private func parseJSON(_ method:String, _ data: Data, completionHandlerForData: (_ result: Any?, _ statusCode: Int?, _ error: Error?)-> Void){
        
        let decoder = JSONDecoder()
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        var result: Any?
        
        do {
            switch method {
            case "taskForGetMethod":
                do{
                    result = try decoder.decode(OTMRoot.self, from: data)
                    completionHandlerForData(result, nil, nil)
                } catch {
                    completionHandlerForData(nil, nil, NSError(domain: "convertDataWithCompletionHandlerForGet", code: 1, userInfo: userInfo))
                }
                
            case "taskForPostMethod" :
                do {
                    result = try decoder.decode(OTMNewStudent.self, from: data)
                    completionHandlerForData(result, nil, nil)
                } catch {
                    completionHandlerForData(nil, nil, NSError(domain: "convertDataWithCompletionHandlerForPost", code: 1, userInfo: userInfo))
                }
                
            case "taskForPutMethod":
                do{
                    result = try decoder.decode(OTMUpdatedStudent.self, from: data)
                    completionHandlerForData(result, nil, nil)
                }catch{
                    completionHandlerForData(nil, nil, NSError(domain: "convertDataWithCompletionHandlerForPut", code: 1, userInfo: userInfo))
                }
                
            case "taskForGetPublicUserMethod":
                var json = [String:AnyObject]()
                do{
                    json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                    completionHandlerForData(json, nil, nil)
                } catch {
                    completionHandlerForData(nil, nil, NSError(domain: "convertDataWithCompletionHandlerForFetPublicUser", code: 1, userInfo: userInfo))
                }
               
            default:
                print("converDataError")
                
                }
            }
        }
 
    // MARK: - Helper Methods
    
    private func createURLFromMethod(_ method: String, parameters: [String:AnyObject]? ) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        
        // Check for Host Component Type
        if method.contains("api"){
            components.host = OTMClient.Constants.ApiHost
        } else {
            components.host = OTMClient.Constants.ParseHost
        }
        components.path = method
        components.queryItems = [URLQueryItem]()
        
        //Check if parameters exist
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "<\(key)>") != nil {
            return method.replacingOccurrences(of: "<\(key)>", with: value)
        } else {
            return nil
        }
    }
  
    // MARK: - Shared Instance
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
