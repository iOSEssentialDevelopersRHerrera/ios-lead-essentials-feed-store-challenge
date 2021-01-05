//
//  CoreDataFeed.swift
//  FeedStoreChallenge
//
//  Created by Ricardo Herrera Petit on 1/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataFeed)
internal class CoreDataFeed: NSManagedObject {
	@NSManaged internal var timestamp: Date
	@NSManaged internal var images: NSOrderedSet
}
