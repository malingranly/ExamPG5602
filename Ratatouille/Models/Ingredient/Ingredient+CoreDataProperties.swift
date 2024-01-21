//
//  Ingredient+CoreDataProperties.swift
//  Ratatouille

import Foundation
import CoreData

extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var meals: String?
    @NSManaged public var idIngredient: String?
    @NSManaged public var strDescription: String?
    @NSManaged public var strIngredient: String?
    @NSManaged public var isArchived: Bool

}

extension Ingredient : Identifiable {

}

// Setting the default value from awake.
extension Ingredient {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        isArchived = false
    }
}
