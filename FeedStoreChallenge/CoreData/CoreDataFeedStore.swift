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
		//
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		//
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let fetchRequest = NSFetchRequest<CoreDataFeed>(entityName: "CoreDataFeed")
		let coreDataFeed = try! managedContext.fetch(fetchRequest).first
		if let dataFeed = coreDataFeed {
			let imageFeed: [LocalFeedImage] = dataFeed.feed.compactMap { ($0 as? CoreDataFeedImage)?.local }
			completion(.found(feed: imageFeed, timestamp: dataFeed.timestamp))
		} else {
			completion(.empty)
		}
	}
	
	
	
}
