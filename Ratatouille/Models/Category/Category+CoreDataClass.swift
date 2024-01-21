//
//  Category+CoreDataClass.swift
//  Ratatouille

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject, Decodable {
    /// Enum codingkeys
    enum CodingKeys: CodingKey {
        case meals
        case strCategory
        case isArchived
    }
    
    /// Init
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meals = try container.decodeIfPresent(String.self, forKey: .meals)
        let strCategory = try container.decodeIfPresent(String.self, forKey: .strCategory)
        let isArchived = try container.decode(Bool.self, forKey: .isArchived)
        
        let dataController = DataController.shared
        let moc = dataController.container.viewContext
        
        super.init(entity: .entity(forEntityName: "Category", in: moc)!, insertInto: moc)
        
        self.meals = meals
        self.strCategory = strCategory
        self.isArchived = isArchived
    }
}

