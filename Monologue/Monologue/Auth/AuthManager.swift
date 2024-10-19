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
    
    // 로그인 버튼 클릭 후 과정 거치면 user가 무조건 생성
    // 그러면 자동로그인 기능때문에 회원가입 시 sheet가 안띄어짐
    // 그래서 닉네임이 존재하는지 안하는 지 체크하는 용도, user와 닉네임 없으면 sheet 띄어짐
    @Published var nicknameExists: Bool {
            didSet {
                UserDefaults.standard.set(nicknameExists, forKey: "nicknameExists")
            }
        }
    // LoginView에서 state로 사용했는데, 로그아웃 후 로그인 뷰에서 실시간 변화가 없어서 여기에 추가..
    @Published var isPresented: Bool = false
    
    init() {
        self.nicknameExists = UserDefaults.standard.bool(forKey: "nicknameExists")
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
            self.nicknameExists = false
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
            
            self.userID = "\(firebaseUser.uid)"
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
            return false
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
