//
//  LearnDirectoryView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-17.
//

import SwiftUI

// MARK: - PRAHAR LOGIC HELPERS
struct PraharInfo {
    let title: String
    let timeString: String
    let recommendedRaags: [String]
    let themeColor: Color
}

func calculateCurrentPrahar() -> PraharInfo {
    let hour = Calendar.current.component(.hour, from: Date())
    
    switch hour {
    case 6..<9:   return PraharInfo(title: "1st Prahar", timeString: "6 AM - 9 AM", recommendedRaags: ["Bhairav", "Ahir Bhairav", "Ramkali"], themeColor: .orange)
    case 9..<12:  return PraharInfo(title: "2nd Prahar", timeString: "9 AM - 12 PM", recommendedRaags: ["Asavari", "Jaunpuri", "Todi"], themeColor: .yellow)
    case 12..<15: return PraharInfo(title: "3rd Prahar", timeString: "12 PM - 3 PM", recommendedRaags: ["Brindavani Sarang", "Shuddha Sarang", "Gaud Sarang"], themeColor: .green)
    case 15..<18: return PraharInfo(title: "4th Prahar", timeString: "3 PM - 6 PM", recommendedRaags: ["Multani", "Shree", "Puriya Dhanashree"], themeColor: .pink)
    case 18..<21: return PraharInfo(title: "5th Prahar", timeString: "6 PM - 9 PM", recommendedRaags: ["Yaman", "Bhoopali", "Puriya"], themeColor: .indigo)
    case 21..<24: return PraharInfo(title: "6th Prahar", timeString: "9 PM - 12 AM", recommendedRaags: ["Bageshree", "Jaijaiwanti", "Bihag"], themeColor: .purple)
    case 0..<3:   return PraharInfo(title: "7th Prahar", timeString: "12 AM - 3 AM", recommendedRaags: ["Malkauns", "Darbari Kanada", "Adana"], themeColor: .gray)
    case 3..<6:   return PraharInfo(title: "8th Prahar", timeString: "3 AM - 6 AM", recommendedRaags: ["Lalit", "Bhatiyar", "Sohini"], themeColor: .cyan)
    default:      return PraharInfo(title: "Anytime", timeString: "Riyaz Time", recommendedRaags: ["Bhairav", "Yaman", "Malkauns"], themeColor: .blue)
    }
}

// MARK: - MAIN VIEW
struct LearnDirectoryView: View {
    
    @StateObject private var viewModel = LearnViewModel()
    @StateObject private var authVM = AuthViewModel()
    
    // Sheet State Variables
    @State private var showLoginSheet = false
    @State private var showAddRaagSheet = false
    
    @State private var activePrahar: PraharInfo = calculateCurrentPrahar()

    // Search State Variables
    @State private var selectedJati = "Any"
    @State private var selectedThaat = "Any"
    @State private var selectedTime = "Any"
    
    let jatis = ["Any", "Audav-Audav", "Shadav-Shadav", "Sampurna", "Audav-Sampurna"]
    let thaats = ["Any", "Bilawal", "Kalyan", "Khamaj", "Bhairav", "Marwa", "Kafi"]
    let times = ["Any", "Morning", "Afternoon", "Evening", "Night"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - TOP 1/3: THE SMART PRAHAR HEADER
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(activePrahar.title) • \(activePrahar.timeString)")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(activePrahar.themeColor)
                        .textCase(.uppercase)
                    
                    Text("Recommended for this time:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // THE 3 RAAG BUTTONS
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                ForEach(activePrahar.recommendedRaags, id: \.self) { raagName in
                                                    
                                                    // 1. Check if this Raag actually exists in our Firebase database
                                                    if let matchedRaag = viewModel.raags.first(where: { $0.name == raagName }) {
                                                        
                                                        // 2. If it DOES exist, pass the full object and the viewModel!
                                                        NavigationLink(destination: RaagDetailView(raag: matchedRaag, viewModel: viewModel)) {
                                                            Text(raagName)
                                                                .fontWeight(.semibold)
                                                                .padding(.horizontal, 20)
                                                                .padding(.vertical, 10)
                                                                .background(activePrahar.themeColor)
                                                                .foregroundColor(.white)
                                                                .clipShape(Capsule())
                                                                .shadow(color: activePrahar.themeColor.opacity(0.3), radius: 4, x: 0, y: 2)
                                                        }
                                                        
                                                    } else {
                                                        // 3. If it doesn't exist in the database yet, show a grayed-out "Coming Soon" style pill
                                                        Text(raagName)
                                                            .fontWeight(.semibold)
                                                            .padding(.horizontal, 20)
                                                            .padding(.vertical, 10)
                                                            .background(Color.gray.opacity(0.2))
                                                            .foregroundColor(.gray)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 5)
                                        }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(activePrahar.themeColor.opacity(0.1))
                
                // MARK: - MIDDLE 1/3: THE SEARCH INTERFACE
                Form {
                    Section(header: Text("Search Raag Index").font(.headline)) {
                        Picker("Jati of the Raag", selection: $selectedJati) {
                            ForEach(jatis, id: \.self) { Text($0) }
                        }
                        Picker("Thaat of the Raag", selection: $selectedThaat) {
                            ForEach(thaats, id: \.self) { Text($0) }
                        }
                        Picker("Time of the Raag", selection: $selectedTime) {
                            ForEach(times, id: \.self) { Text($0) }
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: Text("Search Results View Here")) {
                            HStack {
                                Spacer()
                                Text("Search \(viewModel.raags.count) Raags")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.blue)
                    }
                }
                .scrollDisabled(true)
            }
            // FIX: Attached the Login Sheet to the inner VStack
            .sheet(isPresented: $showLoginSheet) {
                LoginSheet()
                    .environmentObject(authVM)
            }
            .navigationTitle("Library")
            .onAppear {
                viewModel.fetchRaags()
                activePrahar = calculateCurrentPrahar()
            }
            .toolbar {
                if authVM.isAdmin {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showAddRaagSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if authVM.isAuthenticated {
                        Button(action: { authVM.logout() }) {
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: { showLoginSheet = true }) {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        // FIX: Attached the Add Raag Sheet to the outer NavigationStack
        .sheet(isPresented: $showAddRaagSheet) {
            AddRaagView(viewModel: viewModel)
        }
    }
}

   
#Preview {
    LearnDirectoryView()
}
