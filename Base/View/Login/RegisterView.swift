//
//  RegisterView.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 01/07/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

// MARK: Register View
struct RegisterView: View {
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
    // MARK: View Properties
    @Environment(\.dismiss) var dissmiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: USER DEFAULTS
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_id") var userID: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_profile_url") var profileURL: URL?
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Register Account")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello User, nice to meet you!")
                .font(.title3)
                .hAlign(.leading)
            
            ViewThatFits{
                ScrollView(.vertical, showsIndicators: false){
                    helperView()
                }
                helperView()
            }
            
            // Mark: registro
            HStack{
                Text("Already Have an Account?")
                    .foregroundColor(.gray)
                Button("Login Now"){
                    dissmiss()
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
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem){ newValue in
            // Extract UI IMAG
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                        await MainActor.run(body: {userProfilePicData = imageData})
                    }catch{}
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        
    }
    
    @ViewBuilder
    func helperView() -> some View{
        VStack(spacing: 12){
            
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            TextField("Username", text: $userName )
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
                .padding(.top, 25)
            
            TextField("Email", text: $emailID )
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
            
            SecureField("Password", text: $password )
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink )
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
        
            
            Button{
                registerUser()
            }label: {
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(userName == "" || emailID == "" || password == "" || userBio == "" || userProfilePicData == nil)
            .padding(.top, 20)
        }
    }
    
    
    
    func registerUser(){
        isLoading = true
        closeKyeboard()
        Task{
            do{
                // STEP 01: creatung firebase account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // STEP 02: uploading photo in firebase
                guard let userID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userID)
                let _ = try await storageRef.putDataAsync(imageData)
                // STEP 03: downloading photo  URL
                let downladURL = try await storageRef.downloadURL()
                // STEP 04: creating a user firestore object
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userID: userID, userEmail: emailID, userProfileURL: downladURL)
                // STEP 04: SAVING USER DOC INTO FIRESTORE
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: {
                    error in
                    if error == nil{
                        print("Saved succesfull")
                        userNameStored = userName
                        self.userID = userID
                        profileURL = downladURL
                        logStatus = true
                    }
                })
            }catch{
                // MARK: deleting created account in case of failure
                // try await Auth.auth().currentUser?.delete()
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

struct RegisterView_Previws: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
