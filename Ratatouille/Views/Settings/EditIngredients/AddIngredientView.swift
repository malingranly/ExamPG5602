//
//  AddAreaView.swift
//  Ratatouille

import SwiftUI

struct AddIngredientView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isSheetPresented: Bool
    @Binding var newIngredientName: String
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Navn på ingrediens", text: $newIngredientName)
                    .font(.title)
                    .padding()
                
                Button("Legg til") {
                    let newIngredient = Ingredient(context: viewContext)
                    newIngredient.strIngredient = newIngredientName
                    newIngredient.isArchived = false
                    
                    do {
                        try viewContext.save()
                        isSheetPresented.toggle()
                    } catch {
                        print("Error saving new area: \(error)")
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                
            }
            .navigationTitle("Legg til ingredienser")
            .navigationBarItems(trailing: Button("Tilbake") {
                isSheetPresented.toggle()
            })
        }
    }
}

struct AddIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        let isSheetPresented = Binding.constant(true)
        let newIngredientName = Binding.constant("")

        return AddIngredientView(isSheetPresented: isSheetPresented, newIngredientName: newIngredientName)
            .environment(\.managedObjectContext, DataController.shared.viewContext)
    }
}

