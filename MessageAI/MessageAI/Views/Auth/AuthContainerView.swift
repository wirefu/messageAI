//
//  AuthContainerView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Container view managing authentication flow navigation
struct AuthContainerView: View {
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            if showingSignUp {
                SignUpView {
                    withAnimation {
                        showingSignUp = false
                    }
                }
                .transition(.move(edge: .trailing))
            } else {
                LoginView {
                    withAnimation {
                        showingSignUp = true
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .dismissKeyboardOnTap()
    }
}

#Preview {
    AuthContainerView()
        .environmentObject(AuthViewModel())
}

