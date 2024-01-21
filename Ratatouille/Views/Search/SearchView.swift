//
//  ContentView.swift
//  Ratatouille

import SwiftUI
import CoreData

struct SearchView: View {
    /// Variables
    @State private var mealsResponse: MealResponse?
    @State private var areaResponse: AreaResponse?
    @State private var categoryResponse: CategoryResponse?
    @State private var ingredientResponse: IngredientResponse?
    @State private var searchText: String = ""
    @State private var selectedSearchType: SearchType = .meal
    @State private var isEditing = false
    @State private var selectedItems: Set<String> = []
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State var meals: [MealDetails] = []

    /// Enum
    enum SearchType: String, CaseIterable {
        case meal
        case area
        case category
        case ingredient
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Search Type", selection: $selectedSearchType) {
                    ForEach(SearchType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                    .cornerRadius(12)
                    .padding(.vertical, 10)
                    .onChange(of: searchText) { _ in
                        Task {
                            await search()
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                MealListView(meals: mealsResponse?.meals ?? [])
                    .onAppear {
                        print("MealListView Appear: \(mealsResponse?.meals ?? [])")
                    }
            }
            .environmentObject(FavoritesViewModel())
            .navigationTitle("Søk")
            .onAppear {
                Task {
                    await fetchAndSaveData()
                }
            }
        }
    }
    
    /// Search switch-case
    private func search() async {
        do {
            switch selectedSearchType {
            case .meal:
                await searchMeal()
            case .area:
                try await searchMealsByArea(area: searchText)
            case .category:
                try await searchMealsByCategory(category: searchText)
            case .ingredient:
                try await searchMealsByIngredient(ingredient: searchText)
            }
        } catch {
            print("Search error: \(error)")
        }
    }

    /// Search functions
    private func searchMealsByArea(area: String) async throws {
        do {
            let filteredMeals = try await APIClient().filterMealsByArea(area: area)

            guard let mealsArray = filteredMeals?.meals else {
                return
            }

            let decodedMeals = mealsArray.map { dictionary in
                MealDetails(
                    idMeal: dictionary.idMeal ,
                    strMeal: dictionary.strMeal ,
                    strArea: dictionary.strArea,
                    strCategory: dictionary.strCategory ?? "",
                    strInstructions: dictionary.strInstructions ,
                    strMealThumb: dictionary.strMealThumb ,
                    ingredients: []
                )
            }
            self.mealsResponse = MealResponse(meals: decodedMeals)
            updateMealDetails()
        } catch {
            print("Error searching meals by area: \(error)")
        }
    }

    private func searchMealsByCategory(category: String) async throws {
        do {
            let mutableSearchResults = try await APIClient().filterMealsByCategory(category: category)
            self.mealsResponse = mutableSearchResults

            if var meals = self.mealsResponse?.meals {
                try await updateMealDetails(for: &meals)
                let updatedMealResponse = MealResponse(meals: meals)
                self.mealsResponse = updatedMealResponse
            }
        } catch {
            print("Error searching meals by category: \(error)")
        }
    }

    private func searchMealsByIngredient(ingredient: String) async throws {
        do {
            let mutableSearchResults = try await APIClient().filterMealsByIngredient(ingredient: ingredient)
            self.mealsResponse = mutableSearchResults

            if var meals = self.mealsResponse?.meals {
                try await updateMealDetails(for: &meals)
                let updatedMealResponse = MealResponse(meals: meals)
                self.mealsResponse = updatedMealResponse
            }
        } catch {
            print("Error searching meals by ingredient: \(error)")
        }
    }

    private func searchMeal() async {
        do {
            let mutableSearchResults = try await APIClient().searchMealByName(name: searchText)
            self.mealsResponse = mutableSearchResults

            if var meals = self.mealsResponse?.meals {
                try await updateMealDetails(for: &meals)
                let updatedMealResponse = MealResponse(meals: meals)
                self.mealsResponse = updatedMealResponse
                
                print("Meals Searched by Name: \(meals)")
                self.meals = meals
                print("SearchView meals array after updating: \(meals)")
                print("MealListView Appear: \(meals)")
                self.meals = meals
            }
        } catch {
            print("Error searching meals by name: \(error)")
            if let apiError = error as? APIClientError {
                print("API Error: \(apiError)")
            }
        }
    }
    
    /// Updating, convertion and fetching
    private func updateMealDetails() {
        guard var meals = self.mealsResponse?.meals else { return }

        for index in meals.indices {
            do {
                let mealDetails = try APIClient().decodeMealDetails(data: try JSONEncoder().encode(meals[index]))

                if meals[index].ingredients.isEmpty {
                    meals[index].ingredients = mealDetails.ingredients
                }
            } catch {
                print("Error decoding meal details: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.mealsResponse?.meals = meals
        }
    }

    private func updateMealDetails(for meals: inout [MealDetails]) async throws {
        let mealNames = Set(meals.map { $0.strMeal })

        for mealName in mealNames {
            do {
                let detailedMeal = try await APIClient().searchMealByName(name: mealName)
                if let detailedMealInfo = detailedMeal.meals?.first {
                    
                    if let index = meals.firstIndex(where: { $0.strMeal == mealName }) {
                        meals[index].strArea = detailedMealInfo.strArea
                        meals[index].strCategory = detailedMealInfo.strCategory
                        meals[index].strInstructions = detailedMealInfo.strInstructions
                        meals[index].ingredients = detailedMealInfo.ingredients
                    }
                } else {
                    print("Error: Detailed meal information not found for meal '\(mealName)'")
                }
            } catch {
                print("Error fetching detailed meal information by name: \(error)")
            }
        }
    }
    
    private func convertToMealDetails(details: [Any]) -> [MealDetails] {
        var mealDetailsArray: [MealDetails] = []

        for detail in details {
            if let detailDictionary = detail as? [String: Any] {
                if let idMeal = detailDictionary["idMeal"] as? String,
                   let strMeal = detailDictionary["strMeal"] as? String,
                   let strArea = detailDictionary["strArea"] as? String,
                   let strCategory = detailDictionary["strCategory"] as? String,
                   let strInstructions = detailDictionary["strInstructions"] as? String,
                   let strMealThumb = detailDictionary["strMealThumb"] as? String {

                    let ingredients = detailDictionary["ingredients"] as? [String] ?? []

                    let mealIngredients = ingredients.map { MealIngredientDetails(name: $0, measurement: "some default measurement") }

                    let mealDetails = MealDetails(
                        idMeal: idMeal,
                        strMeal: strMeal,
                        strArea: strArea,
                        strCategory: strCategory,
                        strInstructions: strInstructions,
                        strMealThumb: strMealThumb,
                        ingredients: mealIngredients
                    )
                    mealDetailsArray.append(mealDetails)
                }
            }
        }

        return mealDetailsArray
    }

    private func fetchAndSaveData() async {
        do {
            let areasResponse = try await APIClient().getArea()
            try await APIClient().saveAreaToCoreData(areaResponse: areasResponse)
            self.areaResponse = areasResponse

            let categoriesResponse = try await APIClient().getCategory()
            let ingredientsResponse = try await APIClient().getIngredient()

            self.categoryResponse = categoriesResponse
            self.ingredientResponse = ingredientsResponse

            await APIClient().saveCategoriesToCoreData(categoryResponse: categoriesResponse)
            await APIClient().saveIngredientsToCoreData(ingredientResponse: ingredientsResponse)
        } catch {
            print("Error fetching and saving data: \(error)")
        }
    }

}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
