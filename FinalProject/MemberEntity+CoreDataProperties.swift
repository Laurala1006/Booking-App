//
//  MemberEntity+CoreDataProperties.swift
//  FinalProject
//
//  Created by 吳育臻 on 2025/3/21.
//
//

import Foundation
import CoreData


extension MemberEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemberEntity> {
        return NSFetchRequest<MemberEntity>(entityName: "MemberEntity")
    }

    @NSManaged public var account: String?
    @NSManaged public var age: Int32
    @NSManaged public var birthday: Date?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var profileImagePath: String?
    @NSManaged public var timestamp: Date?

}

extension MemberEntity : Identifiable {

}
