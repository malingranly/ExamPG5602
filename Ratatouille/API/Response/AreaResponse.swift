//
//  AreaResponse.swift
//  Ratatouille

import Foundation

struct AreaResponse: Codable {
    let meals: [AreaDetails]
}

struct AreaDetails: Codable {
    let strArea: String
    let meals: [MealDetails]?
}
