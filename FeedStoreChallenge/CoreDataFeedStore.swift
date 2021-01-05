//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Ricardo Herrera Petit on 1/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore:FeedStore {
	
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	private let storeContainer: NSPersistentContainer
	private let managedContext: NSManagedObjectContext
	
	public init(modelName name: String, url: URL, in bundle: Bundle) throws {
		
		guard let model = bundle.url(forResource: name, withExtension: "momd").flatMap({ (url) in
			NSManagedObjectModel(contentsOf: url)
		}) else {
			throw LoadingError.modelNotFound
		}
		
		let description = NSPersistentStoreDescription(url: url)
		
		storeContainer = NSPersistentContainer(name: name, managedObjectModel: model)
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
		
		managedContext = storeContainer.newBackgroundContext()
	}
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(.none)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		if let coreDataFeed = getFetchedRequest() {
			managedContext.delete(coreDataFeed)
		}
		
		_ = map(feed,timestamp: timestamp)
		if let saveError = saveContext() {
			completion(.some(saveError))
		} else {
			completion(.none)
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		if let dataFeed =  getFetchedRequest() {
			let imageFeed: [LocalFeedImage] = dataFeed.images.compactMap { ($0 as? CoreDataFeedImage)?.local }
			completion(.found(feed: imageFeed, timestamp: dataFeed.timestamp))
		} else {
			completion(.empty)
		}
	}
	
	// MARK: Helper Methods
	
	private func getFetchedRequest()->CoreDataFeed? {
		let fetchRequest = NSFetchRequest<CoreDataFeed>(entityName: Constants.CORE_DATA_FEED_MODEL_NAME)
		return try! managedContext.fetch(fetchRequest).first
	}
	
	private func saveContext() -> Error? {
		if storeContainer.viewContext.hasChanges {
			do {
				try storeContainer.viewContext.save()
				return nil
			} catch {
				return error
			}
		} else {
			return nil
		}
	}
	
	private func map(_ feed:[LocalFeedImage], timestamp:Date) -> CoreDataFeed {
		var imageSet: [CoreDataFeedImage] = []
		
		for image in feed {
			
			let cdImage = CoreDataFeedImage(context: managedContext)
			
			cdImage.id = image.id
			cdImage.url = image.url
			cdImage.image_desc = image.description
			cdImage.location = image.location
			
			imageSet.append(cdImage)
		}
		
		let images = NSOrderedSet(array: imageSet)
		let cdFeed = CoreDataFeed(context: managedContext)
		
		cdFeed.images = images
		cdFeed.timestamp = timestamp
		
		return cdFeed
	}
	
}
