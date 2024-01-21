// EditIngredientView.swift
// Ratatouille

import SwiftUI

struct EditIngredientView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingIngredientSheetPresented = false
    @State private var newIngredientName = ""
    @State private var selectedIngredient: Ingredient?
    @State private var isEditingIngredientSheetPresented = false
    
    /// Fetch requests
    @FetchRequest(
            entity: Ingredient.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Ingredient.strIngredient, ascending: true)
            ], predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: false))
        ) var ingredients: FetchedResults<Ingredient>
  
    var body: some View {
        NavigationView {
            List {
                ForEach(ingredients, id: \.id) { ingredient in
                    NavigationLink(
                        destination: EditIngredientInCoreDataView(ingredient: ingredient, isSheetPresented: $isEditingIngredientSheetPresented)
                    ) {
                        Text(ingredient.strIngredient ?? "Unknown Ingredient")
                    }
                    .swipeActions {
                        Button {
                            viewContext.perform {
                                ingredient.isArchived = true
                                try? viewContext.save()
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox.circle")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            selectedIngredient = ingredient
                            isEditingIngredientSheetPresented.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
                .onDelete { indexSet in
                    viewContext.perform {
                        for index in indexSet {
                            let ingredient = ingredients[index]
                            viewContext.delete(ingredient)
                        }

                        try? viewContext.save()
                    }
                }
            }
            .navigationTitle("Redigere ingredienser")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isAddingIngredientSheetPresented.toggle()
                    } label: {
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
            .sheet(isPresented: $isAddingIngredientSheetPresented) {
                if let selectedIngredient = selectedIngredient {
                    EditIngredientInCoreDataView(ingredient: selectedIngredient, isSheetPresented: $isEditingIngredientSheetPresented)
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    AddIngredientView(isSheetPresented: $isAddingIngredientSheetPresented, newIngredientName: $newIngredientName)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

struct EditIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        EditIngredientView()
    }
}
