//
//  NavigationAppearance.swift
//  Monologue
//
//  Created by Hyojeong on 10/22/24.
//

import SwiftUI

func setupNavigationBarAppearance(backgroundColor: UIColor = .background) {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = backgroundColor
    appearance.titleTextAttributes = [.foregroundColor: UIColor.accent]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
    appearance.shadowColor = nil
    
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
}
