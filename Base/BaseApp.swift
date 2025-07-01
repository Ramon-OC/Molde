//
//  BaseApp.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 30/06/25.
//

import SwiftUI
import Firebase

@main
struct BaseApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
