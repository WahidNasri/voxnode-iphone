//
//  VoxCallsAndRecordingsView.swift
//  LinphoneApp
//
//  Created by Wahid on 02/08/2025.
//

import SwiftUI
import linphonesw

struct VoxCallsAndRecordingsView: View {
    
    // Required parameters for HistoryView
    @ObservedObject var historyListViewModel: HistoryListViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @ObservedObject var contactViewModel: ContactViewModel
    @ObservedObject var editContactViewModel: EditContactViewModel
    
    @Binding var index: Int
    @Binding var isShowStartCallFragment: Bool
    @Binding var isShowEditContactFragment: Bool
    @Binding var text: String
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Custom Tab Bar
                    HStack(spacing: 0) {
                        Button(action: {
                            selectedTab = 0
                        }) {
                            VStack(spacing: 4) {
                                Text("Calls")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == 0 ? .lightBlueMain500 : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == 0 ? Color.lightBlueMain500 : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            selectedTab = 1
                        }) {
                            VStack(spacing: 4) {
                                Text("Recordings")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == 1 ? .lightBlueMain500 : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == 1 ? Color.lightBlueMain500 : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        // Tab 0: Calls
                        HistoryView(
                            historyListViewModel: historyListViewModel,
                            historyViewModel: historyViewModel,
                            contactViewModel: contactViewModel,
                            editContactViewModel: editContactViewModel,
                            index: $index,
                            isShowStartCallFragment: $isShowStartCallFragment,
                            isShowEditContactFragment: $isShowEditContactFragment,
                            text: $text
                        )
                        .tag(0)
                        
                        // Tab 1: Recordings
                        VStack {
                            Spacer()
                            
                            VStack(spacing: 16) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No recordings")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
        }
    }
}

#Preview {
    VoxCallsAndRecordingsView(
        historyListViewModel: HistoryListViewModel(),
        historyViewModel: HistoryViewModel(),
        contactViewModel: ContactViewModel(),
        editContactViewModel: EditContactViewModel(),
        index: .constant(1),
        isShowStartCallFragment: .constant(false),
        isShowEditContactFragment: .constant(false),
        text: .constant("")
    )
}

