//
//  AuthViewModel.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - 1. THE VIEW MODEL (The Brain)
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isAdmin = false
    @Published var errorMessage = ""
    
    init() {
        if Auth.auth().currentUser != nil {
            self.isAuthenticated = true
            self.checkAdminStatus()
        }
    }
    
    // Logs in an existing user
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isAuthenticated = true
            self.checkAdminStatus()
            self.errorMessage = ""
        }
    }
    
    // Creates a brand new user
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isAuthenticated = true
            self.checkAdminStatus()
            self.errorMessage = ""
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        self.isAuthenticated = false
        self.isAdmin = false
    }
    
    func checkAdminStatus() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Make sure this matches the email you registered for the Admin account!
        if user.email == "swapnilthakre@gmail.com" {
            self.isAdmin = true
        }
    }
}

// MARK: - 2. THE LOGIN & REGISTRATION UI
struct LoginSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
    // This single variable controls whether we are logging in or signing up
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // The title changes based on the mode
                Text(isLoginMode ? "Library Access" : "Create Account")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !authVM.errorMessage.isEmpty {
                    Text(authVM.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                
                // The Main Action Button
                Button(action: {
                    if isLoginMode {
                        authVM.login(email: email, password: password)
                    } else {
                        authVM.register(email: email, password: password)
                    }
                }) {
                    Text(isLoginMode ? "Sign In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                // The Mode Switcher Button
                Button(action: {
                    isLoginMode.toggle()
                    authVM.errorMessage = "" // Clear any errors when switching modes
                }) {
                    Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .onChange(of: authVM.isAuthenticated) { authenticated in
                if authenticated { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
