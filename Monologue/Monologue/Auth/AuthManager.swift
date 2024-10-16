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
    @Published var name: String = ""
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
    func signOut() {
        do {
//            try Auth.auth().signOut()

            self.authenticationState = .unauthenticated  // 상태를 로그아웃 상태로 업데이트
            print("로그아웃 성공")
        }
//        catch {
//            print("Error signing out: \(error.localizedDescription)")
//            self.errorMessage = error.localizedDescription
//        }
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
            
            //            authenticationState = .authenticated
            //            return true
            
//            return await checkNicknameExists(email: self.email)
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // 처음 가입할 때 닉네임 존재 여부 확인 메서드 추가 -> 있다면 바로 로그인, 없다면 가입으로
    func checkNicknameExists(email: String) async -> Bool {
        let db = Firestore.firestore()
        let docRef = db.collection("User").document(email)
        
        do {
            let document = try await docRef.getDocument()
            if let data = document.data(), let nickname = data["nickname"] as? String, !nickname.isEmpty {
                return true
            }
        } catch {
            print("Error checking nickname: \(error)")
        }
        return false
    }
    
    // 가입할 때, 닉네임 입력 시 중복된 것이 있는 지 확인 -> 중복이라면 다른 닉네임 입력
    func NicknameDuplicate(nickname: String) async -> Bool {
        let db = Firestore.firestore()
        let query = db.collection("User").whereField("nickname", isEqualTo: nickname)
        
        do {
            let snapshot = try await query.getDocuments()
            return !snapshot.documents.isEmpty // 중복된 닉네임이 있으면 true
        } catch {
            print("Error checking nickname: \(error)")
            return false
        }
    }
}


