//
//  CallViewable.swift
//  LinphoneApp
//
//  Created by Mehrooz Khan on 13/08/2025.
//

import SwiftUI
import CallKit
import AVFAudio
import linphonesw
import UniformTypeIdentifiers

struct CallViewable: View {
    
    @State private var fullscreenVideo = false
    @State private var isPausedByRemote = false
    @State private var isPaused = false
    @State private var displayName = "+16505551234"
    @State private var outgoingCallStarted = true
    @State private var callInProgress = true
    @State private var callStarted = true
    @State private var timeElapsed = 120
    @State private var videoDisplayed = false
    @State private var isMediaEncrypted = false
    @State private var isRemoteDeviceTrusted = false
    @State private var isZrtp = false
    @State private var cacheMismatch = false
    @State private var isNotEncrypted = false
    @State private var currentOffset: CGFloat = 0.0
    @State private var minBottomSheetHeight: CGFloat = 0.16
    @State private var maxBottomSheetHeight: CGFloat = 0.35
    @State private var pointingUp: CGFloat = 0.0
    @State private var optionsChangeLayout: Int = 2
    @State private var isOneOneCall = true
    @State private var remoteConfVideo = false
    @State private var avatarModel: ContactAvatarModel?
    @State private var remoteAddressString = "test remote address"
    @State private var isConference = false
    @State private var activeSpeakerParticipant = false
    @State private var participantList = 2
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @State private var orientation = UIDevice.current.orientation
    @State var angleDegree = 0.0
    @State private var activeSpeakerParticipantonPause = false
    @State var buttonSize = 60.0
    @State private var micMutted = false
    @State private var callsCounter = 6
    @State private var operationInProgress = false
    
    @State private var isRecording = false
    
    var body: some View {
        GeometryReader { geo in
            innerView(geometry: geo)
                .onAppear {
                    avatarModel = ContactAvatarModel(friend: nil, name: "+1123456", address: "adf", withPresence: false)
                }
        }
    }
    
    @ViewBuilder
    func innerView(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack {
                if !fullscreenVideo || (fullscreenVideo && isPausedByRemote) {
                    ZStack {
                        HStack {
                            Button {
                                
                            } label: {
                                Image("caret-left")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(.white)
                                    .frame(width: 25, height: 25, alignment: .leading)
                                    .padding(.all, 10)
                            }
                            
                            Text(displayName)
                                .default_text_style_white_800(styleSize: 16)
                            
                            if !outgoingCallStarted && callInProgress {
                                Text("|")
                                    .default_text_style_white_800(styleSize: 16)
                                
                                ZStack {
                                    Text(timeElapsed.convertDurationToString())
                                        .default_text_style_white_800(styleSize: 16)
                                        .if(isPaused || isPausedByRemote) { view in
                                            view.hidden()
                                        }
                                    
                                    if isPaused {
                                        Text("call_state_paused")
                                            .default_text_style_white_800(styleSize: 16)
                                    } else if isPausedByRemote {
                                        Text("call_state_paused_by_remote")
                                            .default_text_style_white_800(styleSize: 16)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image("cell-signal-full")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .padding(.all, 10)
                            }
                            
                            if videoDisplayed {
                                Button {
                                } label: {
                                    Image("camera-rotate")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 30, height: 30)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .frame(height: 40)
                        .zIndex(1)
                        
                        if !outgoingCallStarted && callInProgress {
                            if isMediaEncrypted && isRemoteDeviceTrusted && isZrtp {
                                HStack {
                                    Image("lock-key")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(Color.blueInfo500)
                                        .frame(width: 15, height: 15, alignment: .leading)
                                        .padding(.leading, 50)
                                        .padding(.top, 35)
                                    
                                    Text("call_zrtp_end_to_end_encrypted")
                                        .foregroundStyle(Color.blueInfo500)
                                        .default_text_style_white(styleSize: 12)
                                        .padding(.top, 35)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                    
                                }
                                .frame(height: 40)
                                .zIndex(1)
                            } else if isMediaEncrypted && !isZrtp {
                                HStack {
                                    Image("lock_simple")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(Color.blueInfo500)
                                        .frame(width: 15, height: 15, alignment: .leading)
                                        .padding(.leading, 50)
                                        .padding(.top, 35)
                                    
                                    Text("call_srtp_point_to_point_encrypted")
                                        .foregroundStyle(Color.blueInfo500)
                                        .default_text_style_white(styleSize: 12)
                                        .padding(.top, 35)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                    
                                }
                                .frame(height: 40)
                                .zIndex(1)
                            } else if isMediaEncrypted && (!isRemoteDeviceTrusted && isZrtp) || cacheMismatch {
                                HStack {
                                    Image("warning-circle")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(Color.orangeWarning600)
                                        .frame(width: 15, height: 15, alignment: .leading)
                                        .padding(.leading, 50)
                                        .padding(.top, 35)
                                    
                                    Text("call_zrtp_sas_validation_required")
                                        .foregroundStyle(Color.orangeWarning600)
                                        .default_text_style_white(styleSize: 12)
                                        .padding(.top, 35)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                    
                                }
                                .frame(height: 40)
                                .zIndex(1)
                            } else if isNotEncrypted {
                                HStack {
                                    Image("lock_simple")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 15, height: 15, alignment: .leading)
                                        .padding(.leading, 50)
                                        .padding(.top, 35)
                                    
                                    Text("call_not_encrypted")
                                        .foregroundStyle(.white)
                                        .default_text_style_white(styleSize: 12)
                                        .padding(.top, 35)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                   
                                }
                                .frame(height: 40)
                                .zIndex(1)
                            } else {
                                HStack {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 15, height: 15, alignment: .leading)
                                        .padding(.leading, 50)
                                        .padding(.top, 35)
                                    
                                    Text("call_waiting_for_encryption_info")
                                        .foregroundStyle(.white)
                                        .default_text_style_white(styleSize: 12)
                                        .padding(.top, 35)
                                    
                                    Spacer()
                                }
                                .frame(height: 40)
                                .zIndex(1)
                            }
                        }
                    }
                }
                
                simpleCallView(geometry: geometry)
                
                Spacer()
            }
            .frame(height: geometry.size.height)
            .frame(maxWidth: .infinity)
            .background(Color.gray900)
                        
            if !fullscreenVideo || (fullscreenVideo && isPausedByRemote) {
                if callStarted {
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let bottomInset = scene?.windows.first?.safeAreaInsets
                    
                    BottomSheetView(
                        content: bottomSheetContent(geo: geometry),
                        minHeight: (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78),
                        maxHeight: (maxBottomSheetHeight * geometry.size.height),
                        currentOffset: $currentOffset,
                        pointingUp: $pointingUp,
                        bottomSafeArea: bottomInset?.bottom ?? 0
                    )
                    .onAppear {
                        currentOffset = (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78)
                        pointingUp = -(((currentOffset - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78)) / ((maxBottomSheetHeight * geometry.size.height) - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78))) - 0.5) * 2
                    }
                    .onChange(of: optionsChangeLayout) { _ in
                        currentOffset = (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78)
                        pointingUp = -(((currentOffset - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78)) / ((maxBottomSheetHeight * geometry.size.height) - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78))) - 0.5) * 2
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
    }
    
    func simpleCallView(geometry: GeometryProxy) -> some View {
        ZStack {
            if isOneOneCall {
                VStack {
                    Spacer()
                    ZStack {
                        
                        if isRemoteDeviceTrusted {
                            Circle()
                                .fill(Color.blueInfo500)
                                .frame(width: 206, height: 206)
                        }
                        
                        if avatarModel != nil {
                            Avatar(contactAvatarModel: avatarModel!, avatarSize: 200, hidePresence: true, showOnlyPhoto: true)
                        }
                        
                        if isRemoteDeviceTrusted {
                            VStack {
                                Spacer()
                                HStack {
                                    Image("trusted")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .padding(.all, 15)
                                    Spacer()
                                }
                            }
                            .frame(width: 200, height: 200)
                        }
                    }
                    
                    Text(displayName)
                        .padding(.top)
                        .default_text_style_white(styleSize: 22)
                    
                    Text(remoteAddressString)
                        .default_text_style_white_300(styleSize: 16)
                    
                    Spacer()
                }
                
                
                if outgoingCallStarted {
                    VStack {
                        ActivityIndicator(color: .white)
                            .frame(width: 20, height: 20)
                            .padding(.top, 60)
                        
                        Text("counterToMinutes")
                            .padding(.top)
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .background(.clear)
                    .frame(
                        maxWidth: fullscreenVideo && !isPausedByRemote ? geometry.size.width : geometry.size.width - 8,
                        maxHeight: fullscreenVideo && !isPausedByRemote ? geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom : geometry.size.height - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78) - 40 - 20 + geometry.safeAreaInsets.bottom
                    )
                }
                
            } else if outgoingCallStarted {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 60, height: 60, alignment: .center)
            }
            
            if isRecording {
                HStack {
                    VStack {
                        Image("record-fill")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.redDanger500)
                            .frame(width: 32, height: 32)
                            .padding(10)
                            .if(fullscreenVideo && !isPausedByRemote) { view in
                                view.padding(.top, 30)
                            }
                        Spacer()
                    }
                    Spacer()
                }
                .frame(
                    maxWidth: fullscreenVideo && !isPausedByRemote ? geometry.size.width : geometry.size.width - 8,
                    maxHeight: fullscreenVideo && !isPausedByRemote ? geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom : geometry.size.height - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78) - 40 - 20 + geometry.safeAreaInsets.bottom
                )
            }
        }
        .frame(
            maxWidth: fullscreenVideo && !isPausedByRemote ? geometry.size.width : geometry.size.width - 8,
            maxHeight: fullscreenVideo && !isPausedByRemote ? geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom : geometry.size.height - (minBottomSheetHeight * geometry.size.height > 80 ? minBottomSheetHeight * geometry.size.height : 78) - 40 - 20 + geometry.safeAreaInsets.bottom
        )
        .background(Color.gray900)
        .cornerRadius(20)
        .padding(.top, isOneOneCall && fullscreenVideo && !isPausedByRemote ? geometry.safeAreaInsets.bottom + 10 : 0)
        .padding(.horizontal, fullscreenVideo && !isPausedByRemote ? 0 : 4)
        .onRotate { newOrientation in
//            let oldOrientation = orientation
//            orientation = newOrientation
//            if orientation == .portrait || orientation == .portraitUpsideDown {
//                angleDegree = 0
//            } else {
//                if orientation == .landscapeLeft {
//                    angleDegree = -90
//                } else if orientation == .landscapeRight {
//                    angleDegree = 90
//                } else if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
//                    angleDegree = 90
//                }
//            }
//            
//            if (oldOrientation != orientation && oldOrientation != .faceUp) || (oldOrientation == .faceUp && (orientation == .landscapeLeft || orientation == .landscapeRight)) {
//                callStarted = false
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    callStarted = true
//                }
//            }
            
        }
        .onAppear {
            if orientation == .portrait && orientation == .portraitUpsideDown {
                angleDegree = 0
            } else {
                if orientation == .landscapeLeft {
                    angleDegree = -90
                } else if orientation == .landscapeRight {
                    angleDegree = 90
                } else if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                    angleDegree = 90
                }
            }
            
        }
    }
    
    func bottomSheetContent(geo: GeometryProxy) -> some View {
        
        VStack(spacing: 0) {
            Button {
                withAnimation {
                    if currentOffset < (maxBottomSheetHeight * geo.size.height) {
                        currentOffset = (maxBottomSheetHeight * geo.size.height)
                    } else {
                        currentOffset = (minBottomSheetHeight * geo.size.height > 80 ? minBottomSheetHeight * geo.size.height : 78)
                    }
                    
                    pointingUp = -(((currentOffset - (minBottomSheetHeight * geo.size.height > 80 ? minBottomSheetHeight * geo.size.height : 78)) / ((maxBottomSheetHeight * geo.size.height) - (minBottomSheetHeight * geo.size.height > 80 ? minBottomSheetHeight * geo.size.height : 78))) - 0.5) * 2
                }
            } label: {
                ChevronShape(pointingUp: pointingUp)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 6)
                    .foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .padding(.top, 15)
            }
            
            
            HStack(spacing: 0) {
                
                Button {
                    micMutted.toggle()
                } label: {
                    Image(micMutted ? "microphone-slash" : "microphone")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(micMutted ? Color.redDanger500 : Color.gray500)
                }
                .clipShape(.circle)
                .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
                
                Button {
                    
                } label: {
                    Image("phone-disconnect")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.redDanger500)
                }
                .clipShape(.circle)
                .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
                
                Button {
                    
                } label: {
                    Image("speaker-high")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.gray500)
                }
                .clipShape(.circle)
                .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
            }
            .frame(height: geo.size.height * 0.15)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, -5)
            
            if orientation != .landscapeLeft && orientation != .landscapeRight {
                
                HStack(spacing: 0) {
                    
                    VStack {
                        Button {
                            
                        } label: {
                            Image("dialer")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color.gray500)
                        }
                        .clipShape(.circle)
                        
                        Text("call_action_show_dialer")
                            .foregroundStyle(.white)
                            .default_text_style(styleSize: 15)
                    }
                    .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
                    
                    VStack {
                        Button {
                            isPaused.toggle()
                        } label: {
                            Image(isPaused ? "play" : "pause")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(isPausedByRemote ? Color.gray500 : .white)
                                .frame(width: 32, height: 32)
                                .frame(width: buttonSize, height: buttonSize)
                                .background(isPausedByRemote ? .white : (isPaused ? Color.greenSuccess500 : Color.gray500))
                        }
                        .clipShape(.circle)
                        .disabled(isPausedByRemote)
                        
                        Text("call_action_pause_call")
                            .foregroundStyle(.white)
                            .default_text_style(styleSize: 15)
                    }
                    .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
                    
                    VStack {
                        Button {
                            isRecording.toggle()
                        } label: {
                            Image("record-fill")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle((isPaused || isPausedByRemote) ? Color.gray500 : .white)
                                .frame(width: 32, height: 32)
                                .frame(width: buttonSize, height: buttonSize)
                                .background((isPaused || isPausedByRemote) ? .white : (isRecording ? Color.redDanger500 : Color.gray500))
                            
                        }
                        .clipShape(.circle)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .opacity(isRecording ? 0.8 : 1.0)
                        .animation(
                            isRecording ?
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true) :
                                Animation.easeInOut(duration: 0.8),
                            value: isRecording
                        )
                        .disabled(isPaused || isPausedByRemote)
                        
                        Text("call_action_record_call")
                            .foregroundStyle(.white)
                            .default_text_style(styleSize: 15)
                    }
                    .frame(width: geo.size.width * 0.24, height: geo.size.width * 0.24)
                    
                }
                .frame(height: geo.size.height * 0.15)
                
            } else {
                HStack {
                    
                    
                    if isOneOneCall {
                        VStack {
                            Button {
                                
                            } label: {
                                HStack {
                                    Image("dialer")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(PressedButtonStyle(buttonSize: buttonSize))
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.gray500)
                            .cornerRadius(40)
                            
                            Text("call_action_show_dialer")
                                .foregroundStyle(.white)
                                .default_text_style(styleSize: 15)
                        }
                        .frame(width: geo.size.width * 0.125, height: geo.size.width * 0.125)
                    } else {
                        VStack {
                            Button {
                                
                            } label: {
                                HStack {
                                    Image("notebook")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(PressedButtonStyle(buttonSize: buttonSize))
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.gray500)
                            .cornerRadius(40)
                            
                            Text("call_action_change_layout")
                                .foregroundStyle(.white)
                                .default_text_style(styleSize: 15)
                        }
                        .frame(width: geo.size.width * 0.125, height: geo.size.width * 0.125)
                    }
                    
                    
                    VStack {
                        Button {
                            isPaused.toggle()
                        } label: {
                            HStack {
                                Image(isPaused ? "play" : "pause")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(isPausedByRemote ? Color.gray500 : .white)
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .buttonStyle(PressedButtonStyle(buttonSize: buttonSize))
                        .frame(width: buttonSize, height: buttonSize)
                        .background(isPausedByRemote ? .white : (isPaused ? Color.greenSuccess500 : Color.gray500))
                        .cornerRadius(40)
                        .disabled(isPausedByRemote)
                        
                        Text("call_action_pause_call")
                            .foregroundStyle(.white)
                            .default_text_style(styleSize: 15)
                    }
                    .frame(width: geo.size.width * 0.125, height: geo.size.width * 0.125)
                    
                    if isOneOneCall {
                        VStack {
                            Button {
                                
                            } label: {
                                HStack {
                                    Image("record-fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle((isPaused || isPausedByRemote) ? Color.gray500 : .white)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(PressedButtonStyle(buttonSize: buttonSize))
                            .frame(width: buttonSize, height: buttonSize)
                            .background((isPaused || isPausedByRemote) ? .white : (isRecording ? Color.redDanger500 : Color.gray500))
                            .cornerRadius(40)
                            .disabled(isPaused || isPausedByRemote)
                            
                            Text("call_action_record_call")
                                .foregroundStyle(.white)
                                .default_text_style(styleSize: 15)
                        }
                        .frame(width: geo.size.width * 0.125, height: geo.size.width * 0.125)
                    } else {
                        VStack {
                            Button {
                            } label: {
                                HStack {
                                    Image("record-fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(Color.gray500)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(PressedButtonStyle(buttonSize: buttonSize))
                            .frame(width: buttonSize, height: buttonSize)
                            .background(.white)
                            .cornerRadius(40)
                            .disabled(true)
                            
                            Text("call_action_record_call")
                                .foregroundStyle(.white)
                                .default_text_style(styleSize: 15)
                        }
                        .frame(width: geo.size.width * 0.125, height: geo.size.width * 0.125)
                    }
                }
                .frame(height: geo.size.height * 0.15)
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            
            Spacer()
        }
        .background(Color.gray600)
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
}

#Preview {
//    GeometryReader { geo in
//        Button {
//           
//        } label: {
//            Image("phone-disconnect")
//                .renderingMode(.template)
//                .resizable()
//                .foregroundStyle(.white)
//                .frame(width: 32, height: 32)
//                .frame(width: 60, height: 60)
//                .background(Color.redDanger500)
//                //.contentShape(Circle())
//        }
//        .clipShape(.circle)
//        .frame(width: 100, height: 100)
//    }
    
    CallViewable()
}
