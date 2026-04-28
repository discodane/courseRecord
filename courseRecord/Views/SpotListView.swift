import SwiftUI

struct SpotListView: View {
    @Environment(Store.self) private var store
    @State private var showingAddSpot = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.spots) { spot in
                    NavigationLink(value: spot) {
                        SpotCard(
                            spot: spot,
                            eventCount: store.events(for: spot).count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(AppTheme.background)
        .navigationTitle("Spots")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSpot = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddSpot) {
            AddSpotView()
        }
    }
}

struct SpotCard: View {
    let spot: Spot
    let eventCount: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 48, height: 48)
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(spot.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(eventCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
                Text("events")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        SpotListView()
    }
    .environment(Store())
}
