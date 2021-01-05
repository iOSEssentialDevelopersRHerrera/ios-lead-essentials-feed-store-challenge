//
//  CoreDataFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Ricardo Herrera Petit on 1/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataFeedImage)
internal class CoreDataFeedImage: NSManagedObject {
	@NSManaged internal var image_desc: String?
	@NSManaged internal var location: String?
	@NSManaged internal var id: UUID
	@NSManaged internal var url: URL
	@NSManaged internal var feed: CoreDataFeed
	
	var local: LocalFeedImage {
		return LocalFeedImage(id: id,
							  description: image_desc,
							  location: location,
							  url: url)
	}
}
