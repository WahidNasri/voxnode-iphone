//
//  VoxDialerView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let flag: String
    let code: String
    let phoneCode: String
    
    static let algeria = Country(name: "Algeria", flag: "🇩🇿", code: "DZ", phoneCode: "+213")
    static let france = Country(name: "France", flag: "🇫🇷", code: "FR", phoneCode: "+33")
    static let usa = Country(name: "United States", flag: "🇺🇸", code: "US", phoneCode: "+1")
    
    static let allCountries = [algeria, france, usa]
}

struct VoxDialerView: View {
    @State private var selectedCountry: Country = .france
    @State private var dialedNumber: String = ""
    @State private var showingCountryPicker = false
    
    @ObservedObject var startCallViewModel: StartCallViewModel
    @ObservedObject var callViewModel: CallViewModel

    
    private let dialPadButtons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["*", "0", "#"]
    ]
    
    private let dialPadLetters = [
        ["", "ABC", "DEF"],
        ["GHI", "JKL", "MNO"],
        ["PQRS", "TUV", "WXYZ"],
        ["", "", ""]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section - Balance and Country
            VStack(spacing: 16) {
                // Balance
                Text("Solde 0.0 €")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                // Country Selection
                HStack {
                    Button(action: {
                        showingCountryPicker = true
                    }) {
                        HStack(spacing: 8) {
                            Text(selectedCountry.flag)
                                .font(.title2)
                            
                            Text(selectedCountry.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Middle Section - Phone Number Input
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    // Country Code
                    Text(selectedCountry.phoneCode)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Dialed Number
                    Text(dialedNumber)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Backspace Button
                    if !dialedNumber.isEmpty {
                        Button(action: {
                            if !dialedNumber.isEmpty {
                                dialedNumber.removeLast()
                                startCallViewModel.searchField = String(startCallViewModel.searchField.dropLast())
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Dial Pad
            VStack(spacing: 16) {
                ForEach(0..<dialPadButtons.count, id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(0..<dialPadButtons[row].count, id: \.self) { column in
                            let button = dialPadButtons[row][column]
                            let letters = dialPadLetters[row][column]
                            
                            Button(action: {
                                handleDialPadPress(button)
                            }) {
                                VStack(spacing: 4) {
                                    Text(button)
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    if !letters.isEmpty {
                                        Text(letters)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            // Call Button
            Button(action: {
                makeCall()
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
    
    private func handleDialPadPress(_ button: String) {
        switch button {
        case "*", "#":
            dialedNumber += button
            startCallViewModel.searchField += button
        case "0":
            // Handle 0 with + superscript (for international calls)
            dialedNumber += "0"
            startCallViewModel.searchField += "0"
        default:
            dialedNumber += button
            startCallViewModel.searchField += button
        }
    }
    
    private func makeCall() {
        let fullNumber = selectedCountry.phoneCode + dialedNumber.replacingOccurrences(of: " ", with: "")
        print("VOXNODE: Making call to: \(fullNumber)")
        // Implement actual call functionality here
        startCallViewModel.interpretAndStartCall()
        startCallViewModel.searchField = ""
        dialedNumber = ""
    }
}

struct CountryPickerView: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Country.allCountries) { country in
                Button(action: {
                    selectedCountry = country
                    dismiss()
                }) {
                    HStack {
                        Text(country.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(country.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text(country.phoneCode)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if selectedCountry.id == country.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VoxDialerView(startCallViewModel: StartCallViewModel(),
                  callViewModel: CallViewModel())
}

