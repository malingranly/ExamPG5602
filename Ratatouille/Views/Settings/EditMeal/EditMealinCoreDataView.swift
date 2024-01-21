//
//  EditMealView.swift
//  Ratatouille

import SwiftUI
import CoreData

struct EditMealInCoreDataView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @ObservedObject var meal: Meal
    @State private var editedName: String
    @State private var editedInstructions: String
    @State private var editedArea: String
    @State private var editedCategory: String

    /// Init
    init(meal: Meal, isSheetPresented: Binding<Bool>) {
        self._meal = ObservedObject(wrappedValue: meal)
        self._isSheetPresented = isSheetPresented
        self._editedName = State(initialValue: meal.strMeal ?? "")
        self._editedInstructions = State(initialValue: meal.strInstructions ?? "")
        self._editedArea = State(initialValue: meal.strArea ?? "")
        self._editedCategory = State(initialValue: meal.strCategory ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rediger matoppskrift")) {
                    TextField("Navn på oppskrift", text: $editedName)
                }

                Section(header: Text("Rediger instruksjoner")) {
                    TextField("Instruksjoner", text: $editedInstructions)
                }
                
                Section(header: Text("Rediger område")) {
                    TextField("Navn på område", text: $editedArea)
                }
                Section(header: Text("Rediger kategori")) {
                    TextField("Navn på kategori", text: $editedCategory)
                }
                
            }
            .navigationTitle("Rediger matoppskrift")
            .navigationBarItems(
                trailing: Button("Lagre") {
                    viewContext.perform {
                        meal.strMeal = editedName
                        meal.strInstructions = editedInstructions
                        meal.strArea = editedArea
                        meal.strCategory = editedCategory
                        try? viewContext.save()
                        isSheetPresented = false
                    }
                }.buttonStyle(.bordered)
            )
        }
    }
}

struct EditMealInCoredataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeal = Meal() 

        return EditMealInCoreDataView(meal: sampleMeal, isSheetPresented: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
