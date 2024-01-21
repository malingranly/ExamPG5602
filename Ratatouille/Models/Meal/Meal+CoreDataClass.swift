//
//  Meal+CoreDataClass.swift
//  Ratatouille

import Foundation
import CoreData

@objc(Meal)
public class Meal: NSManagedObject, Decodable {
    /// Enum codingkeys
    enum CodingKeys: CodingKey {
        case idMeal
        case strMeal
        case strArea
        case strCategory
        case strInstructions
        case strMealThumb
        case isArchived
        case ingredients
    }
    
    /// Init
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let idMeal = try container.decodeIfPresent(String.self, forKey: .idMeal)
            let strMeal = try container.decodeIfPresent(String.self, forKey: .strMeal)
            let strArea = try container.decodeIfPresent(String.self, forKey: .strArea)
            let strCategory = try container.decodeIfPresent(String.self, forKey: .strCategory)
            let strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)
            let strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
            let isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived)
            
            let dataController = DataController.shared
            let moc = dataController.container.viewContext
            
            super.init(entity: .entity(forEntityName: "Meal", in: moc)!, insertInto: moc)
            
            self.idMeal = idMeal 
            self.strMeal = strMeal
            self.strArea = strArea
            self.strCategory = strCategory
            self.strInstructions = strInstructions
            self.strMealThumb = strMealThumb
            self.isArchived = isArchived ?? false
        }
}
