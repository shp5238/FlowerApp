//
//  MainView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation
import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var showingProfile = false
    @State private var showingNewTask = false
    
    var body: some View {
        //if already logged in, no need to relogin every time.
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            //signed in state
            TabView {
                TodoListView()
                    .tabItem {
                        Label("Todo List", systemImage: "list.bullet")
                    }
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                NotepadView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Notepad", systemImage: "note.text")
                    }
            }
            .overlay(
                HStack(spacing: 16) {
                    Button(action: {
                        showingNewTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .sheet(isPresented: $showingProfile) {
                    ProfileView()
                        .environmentObject(viewModel)
                }
                .sheet(isPresented: $showingNewTask) {
                    NewTaskView()
                },
                alignment: .topTrailing
            )
        } else {
            LoginView()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
