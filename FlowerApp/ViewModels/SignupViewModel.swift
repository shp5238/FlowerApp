//
//  SignupViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMsg: String = ""
    
    init(){}
    
    func signUp() {
        guard validate() else {
            return
        }
        
        //register the user in Firebase
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMsg = error.localizedDescription
                    return
                }
                
                guard let userId = result?.user.uid else {
                    self?.errorMsg = "Failed to create user"
                    return
                }
                
                self?.insertUserRecord(id: userId)
            }
        }
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id, email: email, joined: Date().timeIntervalSince1970)
        
        //insert into db
        do {
            let data = try newUser.asDictionary()
            let db = Firestore.firestore()
            db.collection("users")
                .document(id)
                .setData(data) { [weak self] error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.errorMsg = "Failed to save user data: \(error.localizedDescription)"
                        }
                    }
                }
        } catch {
            DispatchQueue.main.async {
                self.errorMsg = "Failed to save user data: \(error.localizedDescription)"
            }
        }
    }
    
    private func validate() -> Bool {
        errorMsg = "" //reset error msg
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMsg = "Please fill in all fields"
            return false
        }
        
        //check for '@' and '.' characters
        guard email.contains("@") && email.contains(".") else {
            errorMsg = "Invalid email format"
            return false
        }
        
        //password validation
        guard password.count >= 8 else {
            errorMsg = "Please choose a password 8 characters or more"
            return false
        }
        
        guard password == confirmPassword else {
            errorMsg = "Passwords do not match"
            return false
        }
        
        return true
    }
}
