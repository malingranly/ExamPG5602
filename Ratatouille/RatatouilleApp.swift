//
//  RatatouilleApp.swift
//  Ratatouille

import SwiftUI
import CoreData

@main
struct RatatouilleApp: App {
    /// Variables
    let dataController = DataController.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var favoriteMeals: [MealDetails] = []
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplashView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashView {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    showSplashView = false
                                }
                            }
                        }
                } else {
                    TabView {
                        FavoritesView()
                            .environment(\.managedObjectContext, DataController.shared.viewContext)
                            .tabItem {
                                Label("Mine oppskrifter", systemImage: "fork.knife.circle.fill")
                            }
                            .onAppear {
                                print("RatatouilleApp - On Appear")
                                print("Initial favorite meals: \(favoriteMeals)")
                            }
                        
                        SearchView()
                            .environment(\.managedObjectContext, DataController.shared.viewContext)
                            .tabItem {
                                Label("Søk", systemImage: "magnifyingglass.circle.fill")
                            }
                        
                        SettingsView()
                            .environment(\.managedObjectContext, DataController.shared.viewContext)
                            .tabItem {
                                Label("Innstillinger", systemImage: "gearshape.fill")
                            }
                    }
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                }
            }
        }
    }
}
