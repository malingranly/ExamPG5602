//
//  EditAreaInCoreDataView.swift
//  Ratatouille

import SwiftUI

struct EditAreaInCoreDataView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @ObservedObject var area: Area
    @State private var editedAreaName: String

    /// Init
    init(area: Area, isSheetPresented: Binding<Bool>) {
        self.area = area
        self._isSheetPresented = isSheetPresented
        self._editedAreaName = State(initialValue: area.strArea ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rediger landområde")) {
                    TextField("Navn på landområde", text: $editedAreaName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                }
            }
            .navigationTitle("Rediger landområde")
            .navigationBarItems(
                trailing: Button("Lagre") {
                    viewContext.perform {
                        area.strArea = editedAreaName
                        try? viewContext.save()
                        isSheetPresented = false
                    }
                }.buttonStyle(.bordered)
            )
        }
    }
}

struct EditAreaInCoreDataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleArea = Area()

        sampleArea.strArea = "Test Area"
        sampleArea.flagURL = "https://enrandomurl.png"
        sampleArea.countryCode = "NO"
        sampleArea.isArchived = false
        
        let isSheetPresented = Binding.constant(false)

        return EditAreaInCoreDataView(area: sampleArea, isSheetPresented: isSheetPresented)
    }
}

