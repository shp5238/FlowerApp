//
//  MainTabViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class MainViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var currentUserEmail: String?
    @Published var userJoinDate: String?
    @Published var isLoggedIn: Bool = false
    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                self?.currentUserEmail = user?.email
                self?.isLoggedIn = user != nil
                if let user = user {
                    self?.fetchUserData(userId: user.uid)
                }
            }
        }
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    private func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                if let joined = document.data()?["joined"] as? TimeInterval {
                    let date = Date(timeIntervalSince1970: joined)
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    self?.userJoinDate = formatter.string(from: date)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUserId = ""
            self.currentUserEmail = nil
            self.userJoinDate = nil
            self.isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
