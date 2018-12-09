//
//  OTMStudents.swift
//  OnTheMap
//
//  Created by macos on 28/09/18.
//  Copyright © 2018 macos. All rights reserved.
//

import Foundation

struct OTMRoot: Codable {
    let results: [OTMStudent]
}

// Student Struct
struct OTMStudent: Codable {
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Float?
    let longitude: Float?
    let createdAt : String?
    let updateAt : String?
}

// New Student Struct
struct OTMNewStudent: Codable {
    let objectId: String?
    let createdAt : String?
}

// Updated Student Struct
struct OTMUpdatedStudent: Codable {
    let updatedAt: String?
}







