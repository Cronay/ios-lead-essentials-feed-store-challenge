//
//  ManagedCache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Cronay on 28.09.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "Cache")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var images: NSOrderedSet

    static func getUniqueManagedCache(in context: NSManagedObjectContext) -> ManagedCache {
        if let fetchedCache = try? context.fetch(ManagedCache.fetchRequest() as NSFetchRequest<ManagedCache>).first {
            context.delete(fetchedCache)
        }

        return ManagedCache(context: context)
    }

    var localFeed: [LocalFeedImage] {
        return images.compactMap { (managedImage) -> LocalFeedImage? in
            if let image = managedImage as? ManagedFeedImage {
                return image.localFeedImage
            } else {
                return nil
            }
        }
    }
}

extension ManagedCache : Identifiable {

}
