//
//  AuthManager.swift
//  Monologue
//
//  Created by 김종혁 on 10/14/24.
//

import Foundation
import Observation

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthManager: ObservableObject {
    @Published var name: String = "unkown"
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid: Bool  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var photoURL: URL?
    @Published var userID: String = ""
    
    @Published var profileInfo: ProfileInfo = ProfileInfo(nickname: "", registrationDate: Date())

    init() {
             registerAuthStateHandler()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.displayName ?? ""
                self.photoURL = user?.photoURL
                self.email = user?.email ?? "" // 사용자 이메일 설정
                
            }
        }
    }
}

extension AuthManager {
    // 처음 로그인 시 파베에 이메일 바로 저장
    func createProfile(nickname: String) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(email).collection("profileInfo").document("profileDoc").setData([
                "nickname": nickname,
                "registrationDate": profileInfo.registrationDate,
            ])
        } catch {
            print(error)
        }
    }
    
    func loadUserProfile(email: String) async {
        do {
            let db = Firestore.firestore()
            let snapshots = try await db.collection("User").document(email).collection("profileInfo").getDocuments()
            
            for document in snapshots.documents {
                let docData = document.data()
                let nickname: String = email
                
                let registrationTimestamp = docData["registrationDate"] as? Timestamp
                let registrationDate: Date = registrationTimestamp?.dateValue() ?? Date()
                
                self.profileInfo = ProfileInfo(
                    nickname: nickname,
                    registrationDate: registrationDate
                )
            }
        } catch{
            print("\(error)")
        }
    }
    
//    func signInWithEmailPassword() async -> Bool {
//        authenticationState = .authenticating
//        do {
//            // 로그인 시 이메일 설정
//            self.email = try await Auth.auth().signIn(withEmail: self.email, password: self.password).user.email ?? ""
//            return true
//        }
//        catch  {
//            print(error)
//            errorMessage = error.localizedDescription
//            authenticationState = .unauthenticated
//            return false
//        }
//    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.email = ""
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

extension AuthManager {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")

            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            
            self.userID = firebaseUser.uid

            self.email = firebaseUser.email ?? ""  // 구글 로그인하면 이메일 설정
            
            await loadUserProfile(email: email)
            
            await createProfile(nickname: email)
            
            authenticationState = .authenticated
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}


