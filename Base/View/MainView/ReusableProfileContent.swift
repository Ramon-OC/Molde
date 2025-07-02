//
//  ReusableProfileContent.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 02/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack{
                HStack(spacing: 12){
                    WebImage(url: user.userProfileURL).placeholder{
                        // MARK: placeholder image
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode:.fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        if let bioLink = URL(string: user.userBioLink){
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                        
                    }
                    .hAlign(.leading)
                    
                }
                
                Text("POSTS")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .hAlign(.leading)
                    .padding(.vertical,15)
            }
        }
    }
}




