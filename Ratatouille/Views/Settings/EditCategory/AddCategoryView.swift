//
//  AddAreaView.swift
//  Ratatouille

import SwiftUI

struct AddCategoryView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @Binding var newCategoryName: String
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Navn på kategori", text: $newCategoryName)
                    .font(.title)
                    .padding()
                
                Button("Legg til") {
                    let newCategory = Category(context: viewContext)
                    newCategory.strCategory = newCategoryName
                    newCategory.isArchived = false
                    
                    do {
                        try viewContext.save()
                        isSheetPresented.toggle()
                    } catch {
                        print("Error saving new category: \(error)")
                    }
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .ignoresSafeArea()
            .navigationTitle("Legg til kategori")
            .navigationBarItems(trailing: Button("Tilbake") {
                isSheetPresented.toggle()
            })
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let isSheetPresented = Binding.constant(true)
        let newCategoryName = Binding.constant("")

        return AddCategoryView(isSheetPresented: isSheetPresented, newCategoryName: newCategoryName)
            .environment(\.managedObjectContext, DataController.shared.viewContext)
    }
}

