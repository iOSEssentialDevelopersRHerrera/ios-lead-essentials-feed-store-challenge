//
//  CoreDataFeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Ricardo Herrera Petit on 1/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataFeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFeedImage> {
        return NSFetchRequest<CoreDataFeedImage>(entityName: "CoreDataFeedImage")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var image_desc: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL?

}

extension CoreDataFeedImage : Identifiable {

}
