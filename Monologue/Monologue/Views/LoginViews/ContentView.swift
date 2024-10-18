import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        switch authManager.authenticationState {
        case .unauthenticated, .authenticating: // 로그인 중 아니면 로그인 전
            LoginView()
                .environmentObject(authManager)
            
        case .authenticated: // 로그인 후
            MainView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
