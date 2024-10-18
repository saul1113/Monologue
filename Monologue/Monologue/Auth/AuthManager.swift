import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FirebaseCore

enum AuthenticationState {
    case unauthenticated // 로그인 전
    case authenticating  // 로그인 중
    case authenticated   // 로그인 후
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
    @Published var isValid: Bool = false
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
                self.email = user?.email ?? ""
            }
        }
    }
}

extension AuthManager {
    func signOut() {
        do {
            try Auth.auth().signOut()
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
        } catch {
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
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
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
    
    func NicknameDuplicate(nickname: String) async -> Bool {
        let db = Firestore.firestore()
        let query = db.collection("User").whereField("nickname", isEqualTo: nickname)
        
        do {
            let snapshot = try await query.getDocuments()
            return !snapshot.documents.isEmpty
        } catch {
            print("Error checking nickname: \(error)")
            return false
        }
    }
}
