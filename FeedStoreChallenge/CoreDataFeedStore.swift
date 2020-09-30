//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Cronay on 27.09.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {

    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL) throws {
        let managedObjectModel = try NSManagedObjectModel.loadFeedStoreModel()

        persistentContainer = try NSPersistentContainer.loadFeedStorePersistentContainer(at: storeURL, with: managedObjectModel)
        context = persistentContainer.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform { [context] in
            do {
                let managedCache = try ManagedCache.fetchCache(in: context)
                try managedCache.map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context] in
            let cache = ManagedCache.getUniqueManagedCache(in: context)

            cache.timestamp = timestamp
            let managedFeedArray = feed.mapToManagedFeedImages(in: context)
            cache.images = NSOrderedSet(array: managedFeedArray)

            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
            do {
                let fetchedCache = try ManagedCache.fetchCache(in: context)

                if let managedCache = fetchedCache {
                    completion(.found(feed: managedCache.localFeed, timestamp: managedCache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension NSManagedObjectModel {
    static func loadFeedStoreModel() throws -> NSManagedObjectModel {
        guard let modelURL = Bundle(for: CoreDataFeedStore.self).url(forResource: "FeedCache", withExtension: "momd") else {
            throw NSError(domain: "Could not find managed object model resource", code: 0)
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            throw NSError(domain: "Could not instantiate managed object model", code: 0)
        }

        return managedObjectModel
    }
}

private extension NSPersistentContainer {
    static func loadFeedStorePersistentContainer(at storeURL: URL, with managedObjectModel: NSManagedObjectModel) throws -> NSPersistentContainer {
        let persistentContainer = NSPersistentContainer(name: "FeedCache", managedObjectModel: managedObjectModel)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer.persistentStoreDescriptions = [storeDescription]

        var receivedError: Error?
        persistentContainer.loadPersistentStores { (_, error) in
            receivedError = error
        }
        if let error = receivedError { throw error }

        return persistentContainer
    }
}

private extension Array where Element == LocalFeedImage {
    func mapToManagedFeedImages(in context: NSManagedObjectContext) -> [ManagedFeedImage] {
        let managedFeedArray = self.map { (localImage) -> ManagedFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)

            managedFeedImage.id = localImage.id
            managedFeedImage.imageDescription = localImage.description
            managedFeedImage.location = localImage.location
            managedFeedImage.url = localImage.url

            return managedFeedImage
        }

        return managedFeedArray
    }
}
