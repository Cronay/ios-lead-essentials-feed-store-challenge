//
//  ManagedCache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Cronay on 28.09.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import CoreData


extension ManagedCache {

    @nonobjc internal class func fetchCache(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: "Cache")
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var images: NSOrderedSet

    internal static func getUniqueManagedCache(in context: NSManagedObjectContext) -> ManagedCache {
        if let fetchedCache = try? fetchCache(in: context) {
            context.delete(fetchedCache)
        }

        return ManagedCache(context: context)
    }

    internal var localFeed: [LocalFeedImage] {
        return images.compactMap { (managedImage) -> LocalFeedImage? in
            if let image = managedImage as? ManagedFeedImage {
                return image.localFeedImage
            } else {
                return nil
            }
        }
    }
}
