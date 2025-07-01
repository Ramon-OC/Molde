//
//  User.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 30/06/25.
//

import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userID: String
    var userEmail: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userID
        case userEmail
        case userProfileURL
    }
}
