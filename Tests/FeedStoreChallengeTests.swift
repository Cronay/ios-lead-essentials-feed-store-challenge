//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
    private func makeSUT(customContext: NSManagedObjectContextProtocol? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataFeedStore(storeURL: storeURL, customContext: customContext)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
	}
}

private class FailingContext: NSManagedObjectContextProtocol {
    func perform(_ block: @escaping () -> Void) {
        block()
    }

    func delete(_ object: NSManagedObject) {

    }

    func save() throws {
        throw NSError(domain: "Save failed", code: 0)
    }

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        throw NSError(domain: "Fetch failed", code: 0)
    }
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT(customContext: FailingContext())

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
//        let sut = makeSUT(testSpecificInvalidConfiguration())
//
//        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }

}
