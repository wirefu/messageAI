//
//  LoginView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Login view for existing users
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    @FocusState private var focusedField: Field?
    
    var onSignUpTap: () -> Void
    
    enum Field {
        case email
        case password
    }
    
    var body: some View {
        VStack(spacing: AppConstants.UIConfig.largeSpacing) {
            VStack(spacing: AppConstants.UIConfig.smallSpacing) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to continue messaging")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, AppConstants.UIConfig.largeSpacing)
            
            VStack(spacing: AppConstants.UIConfig.standardSpacing) {
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .email)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                                .textContentType(.password)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                        }
                        
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password)
                }
            }
            .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            
            Button {
                Task {
                    focusedField = nil
                    await authViewModel.signIn(email: email, password: password)
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.UIConfig.minTouchTarget)
            .background(isLoginEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
            .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            .disabled(!isLoginEnabled || authViewModel.isLoading)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign Up") {
                    onSignUpTap()
                }
                .fontWeight(.medium)
            }
            .font(.subheadline)
            
            Spacer()
        }
        .errorAlert(error: Binding(
            get: { authViewModel.error },
            set: { _ in authViewModel.clearError() }
        ))
    }
    
    private var isLoginEnabled: Bool {
        email.isValidEmail && password.isNotEmpty
    }
}

#Preview {
    LoginView {
        print("Sign up tapped")
    }
    .environmentObject(AuthViewModel())
}

