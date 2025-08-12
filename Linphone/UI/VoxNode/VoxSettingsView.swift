//
//  VoxSettingsView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI

struct VoxSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutAlert = false
    
    // Sample data - in a real app, these would come from a view model
    private let userEmail = "nasriwahid90@gmail.com"
    private let voipProvider = "VoipPhone"
    private let callerId = "+33974670002"
    private let balance = "0.0 €"
    private let language = "Français"
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top green line
                Rectangle()
                    .fill(Color.greenSuccess500)
                    .frame(height: 4)
                
                // Header
                VStack(spacing: 8) {
                    Text("Options")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.grayMain2c800)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // User Profile Banner
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        // User profile icon
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 60, height: 60)
                            
                            // User silhouette icon
                            Image(systemName: "person.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userEmail)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("VoIP Provider: \(voipProvider)")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.lightBlueMain500)
                
                // Information Cards
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Caller ID Card
                        InfoCard(
                            title: "ID de l'appelant",
                            value: callerId,
                            color: .lightBlueMain500
                        )
                        
                        // Language Card
                        InfoCard(
                            title: "Langue",
                            value: language,
                            color: .lightBlueMain500
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Se déconnecter")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.redDanger500)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .alert("Se déconnecter", isPresented: $showingLogoutAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Se déconnecter", role: .destructive) {
                    // Handle logout action
                    dismiss()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir vous déconnecter ?")
            }
        }
        .navigationBarHidden(true)
    }
}

// Info Card Component
struct InfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.grayMain2c800)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        VoxSettingsView()
    }
}
