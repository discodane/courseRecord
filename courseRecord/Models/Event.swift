import Foundation
import CoreLocation

struct Event: Identifiable, Codable, Hashable {
    var id: UUID
    var spotID: UUID
    var name: String
    var description: String
    var unit: RecordUnit
    var sortOrder: SortOrder
    var startLatitude: Double?
    var startLongitude: Double?
    var createdBy: String
    var createdAt: Date

    var isVerifiable: Bool {
        startLatitude != nil && startLongitude != nil
    }

    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLatitude, let lng = startLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    init(
        id: UUID = UUID(),
        spotID: UUID,
        name: String,
        description: String = "",
        unit: RecordUnit,
        sortOrder: SortOrder,
        startLatitude: Double? = nil,
        startLongitude: Double? = nil,
        createdBy: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.spotID = spotID
        self.name = name
        self.description = description
        self.unit = unit
        self.sortOrder = sortOrder
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.createdBy = createdBy
        self.createdAt = createdAt
    }
}

enum RecordUnit: String, Codable, CaseIterable, Hashable {
    case seconds
    case minutes
    case reps
    case points
    case feet
    case meters
    case pounds
    case kilograms

    var label: String {
        switch self {
        case .seconds: "sec"
        case .minutes: "min"
        case .reps: "reps"
        case .points: "pts"
        case .feet: "ft"
        case .meters: "m"
        case .pounds: "lbs"
        case .kilograms: "kg"
        }
    }
}

enum SortOrder: String, Codable, Hashable {
    case ascending
    case descending

    var displayName: String {
        switch self {
        case .ascending: "Lower is better"
        case .descending: "Higher is better"
        }
    }
}

extension Event {
    static let preview = Event(
        spotID: Spot.preview.id,
        name: "Lap Around the Lake",
        description: "Full loop starting and ending at the main entrance",
        unit: .minutes,
        sortOrder: .ascending,
        startLatitude: 40.8012,
        startLongitude: -73.9714,
        createdBy: "dane"
    )

    static let previews: [Event] = [
        .preview,
        Event(
            spotID: Spot.preview.id,
            name: "Pull-ups at the Bars",
            description: "Max pull-ups in one set, no kipping",
            unit: .reps,
            sortOrder: .descending,
            createdBy: "dane"
        ),
        Event(
            spotID: Spot.previews[1].id,
            name: "Basketball Shootout",
            description: "60-second shooting game, standard rules",
            unit: .points,
            sortOrder: .descending,
            createdBy: "dane"
        ),
    ]
}
