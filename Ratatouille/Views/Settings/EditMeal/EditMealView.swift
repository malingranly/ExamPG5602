//
//  EditCategoryView.swift
//  Ratatouille

import SwiftUI

struct EditMealView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditingMealSheetPresented = false
    @State private var selectedMeal: Meal?
    
    /// Fetch requests
    @FetchRequest(
        entity: Meal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Meal.strMeal, ascending: true)
        ], predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: false))
    ) var meals: FetchedResults<Meal>
    

    var body: some View {
        NavigationView {
            List {
                if meals.isEmpty {
                    Text("Ingen favoriserte måltider")
                } else {
                    ForEach(meals, id: \.id) { meal in
                        NavigationLink(
                            destination: EditMealInCoreDataView(meal: meal, isSheetPresented: $isEditingMealSheetPresented)
                        ) {
                            Text(meal.strMeal ?? "Unknown meal")
                        }
                        .swipeActions {
                            Button {
                                viewContext.perform {
                                    meal.isArchived = true
                                    try? viewContext.save()
                                }
                            } label: {
                                Label("Archive", systemImage: "archivebox.circle")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete { indexSet in
                        viewContext.perform {
                            for index in indexSet {
                                let meal = meals[index]
                                viewContext.delete(meal)
                            }
                            try? viewContext.save()
                        }
                    }
                }
                   
            } .navigationTitle("Redigere matoppskrift")
        }
    }
}

struct EditMealView_Previews: PreviewProvider {
    static var previews: some View {
        EditMealView()
    }
}
