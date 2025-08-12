//
//  VoxDialerView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI
import PhoneNumberKit

struct VoxDialerView: View {
    
    @State private var dialedNumber: String = ""
    @State private var phoneField: PhoneNumberTextFieldView?
    
    @ObservedObject var startCallViewModel: StartCallViewModel
    @ObservedObject var callViewModel: CallViewModel

    var permissionManager = PermissionManager.shared
    @State var showMicAlert = false
    
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
        ["", "+", ""]
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Top Section - Balance and Country
                    
                        // Balance
                    Text("Solde 0.0 €")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(20)
                    
                    
                    // Middle Section - Phone Number Input
                    HStack {
                        self.phoneField
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
                            .keyboardType(.phonePad)
                            .allowsHitTesting(false)
                        
                        
                        if !dialedNumber.isEmpty {
                            Button(action: {
                                if !dialedNumber.isEmpty {
                                    phoneField?.textField.text?.removeLast()
                                    //startCallViewModel.searchField = String(startCallViewModel.searchField.dropLast())
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
                    .padding(20)
                    
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
                                    .supportsLongPress(normalColor: Color.gray.opacity(0.1), pressedColor: Color.gray) {
                                        handleDialPadLongPress(button)
                                    }
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
            }
            .onAppear {
                self.phoneField = PhoneNumberTextFieldView(phoneNumber: self.$dialedNumber)
            }
            .alert("Microphone is needed to make calls, please allow microphone permissions from settings", isPresented: $showMicAlert) {
                Button("Cancel") { }
                Button("Settings", role: .cancel) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func handleDialPadLongPress(_ button: String) {
        if button == "0" {
            phoneField?.textField.text = "+"
        }
    }
    
    private func handleDialPadPress(_ button: String) {
        if let text = phoneField?.textField.text {
            phoneField?.textField.text = text + button
        } else {
            phoneField?.textField.text = button
        }
    }
    
    private func makeCall() {
        guard CoreContext.shared.networkStatusIsConnected else {
                ToastViewModel.shared.toastMessage = "Unavailable_network"
                ToastViewModel.shared.displayToast = true
                return
        }
        
        permissionManager.microphoneRequestPermission { granted in
            guard granted else {
                showMicAlert = true
                return
            }
            
            guard let phoneNumber = phoneField?.textField.phoneNumber else { return }
            let fullNumber = "+" + "\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)"
            print("VOXNODE: Making call to: \(fullNumber)")
            // Implement actual call functionality here
            startCallViewModel.searchField = fullNumber
            startCallViewModel.interpretAndStartCall()
            phoneField?.textField.text = ""
        }
        
        
    }
}

#Preview {
    VoxDialerView(startCallViewModel: StartCallViewModel(),
                  callViewModel: CallViewModel())
    .environment(\.locale, .init(identifier: "en_US"))
}

struct PhoneNumberTextFieldView: UIViewRepresentable {
    @Binding var phoneNumber: String
    let textField = PhoneNumberTextField()
    
    func makeUIView(context: Context) -> PhoneNumberTextField {
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.textFieldTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        
        //textField.addTarget(context.coordinator, action: #selector(Coordinator.onTextChange), for: .editingChanged)
        textField.withExamplePlaceholder = true
        textField.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textField.withFlag = true
        textField.withPrefix = true
        textField.isEnabled = false
        textField.withPrefixPrefill = false
        return textField
    }
    
    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = PhoneNumberTextField
    
    class Coordinator:  NSObject, UITextFieldDelegate {
        var delegate: PhoneNumberTextFieldView
        
        init(_ delegate: PhoneNumberTextFieldView) {
            self.delegate = delegate
        }
        
        @objc func onTextChange(textField: UITextField) {
            self.delegate.phoneNumber = textField.text!
        }
        
        @objc func textFieldTextDidChange(_ notification: Notification) {
            if let textField = notification.object as? UITextField {
                self.delegate.phoneNumber = textField.text!
            }
        }
    }
}

