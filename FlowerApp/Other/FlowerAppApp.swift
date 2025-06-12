//
//  FlowerAppApp.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import FirebaseCore
import SwiftUI

@main
struct FlowerAppApp: App {
    @StateObject private var mainViewModel = MainViewModel()
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mainViewModel)
        }
    }
}

