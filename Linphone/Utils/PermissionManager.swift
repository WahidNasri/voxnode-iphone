/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of Linphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import Photos
import Contacts
import UserNotifications
import SwiftUI
import Network

class PermissionManager: ObservableObject {
	
	static let shared = PermissionManager()
	
	@Published var pushPermissionGranted = false
	@Published var photoLibraryPermissionGranted = false
	@Published var cameraPermissionGranted = false
	@Published var contactsPermissionGranted = false
	@Published var microphonePermissionGranted = false
	@Published var allPermissionsHaveBeenDisplayed = false
    
    @Published var notificationsStatus = ""
    @Published var contactsStatus = ""
    @Published var micStatus = ""
    @Published var videoCameraStatus = ""
	
	private init() {
        setMicrophoneStatus()
        setNotificationsStatus()
        setContactsStatus()
        setVideoCameraStatus()
    }
    
    func setVideoCameraStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            videoCameraStatus = "Undetermined (tap to allow)"
        case .restricted:
            videoCameraStatus = "Restricted"
        case .denied:
            videoCameraStatus = "Denied"
        case .authorized:
            cameraPermissionGranted = true
            videoCameraStatus = "Authorized"
        @unknown default:
            videoCameraStatus = "Unknown"
        }
    }
    
    func setMicrophoneStatus() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            microphonePermissionGranted = true
            micStatus = "Authorized"
        case .denied:
            micStatus = "Denied"
        case .undetermined:
            micStatus = "Undetermined (tap to allow)"
        @unknown default:
            micStatus = "Unknown"
        }
    }
    
    func setNotificationsStatus() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.notificationsStatus = "Undetermined (tap to allow)"
            case .denied:
                self.notificationsStatus = "Denied"
            case .authorized:
                self.pushPermissionGranted = true
                self.notificationsStatus = "Authorized"
            case .provisional:
                self.notificationsStatus = "Provisional"
            case .ephemeral:
                self.notificationsStatus = "Ephemeral"
            @unknown default:
                self.notificationsStatus = "Unknown"
            }
        }
    }
    
    func setContactsStatus() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            contactsStatus = "Undetermined (tap to allow)"
        case .restricted:
            contactsStatus = "Restricted"
        case .denied:
            contactsStatus = "Denied"
        case .authorized:
            contactsPermissionGranted = true
            contactsStatus = "Authorized"
        case .limited:
            contactsPermissionGranted = true
            contactsStatus = "Limited"
        @unknown default:
            contactsStatus = "Unknown"
        }
    }
	
	func getPermissions() {
		pushNotificationRequestPermission {
			let dispatchGroup = DispatchGroup()
			
			dispatchGroup.enter()
			self.microphoneRequestPermission()
			self.photoLibraryRequestPermission()
			self.cameraRequestPermission()
			self.contactsRequestPermission(group: dispatchGroup)
			
			dispatchGroup.notify(queue: .main) {
				// Now request local network authorization last
				self.requestLocalNetworkAuthorization()
			}
		}
	}
	
	func pushNotificationRequestPermission(completion: @escaping () -> Void) {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
			if let error = error {
				Log.error("Unexpected error when asking for Push permission : \(error.localizedDescription)")
			}
			DispatchQueue.main.async {
				self.pushPermissionGranted = granted
                self.setNotificationsStatus()
			}
			completion()
		}
	}
	
    func microphoneRequestPermission(completion: ((Bool)->Void)? = nil) {
		AVAudioSession.sharedInstance().requestRecordPermission({ granted in
			DispatchQueue.main.async {
				self.microphonePermissionGranted = granted
                self.setMicrophoneStatus()
                completion?(granted)
			}
		})
	}
	
	func photoLibraryRequestPermission() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: {status in
			DispatchQueue.main.async {
				self.photoLibraryPermissionGranted = (status == .authorized || status == .limited || status == .restricted)
			}
		})
	}
	
	func cameraRequestPermission(completion: ((Bool)->Void)? = nil) {
		AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
			DispatchQueue.main.async {
				self.cameraPermissionGranted = accessGranted
                self.setVideoCameraStatus()
                completion?(accessGranted)
			}
		})
	}
	
	func contactsRequestPermission(group: DispatchGroup?) {
		let store = CNContactStore()
		store.requestAccess(for: .contacts) { success, _ in
			DispatchQueue.main.async {
				self.contactsPermissionGranted = success
                self.setContactsStatus()
			}
			group?.leave()
		}
	}
	
	func requestLocalNetworkAuthorization() {
		// Use a general UDP broadcast endpoint to attempt triggering the authorization request
		let host = NWEndpoint.Host("255.255.255.255") // Broadcast on the local network
        guard let port = NWEndpoint.Port(rawValue: 12345) else { return } // Choose an arbitrary port
		
		let params = NWParameters.udp
		let connection = NWConnection(host: host, port: port, using: params)
		
		connection.stateUpdateHandler = { newState in
			switch newState {
			case .ready:
				print("Connection ready")
				connection.cancel() // Close the connection after establishing it
			case .failed(let error):
				print("Connection failed: \(error)")
				connection.cancel()
			default:
				break
			}
		}
		connection.start(queue: .main)
		DispatchQueue.main.async {
			self.allPermissionsHaveBeenDisplayed = true
		}
	}
}
