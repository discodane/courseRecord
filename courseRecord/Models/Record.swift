import Foundation

struct Record: Identifiable, Codable, Hashable {
    var id: UUID
    var eventID: UUID
    var value: Double
    var userName: String
    var date: Date
    var note: String
    var isVerified: Bool
    var endorsements: [String]
    var createdAt: Date

    var endorsementCount: Int { endorsements.count }

    func isEndorsedBy(_ name: String) -> Bool {
        endorsements.contains(where: { $0.lowercased() == name.lowercased() })
    }

    init(
        id: UUID = UUID(),
        eventID: UUID,
        value: Double,
        userName: String,
        date: Date = .now,
        note: String = "",
        isVerified: Bool = false,
        endorsements: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.eventID = eventID
        self.value = value
        self.userName = userName
        self.date = date
        self.note = note
        self.isVerified = isVerified
        self.endorsements = endorsements
        self.createdAt = createdAt
    }
}

extension Record {
    func formattedValue(unit: RecordUnit) -> String {
        switch unit {
        case .seconds:
            let mins = Int(value) / 60
            let secs = Int(value) % 60
            let frac = Int((value.truncatingRemainder(dividingBy: 1)) * 100)
            return mins > 0
                ? String(format: "%d:%02d.%02d", mins, secs, frac)
                : String(format: "%d.%02d", secs, frac)
        case .minutes:
            let wholeMins = Int(value)
            let secs = Int((value - Double(wholeMins)) * 60)
            return String(format: "%d:%02d", wholeMins, secs)
        case .reps:
            return "\(Int(value)) \(unit.label)"
        case .points:
            return "\(Int(value)) \(unit.label)"
        case .feet, .meters:
            return String(format: "%.1f %@", value, unit.label)
        case .pounds, .kilograms:
            return String(format: "%.1f %@", value, unit.label)
        }
    }
}

extension Record {
    static let previews: [Record] = [
        Record(
            eventID: Event.preview.id,
            value: 7.5,
            userName: "dane",
            isVerified: true
        ),
        Record(
            eventID: Event.preview.id,
            value: 8.25,
            userName: "alex",
            date: .now.addingTimeInterval(-86400),
            isVerified: true
        ),
        Record(
            eventID: Event.preview.id,
            value: 6.75,
            userName: "jordan",
            date: .now.addingTimeInterval(-172800),
            note: "New personal best!",
            isVerified: true
        ),
        Record(
            eventID: Event.previews[1].id,
            value: 22,
            userName: "dane",
            endorsements: ["alex", "jordan"]
        ),
        Record(
            eventID: Event.previews[1].id,
            value: 18,
            userName: "alex",
            endorsements: ["dane"]
        ),
    ]
}
