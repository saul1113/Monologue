//
//  MonologueApp.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // 구글 로그인을 위해 추가할 부분
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct MonologueApp: App {
    @StateObject private var authStore = AuthManager()
    @StateObject private var userInfoStore  = UserInfoStore()
    @StateObject private var memoStore = MemoStore()
    @StateObject private var columnStore = ColumnStore()
    @StateObject private var commentStore = CommentStore()
    @StateObject private var memoImageStore = MemoImageStore()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            HomeView()
//            SearchView()
            ContentView()
                .environmentObject(authStore)
                .environmentObject(userInfoStore)
                .environmentObject(memoStore)
                .environmentObject(columnStore)
                .environmentObject(commentStore)
                .environmentObject(memoImageStore)
        }
    }
}
