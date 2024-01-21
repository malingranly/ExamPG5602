//
//  MealResponse.swift
//  Ratatouille

import Foundation

struct MealResponse: Codable {
    var meals: [MealDetails]?
}

struct MealDetails: Codable, Identifiable, Hashable, Equatable {
    let idMeal: String
    var strMeal: String
    var strArea: String?
    var strCategory: String?
    var strInstructions: String
    var strMealThumb: String
    var ingredients: [MealIngredientDetails]
    
    var id: String {
        return idMeal
    }
    
    init(idMeal: String, strMeal: String, strArea: String?, strCategory: String, strInstructions: String, strMealThumb: String, ingredients: [MealIngredientDetails]) {
            self.idMeal = idMeal
            self.strMeal = strMeal
            self.strArea = strArea
            self.strCategory = strCategory
            self.strInstructions = strInstructions
            self.strMealThumb = strMealThumb
            self.ingredients = ingredients
        }
    
    enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strInstructions, strMealThumb
        case strArea, strCategory
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15, strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15, strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strArea = try container.decodeIfPresent(String.self, forKey: .strArea) ?? ""
        strCategory = try container.decodeIfPresent(String.self, forKey: .strCategory) ?? ""
        strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions) ?? ""
        strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb) ?? ""

        // Extract ingredients dynamically
        ingredients = try (1...20).compactMap { index in
            guard let ingredientNameKey = CodingKeys(stringValue: "strIngredient" + String(index)),
                  let ingredientMeasurementKey = CodingKeys(stringValue: "strMeasure" + String(index))
            else {
                // If either key is missing, skip this iteration
                return nil
            }

            if let name = try? container.decodeIfPresent(String.self, forKey: ingredientNameKey),
               !name.isEmpty,
               let measurement = try? container.decodeIfPresent(String.self, forKey: ingredientMeasurementKey),
               !measurement.isEmpty
            {
                print("\(ingredientNameKey.stringValue): Name - \(name), Measurement - \(measurement)")
                return MealIngredientDetails(name: name, measurement: measurement)
            } else {
                print("\(ingredientNameKey.stringValue): Empty or decoding failed")
                return nil
            }
        }
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idMeal, forKey: .idMeal)
        try container.encode(strMeal, forKey: .strMeal)
        try container.encode(strArea, forKey: .strArea)
        try container.encode(strCategory, forKey: .strCategory)
        try container.encode(strInstructions, forKey: .strInstructions)
        try container.encode(strMealThumb, forKey: .strMealThumb)
        
        for (index, ingredient) in ingredients.enumerated() {
            try container.encode(ingredient, forKey: .init(stringValue: "strIngredient\(index + 1)")!)
        }
    }
    
    static func == (lhs: MealDetails, rhs: MealDetails) -> Bool {
            return lhs.idMeal == rhs.idMeal
        }
    
  
    
}

