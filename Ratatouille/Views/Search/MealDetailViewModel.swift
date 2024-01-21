//
//  MealDetailViewModel.swift
//  Ratatouille

import Foundation
import SwiftUI

class MealDetailViewModel: ObservableObject {
    /// Variables
    @Published var meals: MealDetails
    
    /// Init
    init(meals: MealDetails) {
        self.meals = meals
    }
    
    func fetchDetailedMealInfoIfNeeded(mealName: String) async throws {
        if meals.strArea == nil || meals.strCategory == nil || meals.strInstructions.isEmpty || meals.ingredients.isEmpty || meals.ingredients.contains(where: { $0.name.isEmpty || $0.measurement.isEmpty }) {
            do {
                let encodedName = mealName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let searchURLString = "https://www.themealdb.com/api/json/v1/1/search.php?s=" + encodedName

                guard let url = URL(string: searchURLString) else {
                    return
                }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let detailedMeal = try JSONDecoder().decode(MealResponse.self, from: data)

                    if let detailedMealInfo = detailedMeal.meals?.first {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.meals.strArea = detailedMealInfo.strArea
                                self.meals.strCategory = detailedMealInfo.strCategory
                                self.meals.strInstructions = detailedMealInfo.strInstructions
                                self.meals.ingredients = detailedMealInfo.ingredients
                            }
                        }
                    } else {
                        print("Error: Detailed meal information not found")
                    }
                } catch {
                    print("Error fetching data: \(error)")
                    throw error
                }
            } catch {
                print("Error fetching detailed meal information by name: \(error)")
            }
        }
    }
    
    func fetchMealFromCoreData(with idMeal: String) -> Meal? {
        let apiClient = APIClient()
        return apiClient.fetchMealFromCoreData(with: idMeal, in: DataController.shared.backgroundContext)
    }

    
    func saveToCoreData(area: Area?, category: Category?) async throws {
            let context = DataController.shared.backgroundContext

        if let existingMeal = fetchMealFromCoreData(with: meals.idMeal) {
                existingMeal.area = nil
                existingMeal.category = nil
                existingMeal.strMeal = meals.strMeal
                existingMeal.strCategory = meals.strCategory
                existingMeal.strInstructions = meals.strInstructions
                existingMeal.strMealThumb = meals.strMealThumb
                existingMeal.isArchived = false

                if let existingArea = area {
                    existingMeal.area = existingArea
                } else {
                    let newArea = Area(context: context)
                    newArea.strArea = meals.strArea
                    existingMeal.area = newArea
                }

                if let existingCategory = category {
                    existingMeal.category = existingCategory
                } else {
                    let newCategory = Category(context: context)
                    newCategory.strCategory = meals.strCategory
                    existingMeal.category = newCategory
                }

                do {
                    try context.save()
                    context.delete(existingMeal)
                    try context.save()
                    print("Meal updated and deleted in Core Data successfully.")
                } catch {
                    print("Error updating meal and deleting in Core Data: \(error)")
                }
            } else {
                let newMeal = Meal(context: context)
                newMeal.idMeal = meals.idMeal
                newMeal.strMeal = meals.strMeal
                newMeal.strCategory = meals.strCategory
                newMeal.strInstructions = meals.strInstructions
                newMeal.strMealThumb = meals.strMealThumb
                newMeal.isArchived = false

                if let existingArea = area {
                    newMeal.area = existingArea
                } else {
                    let newArea = Area(context: context)
                    newArea.strArea = meals.strArea
                    newMeal.area = newArea
                }

                if let existingCategory = category {
                    newMeal.category = existingCategory
                } else {
                    let newCategory = Category(context: context)
                    newCategory.strCategory = meals.strCategory
                    newMeal.category = newCategory
                }

                do {
                    try context.save()
                    print("Meal saved to Core Data successfully.")
                } catch {
                    print("Error saving meal to Core Data: \(error)")
                }
                DataController.shared.save()
            }
        }
    }


