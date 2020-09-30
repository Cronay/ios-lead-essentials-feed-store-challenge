//
//  ManagedFeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Cronay on 28.09.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedFeedImage {

    @NSManaged internal var id: UUID
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
    @NSManaged internal var cache: ManagedCache?

    var localFeedImage: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
