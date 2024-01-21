//
//  Area+CoreDataClass.swift
//  Ratatouille

import Foundation
import CoreData

@objc(Area)
public class Area: NSManagedObject, Decodable {
    /// Enum codingkeys
    enum CodingKeys: CodingKey {
        case meals
        case strArea
        case isArchived
        case flagURL
        case countryCode
    }
    
    /// Init
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mealsArray = try container.decodeIfPresent([AreaDetails].self, forKey: .meals)
        let strArea = try container.decodeIfPresent(String.self, forKey: .strArea)
        let isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived)
        let flagURL = try container.decodeIfPresent(String.self, forKey: .flagURL)
        let countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        
        let dataController = DataController.shared
        let moc = dataController.container.viewContext

        super.init(entity: .entity(forEntityName: "Area", in: moc)!, insertInto: moc)

        if let mealsArray = mealsArray {
            for mealDetails in mealsArray {
                if let entity = NSEntityDescription.entity(forEntityName: "Meal", in: moc),
                    let mealObject = NSManagedObject(entity: entity, insertInto: moc) as? Meal {
                    mealObject.strArea = mealDetails.strArea
                    mealObject.area = self
                }
            }

            self.strArea = strArea
            self.isArchived = isArchived ?? false
            self.flagURL = flagURL
            self.countryCode = countryCode
       
        }
    }
}
