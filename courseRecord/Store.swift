import Foundation

@Observable
class Store {
    var spots: [Spot]
    var events: [Event]
    var records: [Record]

    init() {
        spots = Spot.previews
        events = Event.previews
        records = Record.previews
    }

    func addSpot(_ spot: Spot) {
        spots.append(spot)
    }

    func addEvent(_ event: Event) {
        events.append(event)
    }

    func addRecord(_ record: Record) {
        records.append(record)
    }

    func deleteSpot(_ spot: Spot) {
        let eventIDs = events.filter { $0.spotID == spot.id }.map(\.id)
        records.removeAll { eventIDs.contains($0.eventID) }
        events.removeAll { $0.spotID == spot.id }
        spots.removeAll { $0.id == spot.id }
    }

    func deleteEvent(_ event: Event) {
        records.removeAll { $0.eventID == event.id }
        events.removeAll { $0.id == event.id }
    }

    func events(for spot: Spot) -> [Event] {
        events.filter { $0.spotID == spot.id }
    }

    func records(for event: Event) -> [Record] {
        records.filter { $0.eventID == event.id }
    }

    func sortedRecords(for event: Event) -> [Record] {
        let eventRecords = records(for: event)
        switch event.sortOrder {
        case .ascending:
            return eventRecords.sorted { $0.value < $1.value }
        case .descending:
            return eventRecords.sorted { $0.value > $1.value }
        }
    }
}
