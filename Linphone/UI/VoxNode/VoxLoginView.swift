//
//  VoxLoginView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI

struct VoxLoginView: View {
    @ObservedObject var accountViewModel: AccountLoginViewModel
    
    @State private var selectedAccount = "VoipPhone"
    @State private var isPasswordVisible = false
    @State private var isDropdownExpanded = false
    
    private let accounts = ["VoipPhone", "Account1", "Account2", "Account3"]
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 16) {
                    // App Icon (3x3 grid with hand pointing)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.lightBlueMain300)
                            .frame(width: 60, height: 60)
                        
                        // 3x3 grid of dots
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                            }
                            HStack(spacing: 4) {
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                            }
                            HStack(spacing: 4) {
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                            }
                        }
                    }
                    
                    // Title
                    HStack(spacing: 0) {
                        Text("VoIP")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text(" PHONE")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                // Input Fields
                VStack(spacing: 16) {
                    // Account Dropdown
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        HStack {
                            Text(selectedAccount)
                                .foregroundColor(.primary)
                                .padding(.leading, 16)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isDropdownExpanded.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                                    .rotationEffect(.degrees(isDropdownExpanded ? 180 : 0))
                                    .padding(.trailing, 16)
                            }
                        }
                        .frame(height: 50)
                    }
                    .frame(height: 50)
                    .overlay(
                        // Dropdown menu
                        VStack {
                            if isDropdownExpanded {
                                VStack(spacing: 0) {
                                    ForEach(accounts, id: \.self) { account in
                                        Button(action: {
                                            selectedAccount = account
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isDropdownExpanded = false
                                            }
                                        }) {
                                            HStack {
                                                Text(account)
                                                    .foregroundColor(.primary)
                                                    .padding(.leading, 16)
                                                Spacer()
                                            }
                                            .frame(height: 40)
                                            .background(selectedAccount == account ? Color.blue.opacity(0.1) : Color.white)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                .offset(y: 50)
                                .zIndex(1)
                            }
                        }
                    )
                    
                    // Email Field
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Text("@")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 16)
                        
                        TextField("Email", text: $accountViewModel.username)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    
                    // Password Field
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 16)
                        
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $accountViewModel.passwd)
                                    .textFieldStyle(PlainTextFieldStyle())
                            } else {
                                SecureField("Password", text: $accountViewModel.passwd)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.blue)
                                .padding(.trailing, 16)
                        }
                    }
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, 24)
                
                // Login Button
                Button(action: {
                    self.accountViewModel.login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onTapGesture {
            // Dismiss dropdown when tapping outside
            if isDropdownExpanded {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isDropdownExpanded = false
                }
            }
        }
    }
}

#Preview {
    VoxLoginView(accountViewModel: AccountLoginViewModel())
}

