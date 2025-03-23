//
//  Purchase+CoreDataProperties.swift
//  FinalProject
//
//  Created by 吳育臻 on 2025/3/20.
//
//

import Foundation
import CoreData


extension Purchase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purchase> {
        return NSFetchRequest<Purchase>(entityName: "Purchase")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var price: String?
    @NSManaged public var purchaseDate: Date?

}

extension Purchase : Identifiable {

}
