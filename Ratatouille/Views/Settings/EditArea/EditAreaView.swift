//
//  EditAreaView.swift
//  Ratatouille

import SwiftUI
import CoreData

struct EditAreaView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingAreaSheetPresented = false
    @State private var newAreaName = ""
    @State private var isEditMode = false
    @State private var selectedArea: Area?
    
    /// Fetch requests
    @FetchRequest(
        entity: Area.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Area.strArea, ascending: true)
        ],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: false))
    ) var areas: FetchedResults<Area>

    var body: some View {
        NavigationView {
            List {
                ForEach(areas, id: \.id) { area in
                    NavigationLink(destination: EditAreaInCoreDataView(area: area, isSheetPresented: $isAddingAreaSheetPresented)) {
                        HStack {
                            if let flagURL = area.flagURL, let url = URL(string: flagURL) {
                                AsyncImageView(url: url)
                                    .frame(width: 30, height: 30)

                            }
                            Text(area.strArea ?? "Unknown Area")
                        }
                    }
                    .swipeActions {
                        Button {
                            viewContext.perform {
                                area.isArchived = true
                                try? viewContext.save()
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox.circle")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete { indexSet in
                    viewContext.perform {
                        for index in indexSet {
                            let area = areas[index]
                            viewContext.delete(area)
                        }

                        try? viewContext.save()
                    }
                }
            }
            .navigationTitle("Redigere landområder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAddingAreaSheetPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $isAddingAreaSheetPresented) {
                AddAreaView(isSheetPresented: $isAddingAreaSheetPresented, newAreaName: $newAreaName)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .environment(\.editMode, .constant(isEditMode ? EditMode.active : EditMode.inactive))
    }
}

struct EditAreaView_Previews: PreviewProvider {
    static var previews: some View {
        EditAreaView()
    }
}
