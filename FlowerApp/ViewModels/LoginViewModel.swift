//
//  LoginViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//


//print("Logging in with email: \(email) and password: \(password)")
import FirebaseAuth
import Foundation

class LoginViewModel: ObservableObject{
    //published properties that update views instantly
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMsg: String = ""
    
    init(){}
    
    func login(){
        guard validate() else{
            return
        }
        
        //attempt login
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error{
                    self?.errorMsg = error.localizedDescription
                    return
                }
                
                //successful login
                self?.errorMsg = ""
                print("successful login for \(result?.user.uid ?? "")")
            }
        }
        
    }
    
    private func validate() -> Bool{
        errorMsg = "" //reset error msg
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMsg = "Please fill in all fields"
            return false
        }
        
        //check for '@' and '.' characters
        guard email.contains("@") && email.contains(".") else {
            errorMsg = "Invalid email format"
            return false
        }
        print("Called Login")
        return true
    }
}
