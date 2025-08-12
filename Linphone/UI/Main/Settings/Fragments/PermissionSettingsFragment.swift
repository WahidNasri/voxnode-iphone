//
//  PermissionsFragment.swift
//  LinphoneApp
//
//  Created by Mehrooz Khan on 10/08/2025.
//

import SwiftUI

struct PermissionSettingsFragment: View {
    
    @Environment(\.dismiss) var dismiss
    
    var permissionManager = PermissionManager.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 1) {
                
                Rectangle()
                    .foregroundColor(Color.lightBlueMain500)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 0)
                
                HStack {
                    Image("caret-left")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(Color.lightBlueMain500)
                        .frame(width: 25, height: 25, alignment: .leading)
                        .padding(.all, 10)
                        .padding(.top, 4)
                        .padding(.leading, -10)
                        .onTapGesture {
                            dismiss()
                        }
                    
                    Text("settings_title")
                        .default_text_style_orange_800(styleSize: 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal)
                .padding(.bottom, 4)
                .background(.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PermissionsSettingsRow(image: "bell-ringing", title: "assistant_permissions_post_notifications_title", permissionState: permissionManager.notificationsStatus) {
                            if permissionManager.notificationsStatus == "Undetermined (tap to allow)" {
                                permissionManager.pushNotificationRequestPermission {}
                            } else if permissionManager.notificationsStatus != "Authorized" {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        
                        PermissionsSettingsRow(image: "address-book", title: .init(String(format: String(localized: "assistant_permissions_read_contacts_title"), Bundle.main.displayName)), permissionState: permissionManager.contactsStatus) {
                            if permissionManager.contactsStatus == "Undetermined (tap to allow)" {
                                permissionManager.contactsRequestPermission(group: nil)
                            } else if permissionManager.contactsStatus != "Authorized" {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        
                        PermissionsSettingsRow(image: "microphone", title: "assistant_permissions_record_audio_title", permissionState: permissionManager.micStatus) {
                            if permissionManager.micStatus == "Undetermined (tap to allow)" {
                                permissionManager.microphoneRequestPermission()
                            } else if permissionManager.micStatus != "Authorized" {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        
                        PermissionsSettingsRow(image: "video-camera", title: "assistant_permissions_access_camera_title", permissionState: permissionManager.videoCameraStatus) {
                            if permissionManager.videoCameraStatus == "Undetermined (tap to allow)" {
                                permissionManager.cameraRequestPermission()
                            } else if permissionManager.videoCameraStatus != "Authorized" {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.gray100)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct PermissionsSettingsRow: View {
    
    let image: String
    let title: LocalizedStringKey
    let permissionState: String
    var buttonAction: () -> Void
    
    var color: Color {
        if permissionState == "Denied" {
            return Color.redDanger700
        } else if permissionState == "Authorized" {
            return Color.greenSuccess500
        } else {
            return Color.blueInfo500
        }
    }
    
    var isBold: Bool {
        (permissionState == "Denied" || permissionState == "Authorized")
    }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack(alignment: .center) {
                Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(Color.grayMain2c500)
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(16)
                    .background(Color.grayMain2c200)
                    .clipShape(.circle)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .default_text_style(styleSize: 15)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("**Status:**")
                            .default_text_style(styleSize: 15)
                        
                        Text(permissionState)
                            .foregroundStyle(color)
                            .font(.custom("NotoSans-\(isBold ? "Bold" : "Regular")", size: 15))
                            
                    }
                    
                }
                .padding(.leading, 10)
            }
        }

    }
}

#Preview {
    PermissionSettingsFragment()
}
