//
//  IngredientResponse.swift
//  Ratatouille

import Foundation
 
struct IngredientResponse: Codable {
    let meals: [IngredientDetails]
}

struct IngredientDetails: Codable {
    let idIngredient: String?
    let strIngredient: String?
    let strDescription: String?
}




