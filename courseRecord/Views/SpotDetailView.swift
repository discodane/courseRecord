import SwiftUI

struct SpotDetailView: View {
    let spot: Spot

    @Environment(Store.self) private var store
    @State private var showingAddEvent = false

    var spotEvents: [Event] {
        store.events(for: spot)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                spotInfoCard
                eventsSection
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(AppTheme.background)
        .navigationTitle(spot.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddEvent = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(spot: spot)
        }
    }

    private var spotInfoCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 64, height: 64)
                Image(systemName: "mappin.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.primary)
            }

            Label(spot.address, systemImage: "location.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text("Created by")
                    .foregroundStyle(.secondary)
                Text(spot.createdBy)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primary)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .cardStyle()
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Events")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.leading, 4)

            if spotEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "flag.slash")
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.primary.opacity(0.4))
                    Text("No Events Yet")
                        .font(.headline)
                    Text("Tap + to create the first event at this spot.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .cardStyle()
            } else {
                ForEach(spotEvents) { event in
                    NavigationLink(value: event) {
                        EventCard(
                            event: event,
                            recordCount: store.records(for: event).count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct EventCard: View {
    let event: Event
    let recordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.primaryLight)
                        .frame(width: 36, height: 36)
                    Image(systemName: "flag.fill")
                        .foregroundStyle(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 16) {
                TagBadge(icon: "arrow.up.arrow.down", text: event.sortOrder.displayName)
                TagBadge(icon: "list.number", text: "\(recordCount) records")
            }
        }
        .padding(14)
        .cardStyle()
    }
}

struct TagBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption2)
        .foregroundStyle(AppTheme.primaryDark)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppTheme.primaryLight)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: .preview)
    }
    .environment(Store())
}
