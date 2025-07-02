//
//  MainView.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 01/07/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        // MARK: TABVIEW WITH RECNT POST AND PROFILE TABS
        TabView{
            Text("Recent Post's")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // changing tab label tint to black
        .tint(.black)
        
    }
}

struct MainView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
