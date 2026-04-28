import Foundation
import CoreLocation

struct Spot: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String
    var createdBy: String
    var createdAt: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        address: String,
        createdBy: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.createdBy = createdBy
        self.createdAt = createdAt
    }
}

extension Spot {
    static let preview = Spot(
        name: "Riverside Park",
        latitude: 40.8010,
        longitude: -73.9712,
        address: "Riverside Dr, New York, NY",
        createdBy: "dane"
    )

    static let previews: [Spot] = [
        .preview,
        Spot(
            name: "Dane's House",
            latitude: 40.7484,
            longitude: -73.9857,
            address: "123 Main St",
            createdBy: "dane"
        ),
        Spot(
            name: "Memorial Field",
            latitude: 40.7580,
            longitude: -73.9855,
            address: "456 Park Ave",
            createdBy: "alex"
        ),
    ]
}
