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
	
	enum CoreDataError: Swift.Error {
		case deletionError
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
		let context = managedContext
		context.perform {
			do {
				if let coreDataFeed = try CoreDataFeed.getFecthedRequest(context) {
					context.delete(coreDataFeed)
					try context.save()
					completion(.none)
				} else {
					completion(.none)
				}
			} catch {
				completion(.some(error))
			}
		}
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = managedContext
		do {
			if let coreDataFeed = try CoreDataFeed.getFecthedRequest(context) {
				context.delete(coreDataFeed)
			}
		} catch {
			completion(.some(CoreDataError.deletionError))
		}
		
		context.perform { [weak self] in
			 self!.insert(feed, timestamp: timestamp)
			
			do {
				try context.save()
				completion(.none)
			} catch {
				completion(.some(error))
			}
		}
		
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = managedContext
		context.perform {
			do {
				if let dataFeed = try CoreDataFeed.getFecthedRequest(context) {
					let imageFeed: [LocalFeedImage] = dataFeed.localFeed
					completion(.found(feed: imageFeed, timestamp: dataFeed.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.empty)
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
