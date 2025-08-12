/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
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

// swiftlint:disable type_body_length
// swiftlint:disable line_length
import SwiftUI
import linphonesw

struct VoxContentView: View {
	
	@Environment(\.scenePhase) var scenePhase
	private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
	
	@EnvironmentObject var navigationManager: NavigationManager
	
	@ObservedObject private var coreContext = CoreContext.shared
	@ObservedObject private var sharedMainViewModel = SharedMainViewModel.shared
	@ObservedObject private var telecomManager = TelecomManager.shared
	
	@ObservedObject var contactsManager = ContactsManager.shared
	var magicSearch = MagicSearchSingleton.shared
	
	@ObservedObject var contactViewModel: ContactViewModel
	@ObservedObject var editContactViewModel: EditContactViewModel
	@ObservedObject var historyViewModel: HistoryViewModel
	@ObservedObject var historyListViewModel: HistoryListViewModel
	@ObservedObject var startCallViewModel: StartCallViewModel
	@ObservedObject var startConversationViewModel: StartConversationViewModel
	@ObservedObject var callViewModel: CallViewModel
	@ObservedObject var meetingWaitingRoomViewModel: MeetingWaitingRoomViewModel
	@ObservedObject var conversationsListViewModel: ConversationsListViewModel
	@ObservedObject var conversationViewModel: ConversationViewModel
	@ObservedObject var meetingsListViewModel: MeetingsListViewModel
	@ObservedObject var meetingViewModel: MeetingViewModel
	@ObservedObject var conversationForwardMessageViewModel: ConversationForwardMessageViewModel
	@ObservedObject var accountProfileViewModel: AccountProfileViewModel
	
	@State var index = 0
	@State private var orientation = UIDevice.current.orientation
	@State var sideMenuIsOpen: Bool = false
	
	@State private var searchIsActive = false
	@State private var text = ""
	@FocusState private var focusedField: Bool
	@State private var showingDialer = false
	@State var isMenuOpen = false
	@State var isShowDeleteContactPopup = false
	@State var isShowDeleteAllHistoryPopup = false
	@State var isShowEditContactFragment = false
	@State var isShowStartCallFragment = false
	@State var isShowStartConversationFragment = false
	@State var isShowDismissPopup = false
	@State var isShowSendCancelMeetingNotificationPopup = false
	@State var isShowStartCallGroupPopup = false
	@State var isShowSipAddressesPopup = false
	@State var isShowSipAddressesPopupType = 0 // 0 to call, 1  to message, 2 to video call
	@State var isShowConversationFragment = false
	@State var isShowAccountProfileFragment = false
	@State var isShowSettingsFragment = false
	@State var isShowHelpFragment = false
	
	@State var fullscreenVideo = false
	
	@State var isShowScheduleMeetingFragment = false
	@State private var isShowLoginFragment: Bool = false
	
	private let avatarSize = 45.0
	@State private var imagePath: URL?
	
	var body: some View {
		let pub = NotificationCenter.default
			.publisher(for: NSNotification.Name("ContactLoaded"))
		let pub2 = NotificationCenter.default
				.publisher(for: NSNotification.Name("ContactAdded"))
				.compactMap { $0.userInfo?["address"] as? String }
		let imageChanged = NotificationCenter.default
			.publisher(for: NSNotification.Name("ImageChanged"))
		GeometryReader { geometry in
			VStack(spacing: 0) {
				if (telecomManager.callInProgress && !fullscreenVideo && ((!telecomManager.callDisplayed && callViewModel.callsCounter == 1) || callViewModel.callsCounter > 1)) || isShowConversationFragment {
					HStack {
						Image("phone")
							.renderingMode(.template)
							.resizable()
							.foregroundStyle(.white)
							.frame(width: 26, height: 26)
							.padding(.leading, 10)
						
						if callViewModel.callsCounter > 1 {
							Text(String(format: String(localized: "calls_count_label"), callViewModel.callsCounter.description))
								.default_text_style_white(styleSize: 16)
						} else {
							Text("\(callViewModel.displayName)")
								.default_text_style_white(styleSize: 16)
						}
						
						Spacer()
						
						if callViewModel.callsCounter == 1 {
							Text(callViewModel.isPaused || telecomManager.isPausedByRemote ? String(localized: "call_state_paused") : String(localized: "call_state_connected"))
								.default_text_style_white(styleSize: 16)
								.padding(.trailing, 10)
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 30)
					.background(Color.greenSuccess500)
					.onTapGesture {
						withAnimation {
							telecomManager.callDisplayed = true
						}
					}
				}
				
				ZStack {
					VStack(spacing: 0) {
						HStack(spacing: 0) {
							if orientation == .landscapeLeft
								|| orientation == .landscapeRight
								|| UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
								VStack(spacing: 0) {
									Group {
										Spacer()
										
										Button(action: {
											self.index = 0
											historyViewModel.displayedCall = nil
											conversationViewModel.displayedConversation = nil
											meetingViewModel.displayedMeeting = nil
										}, label: {
											VStack {
												Image("address-book")
													.renderingMode(.template)
													.resizable()
													.foregroundStyle(self.index == 0 ? Color.lightBlueMain500 : Color.grayMain2c600)
													.frame(width: 25, height: 25)
												if self.index == 0 {
													Text("bottom_navigation_contacts_label")
														.default_text_style_700(styleSize: 10)
												} else {
													Text("bottom_navigation_contacts_label")
														.default_text_style(styleSize: 10)
												}
											}
										})
										.padding(.top)
										.frame(height: geometry.size.height/4)
										
										ZStack {
											if historyListViewModel.missedCallsCount > 0 {
												VStack {
													HStack {
														Text(
															historyListViewModel.missedCallsCount < 99
															? String(historyListViewModel.missedCallsCount)
															: "99+"
														)
														.foregroundStyle(.white)
														.default_text_style(styleSize: 10)
														.lineLimit(1)
													}
													.frame(width: 18, height: 18)
													.background(Color.redDanger500)
													.cornerRadius(50)
												}
												.padding(.bottom, 30)
												.padding(.leading, 30)
											}
											
											Button(action: {
												self.index = 1
												contactViewModel.indexDisplayedFriend = nil
												conversationViewModel.displayedConversation = nil
												meetingViewModel.displayedMeeting = nil
												if historyListViewModel.missedCallsCount > 0 {
													historyListViewModel.resetMissedCallsCount()
												}
											}, label: {
												VStack {
													Image("phone")
														.renderingMode(.template)
														.resizable()
														.foregroundStyle(self.index == 1 ? Color.lightBlueMain500 : Color.grayMain2c600)
														.frame(width: 25, height: 25)
													if self.index == 1 {
														Text("bottom_navigation_calls_label")
															.default_text_style_700(styleSize: 10)
													} else {
														Text("bottom_navigation_calls_label")
															.default_text_style(styleSize: 10)
													}
												}
											})
											.padding(.top)
										}
										.frame(height: geometry.size.height/4)
										
										ZStack {
											if conversationsListViewModel.unreadMessages > 0 {
												VStack {
													HStack {
														Text(
															conversationsListViewModel.unreadMessages < 99
															? String(conversationsListViewModel.unreadMessages)
															: "99+"
														)
														.foregroundStyle(.white)
														.default_text_style(styleSize: 10)
														.lineLimit(1)
													}
													.frame(width: 18, height: 18)
													.background(Color.redDanger500)
													.cornerRadius(50)
												}
												.padding(.bottom, 30)
												.padding(.leading, 30)
											}
											
											Button(action: {
												self.index = 2
												historyViewModel.displayedCall = nil
												contactViewModel.indexDisplayedFriend = nil
												meetingViewModel.displayedMeeting = nil
											}, label: {
												VStack {
													Image("chat-teardrop-text")
														.renderingMode(.template)
														.resizable()
														.foregroundStyle(self.index == 2 ? Color.lightBlueMain500 : Color.grayMain2c600)
														.frame(width: 25, height: 25)
													
													if self.index == 2 {
														Text("bottom_navigation_conversations_label")
															.default_text_style_700(styleSize: 10)
													} else {
														Text("bottom_navigation_conversations_label")
															.default_text_style(styleSize: 10)
													}
												}
											})
											.padding(.top)
										}
										.frame(height: geometry.size.height/4)
										
										Button(action: {
											self.index = 3
											contactViewModel.indexDisplayedFriend = nil
											historyViewModel.displayedCall = nil
											conversationViewModel.displayedConversation = nil
										}, label: {
											VStack {
												Image("video-conference")
													.renderingMode(.template)
													.resizable()
													.foregroundStyle(self.index == 3 ? Color.lightBlueMain500 : Color.grayMain2c600)
													.frame(width: 25, height: 25)
												if self.index == 0 {
													Text("bottom_navigation_meetings_label")
														.default_text_style_700(styleSize: 10)
												} else {
													Text("bottom_navigation_meetings_label")
														.default_text_style(styleSize: 10)
												}
											}
										})
										.padding(.top)
										.frame(height: geometry.size.height/4)
										
										Spacer()
									}
								}
								.frame(width: 75, height: geometry.size.height)
								.padding(.leading,
										 orientation == .landscapeRight && geometry.safeAreaInsets.bottom > 0
										 ? -geometry.safeAreaInsets.leading
										 : 0)
							}
							
							VStack(spacing: 0) {
								Rectangle()
									.foregroundColor(Color.lightBlueMain500)
									.edgesIgnoringSafeArea(.top)
									.frame(height: 1)
								
								ZStack {
									VStack {
										Rectangle()
											.foregroundColor(
												(orientation == .landscapeLeft
												 || orientation == .landscapeRight
												 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
												? Color.white
												: Color.lightBlueMain500
											)
											.frame(height: 100)
										
										Spacer()
									}
									
									VStack(spacing: 0) {
										if searchIsActive == false {
											HStack {
												if (accountProfileViewModel.accountModelIndex ?? 0) < CoreContext.shared.accounts.count {
													AsyncImage(url: imagePath) { image in
														switch image {
														case .empty:
															ProgressView()
																.frame(width: avatarSize, height: avatarSize)
														case .success(let image):
															image
																.resizable()
																.aspectRatio(contentMode: .fill)
																.frame(width: avatarSize, height: avatarSize)
																.clipShape(Circle())
														case .failure:
															Image(uiImage: contactsManager.textToImage(
																firstName: CoreContext.shared.accounts[accountProfileViewModel.accountModelIndex ?? 0].avatarModel?.name ?? "",
																lastName: ""))
															.resizable()
															.frame(width: avatarSize, height: avatarSize)
															.clipShape(Circle())
														@unknown default:
															EmptyView()
														}
													}
													.onTapGesture {
														openMenu()
													}
													.onAppear {
														if let accountModelIndex = accountProfileViewModel.accountModelIndex,
														   accountModelIndex < CoreContext.shared.accounts.count {
															let imagePathTmp = CoreContext.shared.accounts[accountModelIndex].getImagePath()
															if !(imagePathTmp.lastPathComponent.isEmpty || imagePathTmp.lastPathComponent == "Error" || imagePathTmp.lastPathComponent == "ImageError.png") {
																imagePath = imagePathTmp
															}
														}
													}
													.onChange(of: CoreContext.shared.accounts[accountProfileViewModel.accountModelIndex ?? 0].usernaneAvatar) { _ in
														if let accountModelIndex = accountProfileViewModel.accountModelIndex,
														   accountModelIndex < CoreContext.shared.accounts.count {
															let imagePathTmp = CoreContext.shared.accounts[accountModelIndex].getImagePath()
															if !(imagePathTmp.lastPathComponent.isEmpty || imagePathTmp.lastPathComponent == "Error" || imagePathTmp.lastPathComponent == "ImageError.png") {
																sharedMainViewModel.changeDefaultAvatar(defaultAvatarURL: imagePathTmp)
																imagePath = imagePathTmp
															}
														}
													}
													.onReceive(imageChanged) { _ in
														if let accountModelIndex = accountProfileViewModel.accountModelIndex,
														   accountModelIndex < CoreContext.shared.accounts.count {
															let imagePathTmp = CoreContext.shared.accounts[accountModelIndex].getImagePath()
															sharedMainViewModel.changeDefaultAvatar(defaultAvatarURL: imagePathTmp)
															imagePath = imagePathTmp
														}
													}
												}
												
												Text(String(localized: 
												index == 0 ? "bottom_navigation_calls_label" : 
												index == 1 ? "bottom_navigation_contacts_label" : 
												index == 2 ? "Dialer" : 
												index == 3 ? "bottom_navigation_meetings_label" : 
												"bottom_navigation_meetings_label"))
													.default_text_style_white_800(styleSize: 20)
													.padding(.leading, 10)
											
												Spacer()
												
											}
											.frame(maxWidth: .infinity)
											.frame(height: 50)
											.padding(.leading)
											.padding(.top, 2.5)
											.padding(.bottom, 2.5)
											.background(Color.lightBlueMain500)
											.roundedCorner(10, corners: [.bottomRight, .bottomLeft])
										} else {
											HStack {
												Button {
													withAnimation {
														self.focusedField = false
														searchIsActive.toggle()
													}
													
													text = ""
													
													if index == 0 {
														magicSearch.currentFilter = ""
														MagicSearchSingleton.shared.searchForContacts(
															sourceFlags: MagicSearch.Source.Friends.rawValue | MagicSearch.Source.LdapServers.rawValue)
													} else if index == 1 {
														historyListViewModel.resetFilterCallLogs()
													} else if index == 2 {
														conversationsListViewModel.resetFilterConversations()
													} else if index == 3 {
														meetingsListViewModel.currentFilter = ""
														meetingsListViewModel.computeMeetingsList()
													}
												} label: {
													Image("caret-left")
														.renderingMode(.template)
														.resizable()
														.foregroundStyle(.white)
														.frame(width: 25, height: 25, alignment: .leading)
														.padding(.all, 10)
														.padding(.leading, -10)
												}
												
												if #available(iOS 16.0, *) {
													TextEditor(text: Binding(
														get: {
															return text
														},
														set: { value in
															var newValue = value
															if value.contains("\n") {
																newValue = value.replacingOccurrences(of: "\n", with: "")
															}
															text = newValue
														}
													))
													.default_text_style_white_700(styleSize: 15)
													.padding(.all, 6)
													.disableAutocorrection(true)
													.autocapitalization(.none)
													.accentColor(.white)
													.scrollContentBackground(.hidden)
													.focused($focusedField)
													.onAppear {
														self.focusedField = true
													}
													.onChange(of: text) { newValue in
														if index == 0 {
															magicSearch.currentFilter = newValue
															MagicSearchSingleton.shared.searchForContacts(
																sourceFlags: MagicSearch.Source.Friends.rawValue | MagicSearch.Source.LdapServers.rawValue)
														} else if index == 1 {
															if text.isEmpty {
																historyListViewModel.resetFilterCallLogs()
															} else {
																historyListViewModel.filterCallLogs(filter: text)
															}
														} else if index == 2 {
															if text.isEmpty {
																conversationsListViewModel.resetFilterConversations()
															} else {
																conversationsListViewModel.filterConversations(filter: text)
															}
														} else if index == 3 {
															meetingsListViewModel.currentFilter = text
															meetingsListViewModel.computeMeetingsList()
														}
													}
												} else {
													TextEditor(text: Binding(
														get: {
															return text
														},
														set: { value in
															var newValue = value
															if value.contains("\n") {
																newValue = value.replacingOccurrences(of: "\n", with: "")
															}
															text = newValue
														}
													))
													.default_text_style_700(styleSize: 15)
													.padding(.all, 6)
													.focused($focusedField)
													.disableAutocorrection(true)
													.autocapitalization(.none)
													.onAppear {
														self.focusedField = true
													}
													.onChange(of: text) { newValue in
														if index == 0 {
															magicSearch.currentFilter = newValue
															MagicSearchSingleton.shared.searchForContacts(
																sourceFlags: MagicSearch.Source.Friends.rawValue | MagicSearch.Source.LdapServers.rawValue)
														} else if index == 1 {
															historyListViewModel.filterCallLogs(filter: text)
														} else if index == 2 {
															conversationsListViewModel.filterConversations(filter: text)
														} else if index == 3 {
															meetingsListViewModel.currentFilter = text
															meetingsListViewModel.computeMeetingsList()
														}
													}
												}
												
												Button {
													text = ""
												} label: {
													Image("x")
														.renderingMode(.template)
														.resizable()
														.foregroundStyle(.white)
														.frame(width: 25, height: 25, alignment: .leading)
														.padding(.all, 10)
												}
												.padding(.leading)
											}
											.frame(maxWidth: .infinity)
											.frame(height: 50)
											.padding(.horizontal)
											.padding(.bottom, 5)
											.background(Color.lightBlueMain500)
											.roundedCorner(10, corners: [.bottomRight, .bottomLeft])
										}
										
										if self.index == 0 {
                                            VoxCallsAndRecordingsView(
                                                historyListViewModel: historyListViewModel,
                                                historyViewModel: historyViewModel,
                                                contactViewModel: contactViewModel,
                                                editContactViewModel: editContactViewModel,
                                                index: $index,
                                                isShowStartCallFragment: $isShowStartCallFragment,
                                                isShowEditContactFragment: $isShowEditContactFragment,
                                                text: $text
                                            )
                                            .roundedCorner(25, corners: [.topRight, .topLeft])
                                            .shadow(
                                                color: (orientation == .landscapeLeft
                                                        || orientation == .landscapeRight
                                                        || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
                                                ? .white.opacity(0.0)
                                                : .black.opacity(0.2),
                                                radius: 25
                                            )
                                            
                                            /*
											
                                             */
										} else if self.index == 1 {
                                            ContactsView(
                                                contactViewModel: contactViewModel,
                                                historyViewModel: historyViewModel,
                                                editContactViewModel: editContactViewModel,
                                                isShowEditContactFragment: $isShowEditContactFragment,
                                                isShowDeletePopup: $isShowDeleteContactPopup,
                                                text: $text
                                            )
                                            .roundedCorner(25, corners: [.topRight, .topLeft])
                                            .shadow(
                                                color: (orientation == .landscapeLeft
                                                        || orientation == .landscapeRight
                                                        || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
                                                ? .white.opacity(0.0)
                                                : .black.opacity(0.2),
                                                radius: 25
                                            )
                                    
										} else if self.index == 2 {
                                            VoxDialerView(
                                                startCallViewModel: StartCallViewModel(),
                                                callViewModel: callViewModel,
                                            )
											
										} else if self.index == 3 {
                                            ConversationsView(
                                                conversationViewModel: conversationViewModel,
                                                conversationsListViewModel: conversationsListViewModel,
                                                text: $text,
                                                isShowStartConversationFragment: $isShowStartConversationFragment
                                            )
                                            .roundedCorner(25, corners: [.topRight, .topLeft])
                                            .shadow(
                                                color: (orientation == .landscapeLeft
                                                        || orientation == .landscapeRight
                                                        || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
                                                ? .white.opacity(0.0)
                                                : .black.opacity(0.2),
                                                radius: 25
                                            )
                                        
										}
                                        else if self.index == 4{
                                            VoxSettingsView()
                                        }
									}
								}
							}
							.frame(maxWidth:
									(orientation == .landscapeLeft
									 || orientation == .landscapeRight
									 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
								   ? geometry.size.width/100*40
								   : .infinity
							)
							.background(
								Color.white
									.shadow(color: Color.gray200, radius: 4, x: 0, y: 0)
									.mask(Rectangle().padding(.horizontal, -8))
							)
							
							if orientation == .landscapeLeft
								|| orientation == .landscapeRight
								|| UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
								Spacer()
							}
						}
						
						if !(orientation == .landscapeLeft
							 || orientation == .landscapeRight
							 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) && !searchIsActive {
							HStack {
								Group {
									Spacer()
                                    ZStack {
                                        if historyListViewModel.missedCallsCount > 0 {
                                            VStack {
                                                HStack {
                                                    Text(
                                                        historyListViewModel.missedCallsCount < 99
                                                        ? String(historyListViewModel.missedCallsCount)
                                                        : "99+"
                                                    )
                                                    .foregroundStyle(.white)
                                                    .default_text_style(styleSize: 10)
                                                    .lineLimit(1)
                                                }
                                                .frame(width: 18, height: 18)
                                                .background(Color.redDanger500)
                                                .cornerRadius(50)
                                            }
                                            .padding(.bottom, 30)
                                            .padding(.leading, 30)
                                        }
                                        
                                        Button(action: {
                                            self.index = 0
                                            contactViewModel.indexDisplayedFriend = nil
                                            conversationViewModel.displayedConversation = nil
                                            meetingViewModel.displayedMeeting = nil
                                            if historyListViewModel.missedCallsCount > 0 {
                                                historyListViewModel.resetMissedCallsCount()
                                            }
                                        }, label: {
                                            VStack {
                                                Image("phone")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .foregroundStyle(self.index == 0 ? Color.lightBlueMain500 : Color.grayMain2c600)
                                                    .frame(width: 25, height: 25)
                                                if self.index == 0 {
                                                    Text("bottom_navigation_calls_label")
                                                        .default_text_style_700(styleSize: 9)
                                                } else {
                                                    Text("bottom_navigation_calls_label")
                                                        .default_text_style(styleSize: 9)
                                                }
                                            }
                                        })
                                        .padding(.top)
                                        .frame(width: 66)
                                    }
                                    
                                    Spacer()
									Button(action: {
										self.index = 1
										historyViewModel.displayedCall = nil
										conversationViewModel.displayedConversation = nil
										meetingViewModel.displayedMeeting = nil
									}, label: {
										VStack {
											Image("address-book")
												.renderingMode(.template)
												.resizable()
												.foregroundStyle(self.index == 1 ? Color.lightBlueMain500 : Color.grayMain2c600)
												.frame(width: 25, height: 25)
											if self.index == 1 {
												Text("bottom_navigation_contacts_label")
													.default_text_style_700(styleSize: 10)
											} else {
												Text("bottom_navigation_contacts_label")
													.default_text_style(styleSize: 10)
											}
										}
									})
									.padding(.top)
									.frame(width: 66)
									
									Spacer()
									
									
									
									ZStack {
										if conversationsListViewModel.unreadMessages > 0 {
											VStack {
												HStack {
													Text(
														conversationsListViewModel.unreadMessages < 99
														? String(conversationsListViewModel.unreadMessages)
														: "99+"
													)
													.foregroundStyle(.white)
													.default_text_style(styleSize: 10)
													.lineLimit(1)
												}
												.frame(width: 18, height: 18)
												.background(Color.redDanger500)
												.cornerRadius(50)
											}
											.padding(.bottom, 30)
											.padding(.leading, 30)
										}
										
										Button(action: {
											self.index = 2
											historyViewModel.displayedCall = nil
											contactViewModel.indexDisplayedFriend = nil
											meetingViewModel.displayedMeeting = nil
										}, label: {
											VStack {
												Image("chat-teardrop-text")
													.renderingMode(.template)
													.resizable()
													.foregroundStyle(self.index == 2 ? Color.lightBlueMain500 : Color.grayMain2c600)
													.frame(width: 25, height: 25)
												
												if self.index == 2 {
													Text("Dialer")
														.default_text_style_700(styleSize: 9)
												} else {
													Text("Dialer")
														.default_text_style(styleSize: 9)
												}
											}
										})
										.padding(.top)
										.frame(width: 66)
									}
                                    Spacer()
                                    Button(action: {
                                        self.index = 3
                                        contactViewModel.indexDisplayedFriend = nil
                                        historyViewModel.displayedCall = nil
                                        conversationViewModel.displayedConversation = nil
                                    }, label: {
                                        VStack {
                                            Image("video-conference")
                                                .renderingMode(.template)
                                                .resizable()
                                                .foregroundStyle(self.index == 3 ? Color.lightBlueMain500 : Color.grayMain2c600)
                                                .frame(width: 25, height: 25)
                                            if self.index == 3 {
                                                Text("bottom_navigation_meetings_label")
                                                    .default_text_style_700(styleSize: 9)
                                            } else {
                                                Text("bottom_navigation_meetings_label")
                                                    .default_text_style(styleSize: 9)
                                            }
                                        }
                                    })
                                    .padding(.top)
                                    .frame(width: 66)
									Spacer()
                                    
									Button(action: {
										self.index = 4
										contactViewModel.indexDisplayedFriend = nil
										historyViewModel.displayedCall = nil
										conversationViewModel.displayedConversation = nil
									}, label: {
										VStack {
											Image("video-conference")
												.renderingMode(.template)
												.resizable()
												.foregroundStyle(self.index == 3 ? Color.lightBlueMain500 : Color.grayMain2c600)
												.frame(width: 25, height: 25)
											if self.index == 4 {
												Text("bottom_navigation_meetings_label")
													.default_text_style_700(styleSize: 9)
											} else {
												Text("bottom_navigation_meetings_label")
													.default_text_style(styleSize: 9)
											}
										}
									})
									.padding(.top)
									.frame(width: 66)
									
									Spacer()
								}
							}
							.padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 15)
							.background(
								Color.white
									.shadow(color: Color.gray200, radius: 4, x: 0, y: 0)
									.mask(Rectangle().padding(.top, -8))
							)
						}
					}
					
					if contactViewModel.indexDisplayedFriend != nil || historyViewModel.displayedCall != nil || conversationViewModel.displayedConversation != nil ||
						meetingViewModel.displayedMeeting != nil{
						HStack(spacing: 0) {
							Spacer()
								.frame(maxWidth:
										(orientation == .landscapeLeft
										 || orientation == .landscapeRight
										 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
									   ? (geometry.size.width/100*40) + 75
									   : 0
								)
							if self.index == 0 {
                                if historyViewModel.displayedCall != nil && historyViewModel.displayedCall!.avatarModel != nil {
                                    HistoryContactFragment(
                                        contactAvatarModel: historyViewModel.displayedCall!.avatarModel!,
                                        historyViewModel: historyViewModel,
                                        historyListViewModel: historyListViewModel,
                                        contactViewModel: contactViewModel,
                                        editContactViewModel: editContactViewModel,
                                        isShowDeleteAllHistoryPopup: $isShowDeleteAllHistoryPopup,
                                        isShowEditContactFragment: $isShowEditContactFragment,
                                        indexPage: $index
                                    )
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray100)
                                    .ignoresSafeArea(.keyboard)
                                }
							} else if self.index == 1 {
                                ContactFragment(
                                    contactViewModel: contactViewModel,
                                    editContactViewModel: editContactViewModel,
                                    conversationViewModel: conversationViewModel,
                                    isShowDeletePopup: $isShowDeleteContactPopup,
                                    isShowDismissPopup: $isShowDismissPopup,
                                    isShowSipAddressesPopup: $isShowSipAddressesPopup,
                                    isShowSipAddressesPopupType: $isShowSipAddressesPopupType
                                )
                                .frame(maxWidth: .infinity)
                                .background(Color.gray100)
                                .ignoresSafeArea(.keyboard)
								
							}
                            else if self.index == 2 {
                                Text("")
                            }
                            else if self.index == 3 {
								ConversationFragment(
									conversationViewModel: conversationViewModel,
									conversationsListViewModel: conversationsListViewModel,
									conversationForwardMessageViewModel: conversationForwardMessageViewModel,
									contactViewModel: contactViewModel,
									editContactViewModel: editContactViewModel,
									meetingViewModel: meetingViewModel,
									accountProfileViewModel: accountProfileViewModel,
									isShowConversationFragment: $isShowConversationFragment,
									isShowStartCallGroupPopup: $isShowStartCallGroupPopup,
									isShowEditContactFragment: $isShowEditContactFragment,
									indexPage: $index,
									isShowScheduleMeetingFragment: $isShowScheduleMeetingFragment
								)
								.frame(maxWidth: .infinity)
								.background(Color.gray100)
								.ignoresSafeArea(.keyboard)
							} else if self.index == 4 {
                                //TODO: settings appbar
								MeetingFragment(meetingViewModel: meetingViewModel, meetingsListViewModel: meetingsListViewModel, isShowScheduleMeetingFragment: $isShowScheduleMeetingFragment, isShowSendCancelMeetingNotificationPopup: $isShowSendCancelMeetingNotificationPopup)
									.frame(maxWidth: .infinity)
									.background(Color.gray100)
									.ignoresSafeArea(.keyboard)
							}
							
						}
						.onAppear {
							if !(orientation == .landscapeLeft
								 || orientation == .landscapeRight
								 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
								&& searchIsActive {
								self.focusedField = false
							}
						}
						.onDisappear {
							if !(orientation == .landscapeLeft
								 || orientation == .landscapeRight
								 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)
								&& searchIsActive {
								self.focusedField = true
							}
						}
						.padding(.leading,
								 orientation == .landscapeRight && geometry.safeAreaInsets.bottom > 0
								 ? -geometry.safeAreaInsets.leading
								 : 0)
						.transition(.move(edge: .trailing))
						.zIndex(1)
					}
					
					SideMenu(
						accountProfileViewModel: accountProfileViewModel,
						width: geometry.size.width / 5 * 4,
						isOpen: $sideMenuIsOpen,
						menuClose: self.openMenu,
						safeAreaInsets: geometry.safeAreaInsets,
						isShowLoginFragment: $isShowLoginFragment,
						isShowAccountProfileFragment: $isShowAccountProfileFragment,
						isShowSettingsFragment: $isShowSettingsFragment,
						isShowHelpFragment: $isShowHelpFragment
					)
					.ignoresSafeArea(.all)
					.zIndex(2)
					
					if isShowLoginFragment {
						LoginFragment(
							accountLoginViewModel: AccountLoginViewModel(),
							isShowBack: true,
							onBackPressed: {
								withAnimation {
									isShowLoginFragment.toggle()
								}
							})
						.zIndex(3)
						.transition(.move(edge: .bottom))
						.onAppear {
						}
					}
					
					if isShowEditContactFragment {
						EditContactFragment(
							editContactViewModel: editContactViewModel,
							contactViewModel: contactViewModel,
							isShowEditContactFragment: $isShowEditContactFragment,
							isShowDismissPopup: $isShowDismissPopup
						)
						.zIndex(3)
						.transition(.opacity.combined(with: .move(edge: .bottom)))
						.onAppear {
							contactViewModel.indexDisplayedFriend = nil
						}
					}
					
					if isShowStartCallFragment {
						if #available(iOS 16.4, *), idiom != .pad {
							StartCallFragment(
								callViewModel: callViewModel,
								startCallViewModel: startCallViewModel,
								isShowStartCallFragment: $isShowStartCallFragment,
								showingDialer: $showingDialer,
								resetCallView: {callViewModel.resetCallView()}
							)
							.zIndex(6)
							.transition(.opacity.combined(with: .move(edge: .bottom)))
							.sheet(isPresented: $showingDialer) {
								DialerBottomSheet(
									startCallViewModel: startCallViewModel,
									callViewModel: callViewModel,
									isShowStartCallFragment: $isShowStartCallFragment,
									showingDialer: $showingDialer,
									currentCall: nil
								)
								.presentationDetents([.medium])
								.presentationBackgroundInteraction(.enabled(upThrough: .medium))
							}
						} else {
							StartCallFragment(
								callViewModel: callViewModel,
								startCallViewModel: startCallViewModel,
								isShowStartCallFragment: $isShowStartCallFragment,
								showingDialer: $showingDialer,
								resetCallView: {callViewModel.resetCallView()}
							)
							.zIndex(6)
							.transition(.opacity.combined(with: .move(edge: .bottom)))
							.halfSheet(showSheet: $showingDialer) {
								DialerBottomSheet(
									startCallViewModel: startCallViewModel,
									callViewModel: callViewModel,
									isShowStartCallFragment: $isShowStartCallFragment,
									showingDialer: $showingDialer,
									currentCall: nil
								)
							} onDismiss: {}
						}
					}
					
					if isShowStartConversationFragment {
						StartConversationFragment(
							startConversationViewModel: startConversationViewModel,
							conversationViewModel: conversationViewModel,
							isShowStartConversationFragment: $isShowStartConversationFragment
						)
						.zIndex(6)
						.transition(.opacity.combined(with: .move(edge: .bottom)))
					}
					
					if isShowDeleteContactPopup {
						PopupView(isShowPopup: $isShowDeleteContactPopup,
								  title: Text(String(format: String(localized: "contact_dialog_delete_title"),contactViewModel.selectedFriend != nil
									? contactViewModel.selectedFriend!.name!
													 : (contactViewModel.indexDisplayedFriend != nil
														? contactsManager.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.name!
														: "Error Name"))),
								  content: Text("contact_dialog_delete_message"),
								  titleFirstButton: Text("dialog_cancel"),
								  actionFirstButton: {
							self.isShowDeleteContactPopup.toggle()},
								  titleSecondButton: Text("dialog_ok"),
								  actionSecondButton: {
							if contactViewModel.selectedFriendToDelete != nil {
								if contactViewModel.indexDisplayedFriend != nil {
									withAnimation {
										contactViewModel.indexDisplayedFriend = nil
									}
								}
								contactViewModel.selectedFriendToDelete!.remove()
							} else if contactViewModel.indexDisplayedFriend != nil {
								let tmpIndex = contactViewModel.indexDisplayedFriend
								withAnimation {
									contactViewModel.indexDisplayedFriend = nil
								}
								contactsManager.lastSearch[tmpIndex!].friend!.remove()
							}
							MagicSearchSingleton.shared.searchForContacts(
								sourceFlags: MagicSearch.Source.Friends.rawValue | MagicSearch.Source.LdapServers.rawValue)
							self.isShowDeleteContactPopup.toggle()
						})
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowDeleteContactPopup.toggle()
						}
						.onAppear {
							contactViewModel.selectedFriendToDelete = contactViewModel.selectedFriend
						}
					}
					
					if isShowDeleteAllHistoryPopup {
						PopupView(isShowPopup: $isShowDeleteContactPopup,
								  title: Text("history_dialog_delete_all_call_logs_title"),
								  content: Text("history_dialog_delete_all_call_logs_message"),
								  titleFirstButton: Text("dialog_cancel"),
								  actionFirstButton: {
							self.isShowDeleteAllHistoryPopup.toggle()
							historyListViewModel.callLogsAddressToDelete = ""
						},
								  titleSecondButton: Text("dialog_ok"),
								  actionSecondButton: {
							historyListViewModel.removeCallLogs()
							self.isShowDeleteAllHistoryPopup.toggle()
							historyViewModel.displayedCall = nil
							
							ToastViewModel.shared.toastMessage = "Success_remove_call_logs"
							ToastViewModel.shared.displayToast.toggle()
						})
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowDeleteAllHistoryPopup.toggle()
						}
					}
					
					if isShowDismissPopup {
						PopupView(isShowPopup: $isShowDismissPopup,
								  title: Text("contact_editor_dialog_abort_confirmation_title"),
								  content: Text("contact_editor_dialog_abort_confirmation_message"),
								  titleFirstButton: Text("dialog_cancel"),
								  actionFirstButton: {self.isShowDismissPopup.toggle()},
								  titleSecondButton: Text("dialog_ok"),
								  actionSecondButton: {
							if editContactViewModel.selectedEditFriend == nil {
								self.isShowDismissPopup.toggle()
								editContactViewModel.removePopup = true
								editContactViewModel.resetValues()
								withAnimation {
									isShowEditContactFragment.toggle()
								}
							} else {
								self.isShowDismissPopup.toggle()
								editContactViewModel.resetValues()
								withAnimation {
									editContactViewModel.removePopup = true
								}
							}
						})
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowDismissPopup.toggle()
						}
					}
					
					if isShowSipAddressesPopup {
						SipAddressesPopup(
							contactAvatarModel: ContactsManager.shared.avatarListModel[contactViewModel.indexDisplayedFriend != nil ? contactViewModel.indexDisplayedFriend! : 0],
							contactViewModel: contactViewModel,
							isShowSipAddressesPopup: $isShowSipAddressesPopup,
							isShowSipAddressesPopupType: $isShowSipAddressesPopupType
						)
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							isShowSipAddressesPopup.toggle()
						}
					}
					
					if contactViewModel.operationInProgress {
						PopupLoadingView()
							.background(.black.opacity(0.65))
							.zIndex(3)
							.onDisappear {
								if contactViewModel.displayedConversation != nil {
									contactViewModel.indexDisplayedFriend = nil
									historyViewModel.displayedCall = nil
									index = 2
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
										withAnimation {
											self.conversationViewModel.changeDisplayedChatRoom(conversationModel: contactViewModel.displayedConversation!)
										}
										contactViewModel.displayedConversation = nil
									}
								}
							}
					}
					
					if isShowScheduleMeetingFragment {
						ScheduleMeetingFragment(
							meetingViewModel: meetingViewModel,
							meetingsListViewModel: meetingsListViewModel,
							isShowScheduleMeetingFragment: $isShowScheduleMeetingFragment
						)
						.zIndex(3)
						.transition(.move(edge: .bottom))
						.onAppear {
						}
					}
					
					if isShowAccountProfileFragment {
						AccountProfileFragment(
							accountProfileViewModel: accountProfileViewModel,
							registerViewModel: RegisterViewModel(),
							isShowAccountProfileFragment: $isShowAccountProfileFragment
						)
						.zIndex(3)
						.transition(.move(edge: .trailing))
					}
					
					if isShowSettingsFragment {
						SettingsFragment(
							settingsViewModel: SettingsViewModel(),
							isShowSettingsFragment: $isShowSettingsFragment
						)
						.zIndex(3)
						.transition(.move(edge: .trailing))
					}
					
					if isShowHelpFragment {
						HelpFragment(
							helpViewModel: HelpViewModel(),
							isShowHelpFragment: $isShowHelpFragment
						)
						.zIndex(3)
						.transition(.move(edge: .trailing))
					}
					
					if isShowSendCancelMeetingNotificationPopup {
						PopupView(isShowPopup: $isShowSendCancelMeetingNotificationPopup,
								  title: Text("meeting_schedule_cancel_dialog_title"),
								  content: Text("meeting_schedule_cancel_dialog_message"),
								  titleFirstButton: Text("dialog_cancel"),
								  actionFirstButton: {
							meetingViewModel.displayedMeeting = nil
							meetingsListViewModel.deleteSelectedMeeting()
							self.isShowSendCancelMeetingNotificationPopup.toggle(
							) },
								  titleSecondButton: Text("dialog_ok"),
								  actionSecondButton: {
							meetingViewModel.displayedMeeting = nil
							if let meetingToDelete = self.meetingsListViewModel.selectedMeetingToDelete {
								self.meetingViewModel.cancelMeetingWithNotifications(meeting: meetingToDelete)
								meetingsListViewModel.deleteSelectedMeeting()
								self.isShowSendCancelMeetingNotificationPopup.toggle()
							}
						})
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowSendCancelMeetingNotificationPopup.toggle()
						}
					}
					
					if isShowStartCallGroupPopup {
						PopupView(
							isShowPopup: $isShowStartCallGroupPopup,
							title: Text("conversation_info_confirm_start_group_call_dialog_title"),
							content: Text("conversation_info_confirm_start_group_call_dialog_message"),
							titleFirstButton: Text("dialog_cancel"),
							actionFirstButton: {
								self.isShowStartCallGroupPopup.toggle()
							},
							titleSecondButton: Text("dialog_ok"),
							actionSecondButton: {
								if conversationViewModel.displayedConversation != nil {
									conversationViewModel.displayedConversation!.createGroupCall()
								}
								self.isShowStartCallGroupPopup.toggle()
							}
						)
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowStartCallGroupPopup.toggle()
						}
					}
					
					if isShowStartCallGroupPopup {
						PopupView(
							isShowPopup: $isShowStartCallGroupPopup,
							title: Text("conversation_info_confirm_start_group_call_dialog_title"),
							content: Text("conversation_info_confirm_start_group_call_dialog_message"),
							titleFirstButton: Text("dialog_cancel"),
							actionFirstButton: {
								self.isShowStartCallGroupPopup.toggle()
							},
							titleSecondButton: Text("dialog_ok"),
							actionSecondButton: {
								if conversationViewModel.displayedConversation != nil {
									conversationViewModel.displayedConversation!.createGroupCall()
								}
								self.isShowStartCallGroupPopup.toggle()
							}
						)
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowStartCallGroupPopup.toggle()
						}
					}
					
					if conversationViewModel.isShowConversationInfoPopup {
						PopupViewWithTextField(conversationViewModel: conversationViewModel)
							.background(.black.opacity(0.65))
							.zIndex(3)
							.onTapGesture {
								conversationViewModel.isShowConversationInfoPopup = false
							}
					}
					
					if telecomManager.meetingWaitingRoomDisplayed {
						MeetingWaitingRoomFragment(meetingWaitingRoomViewModel: meetingWaitingRoomViewModel)
							.zIndex(3)
							.transition(.opacity.combined(with: .move(edge: .bottom)))
							.onAppear {
								meetingWaitingRoomViewModel.resetMeetingRoomView()
							}
					}
					
					if telecomManager.callDisplayed && ((telecomManager.callInProgress && telecomManager.outgoingCallStarted) || telecomManager.callConnected) && !telecomManager.meetingWaitingRoomDisplayed {
						CallView(
							callViewModel: callViewModel,
							conversationViewModel: conversationViewModel,
							conversationsListViewModel: conversationsListViewModel,
							conversationForwardMessageViewModel: conversationForwardMessageViewModel,
							contactViewModel: contactViewModel,
							editContactViewModel: editContactViewModel,
							meetingViewModel: meetingViewModel,
							accountProfileViewModel: accountProfileViewModel,
							fullscreenVideo: $fullscreenVideo,
							isShowStartCallFragment: $isShowStartCallFragment,
							isShowConversationFragment: $isShowConversationFragment,
							isShowStartCallGroupPopup: $isShowStartCallGroupPopup,
							isShowEditContactFragment: $isShowEditContactFragment,
							indexPage: $index,
							isShowScheduleMeetingFragment: $isShowScheduleMeetingFragment
						)
						.zIndex(5)
						.transition(.scale.combined(with: .move(edge: .top)))
						.onAppear {
							UIApplication.shared.isIdleTimerDisabled = true
							callViewModel.resetCallView()
							if callViewModel.callsCounter >= 1 {
								DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
									callViewModel.resetCallView()
								}
							}
						}
						.onDisappear {
							UIApplication.shared.isIdleTimerDisabled = false
						}
					}
					
					ToastView()
						.zIndex(6)
				}
			}
			.onChange(of: navigationManager.selectedCallId) { newCallId in
				if newCallId != nil {
					self.index = 2
				}
			}
			.onReceive(pub) { _ in
				conversationsListViewModel.updateChatRoomsList()
				historyListViewModel.refreshHistoryAvatarModel()
			}
			.onReceive(pub2) { address in
				conversationsListViewModel.updateChatRoom(address: address)
			}
		}
		.overlay {
			if isMenuOpen {
				Color.white.opacity(0.001)
					.ignoresSafeArea()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.onTapGesture {
						isMenuOpen = false
					}
			}
		}
		.onRotate { newOrientation in
			if (contactViewModel.indexDisplayedFriend != nil || historyViewModel.displayedCall != nil || conversationViewModel.displayedConversation != nil) && searchIsActive {
				self.focusedField = false
			} else if searchIsActive {
				self.focusedField = true
			}
			orientation = newOrientation
		}
		.onChange(of: scenePhase) { newPhase in
			orientation = UIDevice.current.orientation
			if newPhase == .active {
				conversationsListViewModel.computeChatRoomsList(filter: "")
				accountProfileViewModel.setAvatarModel()
			}
		}
	}
	
	func openMenu() {
		withAnimation {
			self.sideMenuIsOpen.toggle()
		}
	}
}

@available(iOS 17.0, *)
#Preview {
    
    @Previewable @StateObject var navigationManager = NavigationManager()
    VoxContentView(
        contactViewModel: ContactViewModel(),
        editContactViewModel: EditContactViewModel(),
        historyViewModel: HistoryViewModel(),
        historyListViewModel: HistoryListViewModel(),
        startCallViewModel: StartCallViewModel(),
        startConversationViewModel: StartConversationViewModel(),
        callViewModel: CallViewModel(),
        meetingWaitingRoomViewModel: MeetingWaitingRoomViewModel(),
        conversationsListViewModel: ConversationsListViewModel(),
        conversationViewModel: ConversationViewModel(),
        meetingsListViewModel: MeetingsListViewModel(),
        meetingViewModel: MeetingViewModel(),
        conversationForwardMessageViewModel: ConversationForwardMessageViewModel(),
        accountProfileViewModel: AccountProfileViewModel()
    )
    .environmentObject(navigationManager)
}

// swiftlint:enable type_body_length
// swiftlint:enable line_length
