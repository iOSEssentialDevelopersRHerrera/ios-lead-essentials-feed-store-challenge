//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Ricardo Herrera Petit on 1/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	private var storeContainer: NSPersistentContainer
	private let managedContext: NSManagedObjectContext
	
	public init(url: URL, in bundle: Bundle) throws {
		storeContainer =  try CoreDataFeedStore.createManagedContainer(url, in: bundle)
		managedContext = storeContainer.newBackgroundContext()
	}
	
	static func managedObjectModel(bundle:Bundle) throws -> NSManagedObjectModel {
		guard let model = bundle.url(forResource: Constants.CORE_DATA_FEED_MODEL_NAME, withExtension: "momd").flatMap({ (url) in
			NSManagedObjectModel(contentsOf: url)
		}) else {
			throw LoadingError.modelNotFound
		}
		
		return model
	}
	
	static func createManagedContainer(_ url:URL, in bundle:Bundle) throws -> NSPersistentContainer {
		let description = NSPersistentStoreDescription(url: url)
		
		
		let storeContainer = NSPersistentContainer(name: Constants.CORE_DATA_FEED_MODEL_NAME, managedObjectModel: try CoreDataFeedStore.managedObjectModel(bundle: bundle))
		
		storeContainer.persistentStoreDescriptions = [description]
		
		var loadError: Swift.Error?
		storeContainer.loadPersistentStores { (storeDescription, error) in
			if let error = error {
				loadError = error
			}
		}
		
		try loadError.map {
			throw LoadingError.failedToLoadPersistentStores($0)
		}
		
		return storeContainer
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = managedContext
		context.perform {
			do {
				if let coreDataFeed = try CoreDataFeed.feed(context) {
					context.delete(coreDataFeed)
					try context.save()
				}
				completion(.none)
			} catch {
				completion(.some(error))
			}
		}
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = managedContext
		context.perform {
			do {
				if let coreDataFeed = try CoreDataFeed.feed(context) {
					context.delete(coreDataFeed)
				}
				self.insert(feed, timestamp: timestamp)
				try context.save()
			} catch {
				completion(.some(error))
			}
		
			completion(.none)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = managedContext
		context.perform {
			do {
				if let dataFeed = try CoreDataFeed.feed(context) {
					let imageFeed = dataFeed.localFeed
					completion(.found(feed: imageFeed, timestamp: dataFeed.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
		
	}
	
	// MARK: Helper Methods
	
	private func insert(_ feed:[LocalFeedImage], timestamp:Date) {
		var images: [CoreDataFeedImage] = []
		
		for image in feed {
			
			let cdImage = CoreDataFeedImage(context: managedContext)
			
			cdImage.id = image.id
			cdImage.url = image.url
			cdImage.image_desc = image.description
			cdImage.location = image.location
			
			images.append(cdImage)
		}
		
		let imageSet = NSOrderedSet(array: images)
		let cdFeed = CoreDataFeed(context: managedContext)
		
		cdFeed.images = imageSet
		cdFeed.timestamp = timestamp
	}
	
}
