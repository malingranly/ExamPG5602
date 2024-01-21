//
//  AddAreaView.swift
//  Ratatouille

import SwiftUI

struct AddAreaView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @Binding var newAreaName: String
    @State private var flagURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Navn på landområde", text: $newAreaName)
                    .font(.title)
                    .padding()

                Button {
                    fetchFlagURL()
                    addNewArea()
                } label: {
                    Text("Legg til")
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("Legg til landområde")
            .navigationBarItems(trailing: Button("Tilbake") {
                isSheetPresented.toggle()
            })
        }
    }
    
    func fetchFlagURL() {
        guard let countryCode = CountryMapping.countryCodes[newAreaName] else {
            print("Invalid country area: \(newAreaName)")
            return
        }
        
        let flagURLString = "https://flagsapi.com/\(countryCode)/shiny/64.png"
        
        if let flagURL = URL(string: flagURLString) {
            self.flagURL = flagURL
            print("Flag URL fetched successfully: \(flagURL)")
        } else {
            print("Invalid flag URL: \(flagURLString)")
        }
    }
    
    func addNewArea() {
        Task {
            do {
                let newArea = Area(context: viewContext)
                newArea.strArea = newAreaName
                newArea.isArchived = false
    
                newArea.flagURL = flagURL?.absoluteString
                
                try viewContext.performAndWait {
                    try viewContext.save()
                }
            
                isSheetPresented.toggle()
            } catch {
                print("Error adding new area: \(error)")
            }
        }
    }
}


struct AddAreaView_Previews: PreviewProvider {
    static var previews: some View {
        let isSheetPresented = Binding.constant(true)
        let newAreaName = Binding.constant("")

        return AddAreaView(isSheetPresented: isSheetPresented, newAreaName: newAreaName)
            .environment(\.managedObjectContext, DataController.shared.viewContext)
    }
}
