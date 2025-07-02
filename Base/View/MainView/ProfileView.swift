//
//  ProfileView.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 01/07/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    // MARK: my profile data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: view properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            // MARK: REFRESH USER DATA
                            self.myProfile = nil
                            await fetchUserData()
                        }
                }else{
                    ProgressView()
                }
            }
            
            .navigationTitle("My Profile")
            
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        // MARK: TWO ACTIONS
                        // 1. logout
                        // 2. delete account
                        Button("Logout",action: logOutUser)
                        
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                        
                        
                    }label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay{
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError){
            
        }
        .task {
            // This modifier is like onAppear
            if myProfile != nil {return}
            // MARK: initial fetch
            await fetchUserData()
        }
    }
    
    // MARK: Fetching data
    func fetchUserData()async{
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as:
                                                User.self) else {return}
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    // MARK: LOGING USER OUT
    func logOutUser(){
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    // MARK: DELETING USER ENTIRE ACCOUNT
    func deleteAccount(){
        isLoading = true
        
        Task{
            do{
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                // step 1: firsr deleting profile image form stogae
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                // step 2: deleting firebase user document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // final step: deleting auth account and settung log status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: setting error
    func setError(_ error: Error)async{
        // MARK: UI must be tun on main thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
}

struct ProfileView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
