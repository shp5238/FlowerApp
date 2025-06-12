//
//  SignupView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HeaderView()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Sign Up")
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

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .padding(.horizontal)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button("Sign Up") {
                        viewModel.signUp()
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
                    Text("Already have an account?")
                        .foregroundColor(Color.gray)
                    NavigationLink(destination: LoginView(), isActive: $showLogin) {
                        Button("Login here") {
                            showLogin = true
                        }
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
    SignupView()
}

