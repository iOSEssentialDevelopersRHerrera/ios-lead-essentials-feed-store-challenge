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

extension CoreDataFeed {
	public static func feed(_ context: NSManagedObjectContext) throws -> CoreDataFeed? {
		let fetchRequest = NSFetchRequest<CoreDataFeed>(entityName: Constants.CORE_DATA_FEED_MODEL_NAME)
		return try context.fetch(fetchRequest).first
	}
	
	public var localFeed:[LocalFeedImage] {
		return images.compactMap { ($0 as? CoreDataFeedImage)?.local }
	}
	
	
}
