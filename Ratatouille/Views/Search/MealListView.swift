//
//  MealListView.swift
//  Ratatouille

import SwiftUI
import CoreData

struct MealListView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var dataController = DataController.shared
    var meals: [MealDetails]
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @State private var mealsResponse: MealResponse?

    var body: some View {
        List {
            ForEach(meals, id: \.idMeal) { meal in
                    NavigationLink(destination: MealDetailView(meals: meal)) {
                        HStack {
                            AsyncImageView(url: URL(string: meal.strMealThumb ))
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(meal.strMeal)
                                    .font(.title)
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                Text(meal.strCategory ?? "Unknown Category")
                            }
                            .padding()
                        }
                        .padding(.bottom)
                    }
                    .cornerRadius(10)
                    .swipeActions {
                        Button {
                            Task {
                                do {
                                    try await dataController.updateMealArchivedStatus(mealID: meal.idMeal, isArchived: true)
                                    print("Archiving meal with idMeal: \(meal.idMeal)")
                                } catch {
                                    print("Error archiving meal: \(error)")
                                }
                            }
                        } label: {
                            Image(systemName: "archivebox")
                        }
                        .tint(.blue)

                        Button {
                            Task {
                                do {
                                    print("strArea: \(String(describing: meal.strArea)), strCategory: \(String(describing: meal.strCategory))")
                                    
                                    if let strArea = meal.strArea, !strArea.isEmpty,
                                        let strCategory = meal.strCategory, !strCategory.isEmpty,
                                        let area = try await dataController.fetchAreaByStrArea(strArea: strArea),
                                        let category = try await dataController.fetchCategoryByStrCategory(strCategory: strCategory) {

                                        try await APIClient().saveMealToCoreData(meal: meal, area: area, category: category)
                                        print("Saving meal with idMeal: \(meal.idMeal)")
                                    } else {
                                        print("Area or category not found for strArea: \(String(describing: meal.strArea)), strCategory: \(String(describing: meal.strCategory))")
                                    }
                                } catch {
                                    print("Error fetching area or category, or saving meal: \(error)")
                                }
                            }
                        } label: {
                            Image(systemName: "heart")
                        }
                        .tint(.red)
                    }
            }
            
        }
        .onAppear {
            print("Meals in MealListView: \(meals)")
        }
        .onChange(of: meals) { newMeals in
            print("Meals changed: \(newMeals)")
        }
        .listStyle(.plain)
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [String: Any] = [
            "idMeal": "1",
            "strMeal": "Test Meal",
            "strArea": "Area",
            "strCategory": "Category",
            "strInstructions": "Instructions",
            "strMealThumb": "URL",
            "ingredients": [
                ["name": "Ingredient1", "measurement": "Measurement1"],
                ["name": "Ingredient2", "measurement": "Measurement2"]
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: sampleData)
        
        let decoder = JSONDecoder()
        
        let sampleMealDetails = try! decoder.decode(MealDetails.self, from: jsonData)
        
        MealListView(meals: [sampleMealDetails])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
