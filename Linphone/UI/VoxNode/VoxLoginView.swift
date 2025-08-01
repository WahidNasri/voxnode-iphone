//
//  VoxLoginView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI

// VoxNodeProvider data model
struct VoxNodeProvider: Codable, Identifiable, Hashable {
    let providerId: Int
    let providerName: String
    let providerSite: String
    let providerLogo: String
    let providerColor1: String
    let providerColor2: String
    let providerLanguage: String
    let providerEnabled: Int
    
    var id: Int { providerId }
    
    var isEnabled: Bool {
        return providerEnabled == 1
    }
    
    var primaryColor: Color {
        return Color(hex: providerColor1) ?? .blue
    }
    
    var secondaryColor: Color {
        return Color(hex: providerColor2) ?? .blue
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(providerId)
    }
    
    static func == (lhs: VoxNodeProvider, rhs: VoxNodeProvider) -> Bool {
        return lhs.providerId == rhs.providerId
    }
}

struct VoxLoginView: View {
    @ObservedObject var accountViewModel: AccountLoginViewModel
    
    @State private var selectedProvider: VoxNodeProvider?
    @State private var providers: [VoxNodeProvider] = []
    @State private var isPasswordVisible = false
    @State private var isDropdownExpanded = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Computed properties to simplify complex expressions
    private var logoColor: Color {
        return selectedProvider?.primaryColor ?? Color.lightBlueMain300
    }
    
    private var titleColor: Color {
        return selectedProvider?.primaryColor ?? .blue
    }
    
    private var iconColor: Color {
        return selectedProvider?.primaryColor ?? .blue
    }
    
    private var iconBackgroundColor: Color {
        return (selectedProvider?.primaryColor ?? .blue).opacity(0.1)
    }
    
    private var selectedProviderName: String {
        return selectedProvider?.providerName ?? "Select Provider"
    }
    
    private var isProviderSelected: Bool {
        return selectedProvider != nil
    }
    
    private var enabledProviders: [VoxNodeProvider] {
        return providers.filter { $0.isEnabled }
    }
    
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
                            .fill(logoColor)
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
                            .foregroundColor(titleColor)
                        Text(" PHONE")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(titleColor)
                    }
                }
                
                // Input Fields
                VStack(spacing: 16) {
                    // Provider Dropdown
                    ZStack {
                        // Main dropdown button
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .padding(.leading, 16)
                                } else {
                                    Text(selectedProviderName)
                                        .foregroundColor(isProviderSelected ? .primary : .gray)
                                        .padding(.leading, 16)
                                }
                                
                                Spacer()
                                
                                if !isLoading {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isDropdownExpanded.toggle()
                                        }
                                    }) {
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(iconColor)
                                            .rotationEffect(.degrees(isDropdownExpanded ? 180 : 0))
                                            .padding(.trailing, 16)
                                    }
                                }
                            }
                            .frame(height: 50)
                        }
                        .frame(height: 50)
                    }
                    .frame(height: 50)
                    
                    // Email Field
                    HStack {
                        ZStack {
                            Circle()
                                .fill(iconBackgroundColor)
                                .frame(width: 32, height: 32)
                            
                            Text("@")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(iconColor)
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
                                .fill(iconBackgroundColor)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(iconColor)
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
                                .foregroundColor(iconColor)
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
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 24)
                }
                
                // Login Button
                Button(action: {
                    accountViewModel.login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(titleColor)
                        )
                }
                .padding(.horizontal, 24)
                .disabled(!isProviderSelected || isLoading)
                .opacity((!isProviderSelected || isLoading) ? 0.6 : 1.0)
                
                Spacer()
            }
            
            // Dropdown overlay positioned absolutely
            if isDropdownExpanded && !isLoading {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        ForEach(enabledProviders) { provider in
                            Button(action: {
                                selectedProvider = provider
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isDropdownExpanded = false
                                }
                            }) {
                                HStack {
                                    Text(provider.providerName)
                                        .foregroundColor(.primary)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                .frame(height: 40)
                                .background(selectedProvider?.providerId == provider.providerId ? provider.primaryColor.opacity(0.1) : Color.white)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .zIndex(9999)
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
        .onAppear {
            fetchProviders()
        }
    }
    
    // MARK: - API Functions
    
    private func fetchProviders() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://api3.voxnode.com/getProviders") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let providers = try JSONDecoder().decode([VoxNodeProvider].self, from: data)
                    self.providers = providers
                    
                    // Set default provider if available
                    if let defaultProvider = providers.first(where: { $0.isEnabled }) {
                        self.selectedProvider = defaultProvider
                    }
                } catch {
                    errorMessage = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    VoxLoginView(accountViewModel: AccountLoginViewModel())
}

