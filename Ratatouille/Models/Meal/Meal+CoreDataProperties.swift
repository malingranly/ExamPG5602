//
//  Meal+CoreDataProperties.swift
//  Ratatouille

import Foundation
import CoreData

extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var idMeal: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var strArea: String?
    @NSManaged public var strCategory: String?
    @NSManaged public var strInstructions: String?
    @NSManaged public var strMeal: String?
    @NSManaged public var strMealThumb: String?
    @NSManaged public var area: Area?
    @NSManaged public var category: Category?

}

extension Meal : Identifiable {

}

// Setting the default value from awake.
extension Meal {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        isArchived = false
    }
}
