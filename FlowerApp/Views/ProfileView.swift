//
//  ProfileView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text(mainViewModel.currentUserEmail ?? "User")
                        .font(.title2)
                        .bold()
                }
                .padding()
                
                // User Info Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Account Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        InfoRow(title: "Email", value: mainViewModel.currentUserEmail ?? "Not available")
                        InfoRow(title: "Member Since", value: mainViewModel.userJoinDate ?? "Not available")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                .alert("Sign Out", isPresented: $showingSignOutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        mainViewModel.signOut()
                    }
                } message: {
                    Text("Are you sure you want to sign out?")
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(MainViewModel())
}
