//
//  SettingsView.swift
//  Ratatouille

import SwiftUI

struct SettingsView: View {
    /// Variables
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var isEditingSheetPresented = false
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                List{
                    Section("Redigering"){
                        NavigationLink {
                            EditAreaView()
                        } label: {
                            Text("Redigere landområder")
                        }
                        NavigationLink {
                            EditCategoryView()
                        } label: {
                            Text("Redigere kategorier")
                        }
                        NavigationLink {
                            EditIngredientView()
                        } label: {
                            Text("Redigere ingredienser")
                        }
                        NavigationLink {
                            EditMealView()
                        } label: {
                            Text("Redigere matoppskrifter")
                        }
                    }
                    
                    Section("Aktivere Mørk modus"){
                        HStack{
                            Text("Mørk modus")
                            Toggle(isOn: $isDarkMode){
                                
                            }
                        }
                    }
                    
                    Section("Administrering"){
                        NavigationLink {
                            EditArchiveView()
                        } label: {
                            Text("Administrere arkiv")
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }.navigationTitle("Innstillinger")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
