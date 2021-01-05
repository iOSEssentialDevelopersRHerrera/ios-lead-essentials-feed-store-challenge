//
//  CoreDataFeedStoreFactory.swift
//  Tests
//
//  Created by Ricardo Herrera Petit on 1/5/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import FeedStoreChallenge

func makeSUT() -> FeedStore {
	let modelName = Constants.CORE_DATA_FEED_MODEL_NAME
	let storeBundle = Bundle(for: CoreDataFeedStore.self)
	let storeURL = URL(fileURLWithPath: "/dev/null")
	
	let sut = try! CoreDataFeedStore(modelName: modelName, url: storeURL, in: storeBundle)
	return sut
}
