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
	
	private let storeContainer: NSPersistentContainer
	private let managedContext: NSManagedObjectContext
	
	public init(storeContainer:NSPersistentContainer, managedContext: NSManagedObjectContext) {
		self.storeContainer = storeContainer
		self.managedContext = managedContext
		
		storeContainer.loadPersistentStores { (storeDescription, error) in
			if let error = error {
				print("Core Data error \(error)")
			}
		}
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		//
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		//
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	
}
