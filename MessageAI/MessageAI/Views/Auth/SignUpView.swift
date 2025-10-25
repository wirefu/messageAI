//
//  SignUpView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Sign up view for new users
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    @FocusState private var focusedField: Field?
    
    var onLoginTap: () -> Void
    
    enum Field {
        case displayName
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        VStack(spacing: AppConstants.UIConfig.largeSpacing) {
            VStack(spacing: AppConstants.UIConfig.smallSpacing) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Join your team on MessengerAI")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, AppConstants.UIConfig.standardSpacing)
            
            VStack(spacing: AppConstants.UIConfig.standardSpacing) {
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Display Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Your name", text: $displayName)
                        .textContentType(.name)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .displayName)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("your.email@company.com", text: $email)
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
                            TextField("At least 8 characters", text: $password)
                                .textContentType(.newPassword)
                        } else {
                            SecureField("At least 8 characters", text: $password)
                                .textContentType(.newPassword)
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
                    
                    if !password.isEmpty && password.count < AppConstants.Validation.minPasswordLength {
                        Text("Password must be at least \(AppConstants.Validation.minPasswordLength) characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: AppConstants.UIConfig.smallSpacing) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Re-enter password", text: $confirmPassword)
                                .textContentType(.newPassword)
                        } else {
                            SecureField("Re-enter password", text: $confirmPassword)
                                .textContentType(.newPassword)
                        }
                        
                        Button {
                            isConfirmPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .confirmPassword)
                    
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords don't match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            
            Button {
                Task {
                    focusedField = nil
                    await authViewModel.signUp(
                        email: email,
                        password: password,
                        displayName: displayName
                    )
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.UIConfig.minTouchTarget)
            .background(isSignUpEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.UIConfig.messageBubbleRadius)
            .padding(.horizontal, AppConstants.UIConfig.standardSpacing)
            .disabled(!isSignUpEnabled || authViewModel.isLoading)
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                
                Button("Login") {
                    onLoginTap()
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
    
    private var isSignUpEnabled: Bool {
        displayName.hasMinimumLength(AppConstants.Validation.minDisplayNameLength) &&
        email.isValidEmail &&
        password.hasMinimumLength(AppConstants.Validation.minPasswordLength) &&
        password == confirmPassword
    }
}

#Preview {
    SignUpView {
        print("Login tapped")
    }
    .environmentObject(AuthViewModel())
}
