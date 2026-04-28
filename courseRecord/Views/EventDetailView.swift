import SwiftUI

struct EventDetailView: View {
    let event: Event

    @Environment(Store.self) private var store
    @State private var showingAddRecord = false

    var sortedRecords: [Record] {
        store.sortedRecords(for: event)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                eventInfoCard
                leaderboardSection
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(AppTheme.background)
        .navigationTitle(event.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddRecord = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            AddRecordView(event: event)
        }
    }

    private var eventInfoCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 64, height: 64)
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.primary)
            }

            if !event.description.isEmpty {
                Text(event.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                TagBadge(icon: "arrow.up.arrow.down", text: event.sortOrder.displayName)
                TagBadge(icon: "ruler", text: event.unit.label)
            }

            HStack(spacing: 4) {
                Text("Created by")
                    .foregroundStyle(.secondary)
                Text(event.createdBy)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primary)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .cardStyle()
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leaderboard")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.leading, 4)

            if sortedRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.primary.opacity(0.4))
                    Text("No Records Yet")
                        .font(.headline)
                    Text("Tap + to set the first record!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 58)
                        }
                        RecordRow(rank: index + 1, record: record, unit: event.unit)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }
                }
                .cardStyle()
            }
        }
    }
}

struct RecordRow: View {
    let rank: Int
    let record: Record
    let unit: RecordUnit

    private var rankDisplay: some View {
        Group {
            switch rank {
            case 1:
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                }
            case 2:
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "medal.fill")
                        .foregroundStyle(.gray)
                }
            case 3:
                ZStack {
                    Circle()
                        .fill(Color.brown.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "medal.fill")
                        .foregroundStyle(.brown)
                }
            default:
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryLight)
                        .frame(width: 36, height: 36)
                    Text("#\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            rankDisplay

            VStack(alignment: .leading, spacing: 2) {
                Text(record.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.formattedValue(unit: unit))
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.primaryDark)
                Text(record.date, format: .dateTime.month().day())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: .preview)
    }
    .environment(Store())
}
