//
//  LoginView.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 30/06/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    // MARK: User details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: USER DEFAULTS
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_id") var useruUID: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_profile_url") var profileURL: URL?
    
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12){
                TextField("Email", text: $emailID )
                    .textContentType(.emailAddress)
                    .border(1,.gray.opacity(0.5))
                
                SecureField("Password", text: $password )
                    .textContentType(.emailAddress)
                    .border(1,.gray.opacity(0.5))
                
                Button("Reset Password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button{
                    loginUser()
                }label: {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 20)
            }
            
            // Mark: registro
            HStack{
                Text("Dont have an account?")
                    .foregroundColor(.gray)
                Button("Register now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
            
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
          LoadingView(show: $isLoading)
        })
        
        // MARK: REGISTER VIEW VIA SHEETS
        .fullScreenCover(isPresented: $createAccount){
            RegisterView()
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    // MARK: IF USER FOUND, THEN FETCHING USER DATA FORM FIRESTORE
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        await MainActor.run(body:{
            useruUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
            
        })
    }
    
    func resetPassword(){
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }catch{
                await setError(error)
            }
        }
    }
    
    func loginUser(){
        isLoading = true
        closeKyeboard()
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            }catch{
                await setError(error)
            }
        }
    }

    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
