// EditIngredientInCoreDataView.swift
// Ratatouille

import SwiftUI

struct EditIngredientInCoreDataView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @ObservedObject var ingredient: Ingredient
    @State private var editedIngredientName: String

    /// Init
    init(ingredient: Ingredient, isSheetPresented: Binding<Bool>) {
        self.ingredient = ingredient
        self._isSheetPresented = isSheetPresented
        self._editedIngredientName = State(initialValue: ingredient.strIngredient ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rediger ingredienser")) {
                    TextField("Navn på ingrediens", text: $editedIngredientName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                }
            }
            .navigationTitle("Rediger ingredienser")
            .navigationBarItems(
                trailing: Button("Lagre") {
                    viewContext.perform {
                        ingredient.strIngredient = editedIngredientName
                        try? viewContext.save()
                        isSheetPresented = false
                    }
                }.buttonStyle(.bordered)
            )
        }
    }
}

struct EditIngredientInCoreDataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleIngredient = Ingredient()

        sampleIngredient.strIngredient = "Test Ingredient"
        sampleIngredient.isArchived = false

        let isSheetPresented = Binding.constant(false)

        return EditIngredientInCoreDataView(ingredient: sampleIngredient, isSheetPresented: isSheetPresented)
    }
}

