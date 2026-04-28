import SwiftUI

struct ContentView: View {
    @State private var store = Store()

    var body: some View {
        NavigationStack {
            SpotListView()
                .navigationDestination(for: Spot.self) { spot in
                    SpotDetailView(spot: spot)
                }
                .navigationDestination(for: Event.self) { event in
                    EventDetailView(event: event)
                }
        }
        .tint(AppTheme.primary)
        .environment(store)
    }
}

#Preview {
    ContentView()
}
