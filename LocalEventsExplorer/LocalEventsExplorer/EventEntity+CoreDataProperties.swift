//
//  EventEntity+CoreDataProperties.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-09.
//
//

public import Foundation
public import CoreData
public typealias EventEntityCoreDataPropertiesSet = NSSet

extension EventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var venue: String?
    @NSManaged public var venueImage: String?
    @NSManaged public var eventDescription: String?
    @NSManaged public var eventImages: String?
    @NSManaged public var startTime: String?
    @NSManaged public var date: String?
    @NSManaged public var endTime: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var isFavourite: Bool

}

extension EventEntity : Identifiable {
}
