//
//  DataController.swift
//  Ratatouille

import Foundation
import CoreData

class DataController: ObservableObject {
    /// Variables
    let container = NSPersistentContainer(name: "Ratatouille")
    static let shared = DataController()
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    /// Init
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error)
            }
            print(description)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Save changes in both the view context and background context.
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving view context: \(error)")
            }
        }
        
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Error saving background context: \(error)")
            }
        }
    }
    
    /// Fetching
    func fetchAreaByStrArea(strArea: String?) async throws -> Area? {
        guard let strArea = strArea else {
            return nil
        }
        
        let request: NSFetchRequest<Area> = Area.fetchRequest()
        request.predicate = NSPredicate(format: "strArea == %@", strArea)
        
        do {
            let areas = try viewContext.fetch(request)
            return areas.first
        } catch {
            print("Error fetching area by strArea: \(error)")
            throw error
        }
    }
    
    func fetchCategoryByStrCategory(strCategory: String) async throws -> Category? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "strCategory == %@", strCategory)
        
        do {
            let categories = try viewContext.fetch(request)
            return categories.first
        } catch {
            throw error
        }
    }
    
    /// Meal functionality
    func deleteMeal(idMeal: String) {
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idMeal == %@", idMeal)
        
        viewContext.perform { [weak self] in
            do {
                let meals = try fetchRequest.execute()
                if let meal = meals.first {
                    self?.viewContext.delete(meal)
                    try self?.viewContext.save()
                }
            } catch {
                print("Error deleting meal: \(error)")
            }
        }
    }
    
    func isMealArchived(mealID: String) -> Bool {
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idMeal == %@ AND isArchived == true", mealID)
        
        do {
            let matchingMeals = try viewContext.fetch(fetchRequest)
            return !matchingMeals.isEmpty
        } catch {
            print("Error checking if meal is archived: \(error)")
            return false
        }
    }
    
    func updateMealArchivedStatus(mealID: String, isArchived: Bool) async throws {
        try await Task {
            do {
                try await viewContext.perform { [self] in
                    let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                    request.predicate = NSPredicate(format: "idMeal == %@", mealID)
                    
                    do {
                        if let matchingMeal = try viewContext.fetch(request).first {
                            matchingMeal.isArchived = isArchived
                            do {
                                try viewContext.save()
                                print("Meal \(mealID) archived status updated successfully.")
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        } else {
                            print("Meal with ID \(mealID) not found.")
                        }
                    } catch {
                        print("Error fetching meal: \(error)")
                    }
                }
            } catch {
                print("Error performing Core Data operation: \(error)")
            }
        }
    }
}
