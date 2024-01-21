// MealDetailView.swift
// Ratatouille

import SwiftUI

struct MealDetailView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: MealDetailViewModel
    
    /// Init
    init(meals: MealDetails) {
        _viewModel = StateObject(wrappedValue: MealDetailViewModel(meals: meals))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
                    Text(viewModel.meals.strMeal)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    AsyncImageView(url: URL(string: viewModel.meals.strMealThumb))
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                    
                    if let area = viewModel.meals.strArea, let category = viewModel.meals.strCategory {
                        VStack(alignment: .center, spacing: 10) {
                            Text(area)
                                .font(.headline)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accentColor).opacity(0.8))
                                .foregroundColor(.white)
                            
                            Text(category)
                                .font(.headline)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accentColor).opacity(0.8))
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    
                    if !viewModel.meals.strInstructions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Instructions")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            Text(viewModel.meals.strInstructions)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !viewModel.meals.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ingredients")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            ForEach(viewModel.meals.ingredients, id: \.hashValue) { ingredient in
                                Text("• \(ingredient.name): \(ingredient.measurement)")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchDetailedMealInfoIfNeeded(mealName: viewModel.meals.strMeal)
                    } catch {
                        print("Error fetching detailed meal information by name: \(error)")
                    }
                }
            }
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
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
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sampleData)
        
            let decoder = JSONDecoder()
            
            let sampleMealDetails = try decoder.decode(MealDetails.self, from: jsonData)

            return MealDetailView(meals: sampleMealDetails)
                .previewLayout(.sizeThatFits)
                .padding()
        } catch {
            fatalError("Error creating sample meal: \(error)")
        }
    }
}
