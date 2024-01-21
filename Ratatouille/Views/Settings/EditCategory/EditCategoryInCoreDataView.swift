//
//  EditCategoryInCoreDataView.swift
//  Ratatouille

import SwiftUI

struct EditCategoryInCoreDataView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @ObservedObject var category: Category
    @State private var editedCategoryName: String

    /// Init
    init(category: Category, isSheetPresented: Binding<Bool>) {
        self.category = category
        self._isSheetPresented = isSheetPresented
        self._editedCategoryName = State(initialValue: category.strCategory ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rediger kategorier")) {
                    TextField("Navn på kategori", text: $editedCategoryName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                }
            }
            .navigationTitle("Rediger kategorier")
            .navigationBarItems(
                trailing: Button("Lagre") {
                    viewContext.perform {
                        category.strCategory = editedCategoryName
                        try? viewContext.save()
                        isSheetPresented = false
                    }
                }.buttonStyle(.bordered)
            )
        }
    }
}

struct EditCategoryInCoreDataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = Category()
        
        sampleCategory.strCategory = "Test Category"
        sampleCategory.isArchived = false

        let isSheetPresented = Binding.constant(false)

        return EditCategoryInCoreDataView(category: sampleCategory, isSheetPresented: isSheetPresented)
    }
}
