//
//  APIClient.swift
//  Ratatouille

import Foundation
import CoreData

struct APIClient {
    /// Reusable data fetch
    func fetchData<T: Decodable>(from url: URL, as type: T.Type = T.self) async throws -> T {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print("Received response with status code: \(statusCode)")
                
                let rawJSON = String(data: data, encoding: .utf8) ?? ""
                print("Response data: \(rawJSON)")
                
                switch statusCode {
                case 200...299:
                    // OK
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        print("Successfully decoded data")
                        return decodedData
                    } catch {
                        print("Error decoding data: \(error)")
                        throw error
                    }
                    
                case 400...499:
                    // Client error
                    print("Client error with status code: \(statusCode)")
                    throw APIClientError.clientError(statusCode)
                    
                case 500...599:
                    // Server error
                    print("Server error with status code: \(statusCode)")
                    throw APIClientError.serverError
                    
                default:
                    print("Unknown error with status code: \(statusCode)")
                    throw APIClientError.statusCode(statusCode)
                }
            }
            
            print("Unknown error")
            throw APIClientError.unknown
        } catch {
            print("Error fetching data: \(error)")
            throw APIClientError.failed(underlying: error)
        }
    }

    
    /// Core data
    func saveDataToCoreData(areaResponse: AreaResponse, categoryResponse: CategoryResponse, ingredientResponse: IngredientResponse) async {
            let context = DataController.shared.backgroundContext

        Task {
                do {
                    try await saveAreaToCoreData(areaResponse: areaResponse)
                    await saveCategoriesToCoreData(categoryResponse: categoryResponse)
                    await saveIngredientsToCoreData(ingredientResponse: ingredientResponse)

                    try context.save()
                    print("Changes saved successfully")
                } catch {
                    print("Error saving data to Core Data: \(error)")
                }
            }
        }
    
    func saveAreaToCoreData(areaResponse: AreaResponse) async throws {
        let context = DataController.shared.viewContext
        
        await context.perform {
            do {
                let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
                var oldFlagURLs = Set<String>()
                
                do {
                    let areas = try context.fetch(fetchRequest)
                    oldFlagURLs = Set(areas.compactMap { $0.flagURL })
                } catch {
                    
                    print("Error fetching areas to remove old flag URLs: \(error)")
                }
                
                for oldFlagURL in oldFlagURLs {
                    let oldFlagFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
                    oldFlagFetchRequest.predicate = NSPredicate(format: "flagURL == %@", oldFlagURL)
                    
                    do {
                        if let oldFlagArea = try? context.fetch(oldFlagFetchRequest).first {
                            context.delete(oldFlagArea)
                            print("Removed old flag URL: \(oldFlagURL)")
                        }
                    } catch {
                        print("Error removing old flag URL: \(error)")
                    }
                }
            
                for areaDetails in areaResponse.meals {
                    let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "strArea == %@", areaDetails.strArea)

                    if let existingArea = try context.fetch(fetchRequest).first {
                        if context.registeredObject(for: existingArea.objectID) != nil {
                            print("Updating existing area: \(existingArea.strArea ?? "")")
                            if let countryCode = CountryMapping.countryCodes[areaDetails.strArea] {
                                let newFlagURL = "https://flagsapi.com/\(countryCode)/shiny/64.png"
                                print("New flag URL: \(newFlagURL)")
                                
                                existingArea.isArchived = false
                                existingArea.flagURL = newFlagURL
                                existingArea.countryCode = countryCode
                                print("Updated existing area: \(String(describing: existingArea.strArea))")
                            }
                        } else {
                            print("Object already deleted or not found.")
                        }
                    } else {
                        print("Creating new area: \(areaDetails.strArea)")
                        if let countryCode = CountryMapping.countryCodes[areaDetails.strArea] {
                            let newFlagURL = "https://flagsapi.com/\(countryCode)/shiny/64.png"
                            print("New flag URL: \(newFlagURL)")
                            
                            let areaEntity = Area(context: context)
                            areaEntity.strArea = areaDetails.strArea
                            areaEntity.isArchived = false
                            areaEntity.flagURL = newFlagURL
                            areaEntity.countryCode = countryCode
                            print("Created new area: \(String(describing: areaEntity.strArea))")
                        }
                    }
                }
                
                try context.save()
                print("Changes saved successfully")
                
                context.refreshAllObjects()

            } catch {
                print("Error fetching or creating Area: \(error)")
            }
        }
    }

    func saveCategoriesToCoreData(categoryResponse: CategoryResponse) async {
        let context = DataController.shared.viewContext

        await context.perform {
            do {
                let existingCategories = try context.fetch(Category.fetchRequest())

                let existingCategoryNames = Set(existingCategories.compactMap { $0.strCategory })

                for categoryDetails in categoryResponse.meals {
                    let categoryName = categoryDetails.strCategory
                    
                    if existingCategoryNames.contains(categoryName) {
                        print("Updating existing category: \(categoryName)")
                    } else {
                        let newCategory = Category(context: context)
                        newCategory.strCategory = categoryName
                        print("Created new category: \(categoryName)")
                    }
                }
                
                try context.save()
                print("Categories saved successfully")
            } catch {
                print("Error saving categories to Core Data: \(error)")
            }
        }
    }

    func saveIngredientsToCoreData(ingredientResponse: IngredientResponse) async {
        let context = DataController.shared.viewContext

        await context.perform {
            do {
                let existingIngredients = try context.fetch(Ingredient.fetchRequest())

                let existingIngredientNames = Set(existingIngredients.compactMap { $0.strIngredient })

                for ingredientDetails in ingredientResponse.meals {
                    let ingredientName = ingredientDetails.strIngredient

                    if existingIngredientNames.contains(ingredientName ?? "") {
                        print("Updating existing ingredient: \(String(describing: ingredientName))")
                    } else {
                        let newIngredient = Ingredient(context: context)
                        newIngredient.strIngredient = ingredientName
                        newIngredient.strDescription = ingredientDetails.strDescription
                        newIngredient.idIngredient = ingredientDetails.idIngredient
                        print("Created new ingredient: \(String(describing: ingredientName))")
                    }
                }

                try context.save()
                print("Ingredients saved successfully")
            } catch {
                print("Error saving ingredients to Core Data: \(error)")
            }
        }
    }

    func updateFlagURLInCoreData(area: Area, flagData: Data, countryCode: String) async throws {
        let context = DataController.shared.backgroundContext

        try await context.perform {
            area.flagURL = "https://flagsapi.com/\(countryCode)/shiny/64.png"
            print("Flag image for \(String(describing: area.strArea))")
            print("Flag URL for \(String(describing: area.strArea)): \(area.flagURL ?? "No URL")")

            try context.save()
        }
    }
    
    func saveMealToCoreData(meal: MealDetails, area: Area?, category: Category?) async throws {
        let context = DataController.shared.backgroundContext

        Task{
            if let existingMeal = fetchMealFromCoreData(with: meal.idMeal, in: context) {
                existingMeal.area = nil
                existingMeal.category = nil
                existingMeal.strMeal = meal.strMeal
                existingMeal.strCategory = meal.strCategory
                existingMeal.strInstructions = meal.strInstructions
                existingMeal.strMealThumb = meal.strMealThumb
                existingMeal.isArchived = false
                
                if let areaName = area?.strArea,
                   let existingArea = fetchAreaFromCoreData(with: areaName, in: context) {
                    existingMeal.area = existingArea
                } else {
                    let newArea = Area(context: context)
                    newArea.strArea = area?.strArea
                    existingMeal.area = newArea
                }
                
                if let categoryName = category?.strCategory,
                   let existingCategory = fetchCategoryFromCoreData(with: categoryName, in: context) {
                    existingMeal.category = existingCategory
                } else {
                    let newCategory = Category(context: context)
                    newCategory.strCategory = category?.strCategory
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
                newMeal.idMeal = meal.idMeal
                newMeal.strMeal = meal.strMeal
                newMeal.strCategory = meal.strCategory
                newMeal.strInstructions = meal.strInstructions
                newMeal.strMealThumb = meal.strMealThumb
                newMeal.isArchived = false
                
                if let areaName = area?.strArea,
                   let existingArea = fetchAreaFromCoreData(with: areaName, in: context) {
                    newMeal.area = existingArea
                } else {
                    let newArea = Area(context: context)
                    newArea.strArea = area?.strArea
                    newMeal.area = newArea
                }
                
                if let categoryName = category?.strCategory,
                   let existingCategory = fetchCategoryFromCoreData(with: categoryName, in: context) {
                    newMeal.category = existingCategory
                } else {
                    let newCategory = Category(context: context)
                    newCategory.strCategory = category?.strCategory
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
    
    ///
    func saveChanges() async {
        do {
            try DataController.shared.backgroundContext.save()
        } catch {
            handleConflict(error)
        }
    }
    
    func handleConflict(_ error: Error) {
        DataController.shared.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
            try DataController.shared.backgroundContext.save()
        } catch {
      
        }
    }
    
    /// Fetching
    func fetchMealFromCoreData(with idMeal: String, in context: NSManagedObjectContext) -> Meal? {
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idMeal == %@", idMeal)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching meal from Core Data: \(error)")
            return nil
        }
    }

    func fetchAreaFromCoreData(with name: String, in context: NSManagedObjectContext) -> Area? {
        let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "strArea == %@", name)
        
        do {
            let areas = try context.fetch(fetchRequest)
            return areas.first
        } catch {
            print("Error fetching area from Core Data: \(error)")
            return nil
        }
    }

    func fetchCategoryFromCoreData(with name: String, in context: NSManagedObjectContext) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "strCategory == %@", name)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Error fetching category from Core Data: \(error)")
            return nil
        }
    }
    
    /// Filtering and search
    func filterMealsByArea(area: String) async throws -> MealResponse? {
            let filterURLString = "https://www.themealdb.com/api/json/v1/1/filter.php?a=" + area
            guard let url = URL(string: filterURLString) else {
                print("Invalid filterURL for area")
                throw APIClientError.unknown
            }
            
            print("Filtering meals by \(area)")
            return try await fetchData(from: url, as: MealResponse.self)
        }

    func filterMealsByCategory(category: String) async throws -> MealResponse {
        let filterURLString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=" + category
        guard let url = URL(string: filterURLString) else {
            print("Invalid filterURL for category")
            throw APIClientError.unknown
        }
        
        print("Filtering meals by \(category)")
        return try await fetchData(from: url, as: MealResponse.self)
    }

    func filterMealsByIngredient(ingredient: String) async throws -> MealResponse {
        let filterURLString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=" + ingredient
        guard let url = URL(string: filterURLString) else {
            print("Invalid filterURL for ingredient")
            throw APIClientError.unknown
        }
        
        print("Filtering meals by \(ingredient)")
        return try await fetchData(from: url, as: MealResponse.self)
    }
    
    func searchMealByName(name: String) async throws -> MealResponse {
        let searchURLString = "https://www.themealdb.com/api/json/v1/1/search.php?s=" + name
        guard let url = URL(string: searchURLString) else {
            print("Invalid search URL")
            
            throw APIClientError.unknown
        }

        print("Searching meal by name: \(name)")

        do {
            let response: MealResponse = try await fetchData(from: url)
            print("API Response: \(response)")
            
            guard let meals = response.meals, !meals.isEmpty else {
                let rawJSON = String(data: try JSONEncoder().encode(response), encoding: .utf8) ?? ""
                print("Invalid or missing 'meals' property in the response.")
                print("Response data: \(rawJSON)")
                throw APIClientError.invalidResponse
            }

            guard let firstMeal = meals.first else {
                print("No meals found.")
                throw APIClientError.noData
            }

            print("First meal details: \(firstMeal)")

            return response
        } catch {
            print("Error fetching data: \(error)")
            throw error
        }
    }
    
    /// Get functions
    func getMealDetailsById(id: String) async throws -> MealDetails {
            let detailsURLString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" + id
            guard let url = URL(string: detailsURLString) else {
                print("Invalid detailsURL for meal ID: \(id)")
                throw APIClientError.unknown
            }

            print("Fetching details for meal ID: \(id)")

            do {
                let mealDetails = try await fetchData(from: url, as: MealResponse.self)
            
                if let meal = mealDetails.meals?.first {
                    return MealDetails(
                        idMeal: meal.idMeal,
                        strMeal: meal.strMeal,
                        strArea: meal.strArea,
                        strCategory: meal.strCategory ?? "",
                        strInstructions: meal.strInstructions,
                        strMealThumb: meal.strMealThumb,
                        ingredients: []
                    )
                } else {
                    throw APIClientError.invalidResponse
                }
            } catch {
                print("Error fetching meal details for ID \(id): \(error)")
                throw error
            }
        }
     
    func getArea() async throws -> AreaResponse {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/list.php?a=list")!
        print("Fetching area list from URL: \(url)")

        let areaResponse = try await fetchData(from: url, as: AreaResponse.self)

        try await saveAreaToCoreData(areaResponse: areaResponse)

        return areaResponse
    }
    
    func getCategory() async throws -> CategoryResponse {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/list.php?c=list")!
        print("Fetching category list from URL: \(url)")
        return try await fetchData(from: url)
    }
    
    func getIngredient() async throws -> IngredientResponse {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/list.php?i=list")!
        print("Fetching ingredient list from URL: \(url)")
        return try await fetchData(from: url)
    }
    
    func getFlag(countryCode: String) async throws -> Data {
        let uppercasedCountryCode = countryCode.uppercased()
        let flagURL = URL(string: "https://flagsapi.com/\(uppercasedCountryCode)/shiny/64.png")!
        print("Fetching flag for country code \(uppercasedCountryCode) from URL: \(flagURL)")
        return try await URLSession.shared.data(from: flagURL).0
    }

    func decodeMealDetails(data: Data) throws -> MealDetails {
        do {
            var mealDetails = try JSONDecoder().decode(MealDetails.self, from: data)
            
            if let mealsArray = try? JSONDecoder().decode([MealIngredientDetails].self, from: data) {
                mealDetails.ingredients = mealsArray
            }
            print("Successfully decoded meal details")
            return mealDetails
        } catch {
            print("Error decoding meal details: \(error)")
            throw error
        }
    }
}

/// Custom error
enum APIClientError: Error {
    case failed(underlying: Error)
    case statusCode(Int)
    case clientError(Int)
    case serverError
    case unknown
    case invalidData
    case decodingError(Error)
    case invalidResponse
    case noData
    case invalidURL
    
    init(statusCode: Int) {
        self = .statusCode(statusCode)
        
        if (400...499).contains(statusCode) {
            self = .clientError(statusCode)
        } else if (500...599).contains(statusCode) {
            self = .serverError
        }
    }
}
