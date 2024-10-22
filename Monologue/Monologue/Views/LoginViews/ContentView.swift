import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        
        switch authManager.authenticationState {
        case .unauthenticated, .authenticating: // 로그인 중 아니면 로그인 전
            LoginView()
                .environmentObject(authManager)
            
        case .authenticated: // 로그인 후
            if authManager.nicknameExists { // 닉네임이 있는지도 확인
                MainView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
