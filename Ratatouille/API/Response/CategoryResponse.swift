//
//  CategoryResponse.swift
//  Ratatouille

import Foundation

struct CategoryResponse: Codable {
    let meals: [CategoryDetails]
}

struct CategoryDetails: Codable {
    let strCategory: String
    let meals: [MealDetails]?
}

