//
//  EditArchiveView.swift
//  Ratatouille

import SwiftUI

struct EditArchiveView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Fetch requests
    @FetchRequest(
        entity: Meal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Meal.strMeal, ascending: true)
        ],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: true))
    ) var archivedMeals: FetchedResults<Meal>
    
    @FetchRequest(
        entity: Area.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Area.strArea, ascending: true)
        ],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: true))
    ) var archivedAreas: FetchedResults<Area>
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.strCategory, ascending: true)
        ],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: true))
    ) var archivedCategories: FetchedResults<Category>
    
    @FetchRequest(
        entity: Ingredient.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Ingredient.strIngredient, ascending: true)
        ],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: true))
    ) var archivedIngredients: FetchedResults<Ingredient>
    
    var body: some View {
        NavigationView {
            List {
                Section("landområder") {
                    if archivedAreas.isEmpty {
                        Text("Ingen arkiverte landområder")
                    } else {
                        ForEach(archivedAreas, id: \.id) { area in
                            Text(area.strArea ?? "Unknown Area")
                                .swipeActions {
                                    Button {
                                        viewContext.perform {
                                            area.isArchived = false
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.left.circle")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        viewContext.perform {
                                            viewContext.delete(area)
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.circle")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
                
                Section("Kategorier") {
                    if archivedCategories.isEmpty {
                        Text("Ingen arkiverte kategorier")
                    } else {
                        ForEach(archivedCategories, id: \.id) { category in
                            Text(category.strCategory ?? "Unknown Category")
                                .swipeActions {
                                    Button {
                                        viewContext.perform {
                                            category.isArchived = false
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.left.circle")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        viewContext.perform {
                                            viewContext.delete(category)
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.circle")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
                
                Section("Ingredienser") {
                    if archivedIngredients.isEmpty {
                        Text("Ingen arkiverte ingredienser")
                    } else {
                        ForEach(archivedIngredients, id: \.id) { ingredient in
                            Text(ingredient.strIngredient ?? "Unknown Ingredient")
                                .swipeActions {
                                    Button {
                                        viewContext.perform {
                                            ingredient.isArchived = false
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.left.circle")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        viewContext.perform {
                                            viewContext.delete(ingredient)
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.circle")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
                
                Section("Matoppskrifter") {
                    if archivedMeals.isEmpty {
                        Text("Ingen arkiverte matoppskrifter")
                    } else {
                        ForEach(archivedMeals, id: \.idMeal) { meal in
                            Text(meal.strMeal ?? "Unknown Meal")
                                .swipeActions {
                                    Button {
                                        viewContext.perform {
                                            meal.isArchived = false
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.left.circle")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        viewContext.perform {
                                            if let mealsRelationship = meal.category?.mutableSetValue(forKey: "meal") {
                                                mealsRelationship.remove(meal)
                                            }
                                            viewContext.delete(meal)
                                            do {
                                                try viewContext.save()
                                                print("Meal deleted successfully")
                                            } catch {
                                                print("Error saving context: \(error)")
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.circle")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Arkiv")
            .environment(\.managedObjectContext, DataController.shared.viewContext)
        }
        
    }
}
struct EditArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        EditArchiveView()
    }
}
