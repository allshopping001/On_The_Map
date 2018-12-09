//
//  Constants.swift
//  OnTheMap
//
//  Created by macos on 28/09/18.
//  Copyright © 2018 macos. All rights reserved.
//

extension OTMClient {
    
    //MARK: - Constants
    struct Constants {
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiScheme = "https"
        static let ApiHost = "udacity.com"
        static let ParseHost = "parse.udacity.com"
        static let AuthorizationURL = "https://www.udacity.com/api/session"
        static let SignUpURL = "https://auth.udacity.com/sign-up"
        
    }
    
    //MARK: Method Parameters
    struct ParametersKeys {
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        static let Limit = "limit"
        static let Order = "order"
        static let Where = "where"
        static let UniqueKey = "{\"uniqueKey\":\"<uniqueKey>\"}"
    }
    
    //MARK: Methods
    struct Methods {
        static let AuthenticationSessionNew = "/session"
        static let StudentLocation = "/parse/classes/StudentLocation"
        static let PutAStudentLocation = "/parse/classes/StudentLocation/<objectId>"
        static let GetPublicData = "/api/users/<user_id>"
    }
    
    //MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        static let StudentsResults = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdateAt = "updatedAt"
        
    }
    
    // MARK: URLKeys
    struct URLKeys {
        static let UniqueKey =  "uniqueKey"
        static let ObjectId = "objectId"
        static let UserId = "user_id"
    }
    
    
}
