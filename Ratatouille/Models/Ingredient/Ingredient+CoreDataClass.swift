//
//  Ingredient+CoreDataClass.swift
//  Ratatouille

import Foundation
import CoreData

@objc(Ingredient)
public class Ingredient: NSManagedObject, Decodable {
    // Enum codingkeys
    enum Codingkeys: CodingKey {
        case meals
        case idIngredient
        case strIngredient
        case strDescription
        case isArchived
    }
    
    /// Init
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkeys.self)
        let meals = try container.decodeIfPresent(String.self, forKey: .meals)
        let idIngredient = try container.decodeIfPresent(String.self, forKey: .idIngredient)
        let strIngredient = try container.decodeIfPresent(String.self, forKey: .strIngredient)
        let strDescription = try container.decodeIfPresent(String.self, forKey: .strDescription)
        let isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false

        let dataController = DataController.shared
        let moc = dataController.container.viewContext
        
        super.init(entity: .entity(forEntityName: "Ingredient", in: moc)!, insertInto: moc)
        
        self.meals = meals
        self.idIngredient = idIngredient
        self.strIngredient = strIngredient
        self.strDescription = strDescription
        self.isArchived = isArchived 
    }
    
}
