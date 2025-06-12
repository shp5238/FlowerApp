//
//  LoginView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HeaderView()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Log In")
                            .font(.system(size: 22))
                            .foregroundColor(Color.gray)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)

                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .padding(.horizontal)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button("Login") {
                        viewModel.login()
                    }
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .padding(.horizontal, 30)
                
                if !viewModel.errorMsg.isEmpty {
                    Text(viewModel.errorMsg)
                        .foregroundColor(Color.red)
                }

                VStack(spacing: 8) {
                    Text("Don't have an account?")
                        .foregroundColor(Color.gray)
                    NavigationLink(destination: SignupView()) {
                        Text("Sign Up")
                            .foregroundColor(Color.blue)
                    }
                    .isDetailLink(false)
                }
                .padding(.bottom, 50)

                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(MainViewModel())
}

