//
//  FeedStoreIntegrationTests.swift
//  Tests
//
//  Created by Caio Zullo on 01/09/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
     
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_deliversFeedInsertedOnAnotherInstance() {
        let storeToInsert = makeSUT()
        let storeToLoad = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()

        insert((feed, timestamp), to: storeToInsert)

        expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_insert_overridesFeedInsertedOnAnotherInstance() {
        let storeToInsert = makeSUT()
        let storeToOverride = makeSUT()
        let storeToLoad = makeSUT()

        insert((uniqueImageFeed(), Date()), to: storeToInsert)

        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: storeToOverride)

        expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_delete_deletesFeedInsertedOnAnotherInstance() {
        let storeToInsert = makeSUT()
        let storeToDelete = makeSUT()
        let storeToLoad = makeSUT()

        insert((uniqueImageFeed(), Date()), to: storeToInsert)

        deleteCache(from: storeToDelete)

        expect(storeToLoad, toRetrieve: .empty)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = try! CoreDataFeedStore(storeURL: storeFileURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func storeFileURL() -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let storeURL = cachesDirectory.appendingPathComponent("feed.store")
        return storeURL
    }
    
    private func setupEmptyStoreState() {
        deleteRemainingStoreFileFromTests()
    }

    private func undoStoreSideEffects() {
        deleteRemainingStoreFileFromTests()
    }

    private func deleteRemainingStoreFileFromTests() {
        if FileManager.default.fileExists(atPath: storeFileURL().path) {
            do {
                try FileManager.default.removeItem(at: storeFileURL())
            } catch {
                XCTFail("Couldn't remove feed store file at specified path")
            }
        }
    }
}
