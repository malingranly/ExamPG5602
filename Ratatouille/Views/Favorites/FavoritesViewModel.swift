//
//  FavoritesViewModel.swift
//  Ratatouille

import Foundation
import SwiftUI
import CoreData

class FavoritesViewModel: ObservableObject {
    /// Variables
    @Published var savedMeals: [MealDetails] = []
    @Published var searchResults: [MealDetails] = []
    @Published var selectedSearchType: SearchType = .meal
    @Published var favoriteMealIDs: Set<String> = []
    
    // Enum
    enum SearchType: String, CaseIterable {
            case meal
            case area
            case category
            case ingredient
        }
  
    /// Core data
    func fetchSavedMealsFromCoreData() {
        let context = DataController.shared.viewContext
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: false))

        do {
            let meals = try context.fetch(fetchRequest)
            self.savedMeals = meals.map { meal in
                MealDetails(
                    idMeal: meal.idMeal ?? "",
                    strMeal: meal.strMeal ?? "",
                    strArea: meal.strArea,
                    strCategory: meal.strCategory ?? "",
                    strInstructions: meal.strInstructions ?? "",
                    strMealThumb: meal.strMealThumb ?? "",
                    ingredients: []
                )
            }
            print("Fetched meals from Core Data: \(savedMeals)")
        } catch {
            print("Error fetching meals from Core Data: \(error)")
        }
    }
    
    func fetchMealDetailsById(id: String) async throws -> MealDetails {
        do {
            return try await APIClient().getMealDetailsById(id: id)
        } catch {
            throw error
        }
    }

    /// Filtering search
    func filterMealsByArea(area: String) async throws -> MealResponse? {
        do {
            let response = try await APIClient().filterMealsByArea(area: area)
            print("Received JSON: \(String(describing: response))")

            guard let mealsArray = response?.meals else {
                print("Error: Meals key not found in JSON response")
                return nil
            }

            for (index, meal) in mealsArray.enumerated() {
                print("Meal \(index + 1): \(meal)")
            }

            return response
        } catch {
            print("Error filtering meals by area: \(error)")
            throw error
        }
    }

    func filterMealsByCategory(category: String) async throws -> MealResponse? {
            do {
                let response = try await APIClient().filterMealsByCategory(category: category)
                print("Received JSON: \(String(describing: response))")
                
                guard let mealsArray = response.meals else {
                    print("Error: Meals key not found in JSON response")
                    return nil
                }

                for (index, meal) in mealsArray.enumerated() {
                    print("Meal \(index + 1): \(meal)")
                }

                return response
            } catch {
                print("Error filtering meals by category: \(error)")
                throw error
            }
        }

        func filterMealsByIngredient(ingredient: String) async throws -> MealResponse? {
            do {
                let response = try await APIClient().filterMealsByIngredient(ingredient: ingredient)
                print("Received JSON: \(String(describing: response))")

                guard let mealsArray = response.meals else {
                    print("Error: Meals key not found in JSON response")
                    return nil
                }

                for (index, meal) in mealsArray.enumerated() {
                    print("Meal \(index + 1): \(meal)")
                }

                return response
            } catch {
                print("Error filtering meals by ingredient: \(error)")
                throw error
            }
        }

    /// Searching meals
    func searchMeals(by searchText: String) async {
        print("Search text: \(searchText)")
        
        switch selectedSearchType {
        case .meal:
            print("Searching meals by name")
            DispatchQueue.main.async {
                self.searchResults = self.savedMeals.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
            }
        case .area:
            print("Searching meals by area")
            do {
                if let response = try await filterMealsByArea(area: searchText) {
                    DispatchQueue.main.async {
                        self.searchResults = response.meals ?? []
                    }
                }
            } catch {
                print("Error searching meals by area: \(error)")
            }
        case .category:
            print("Searching meals by category")
            DispatchQueue.main.async {
                self.searchResults = self.savedMeals.filter { ($0.strCategory ?? "").localizedCaseInsensitiveContains(searchText) }
            }
        case .ingredient:
            break
        }
    }
}

     

