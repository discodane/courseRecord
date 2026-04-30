import SwiftUI
import MapKit

struct VerifiedAttemptView: View {
    let event: Event

    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var locationManager = LocationManager()
    @State private var phase: AttemptPhase = .waitingForLocation
    @State private var elapsedSeconds: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime: Date?
    @State private var userName = ""
    @State private var cameraPosition: MapCameraPosition = .automatic

    private let proximityThreshold: Double = 20

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    mapSection
                    controlSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopTimer()
                        locationManager.stopUpdating()
                        dismiss()
                    }
                }
            }
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdating()
                if let coord = event.startCoordinate {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: coord,
                        latitudinalMeters: 300,
                        longitudinalMeters: 300
                    ))
                }
            }
            .onDisappear {
                stopTimer()
                locationManager.stopUpdating()
            }
            .onChange(of: locationManager.location) {
                updatePhase()
            }
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            if let startCoord = event.startCoordinate {
                Annotation("Start", coordinate: startCoord) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary)
                            .frame(width: 32, height: 32)
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            }

            if let userLocation = locationManager.location?.coordinate {
                Annotation("You", coordinate: userLocation) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Controls

    private var controlSection: some View {
        VStack(spacing: 16) {
            timerDisplay

            switch phase {
            case .waitingForLocation:
                statusBanner(
                    icon: "location.magnifyingglass",
                    text: "Getting your location...",
                    color: .secondary
                )

            case .tooFar(let distance):
                statusBanner(
                    icon: "figure.walk",
                    text: "Get to the start point (\(Int(distance))m away)",
                    color: .orange
                )

            case .ready:
                Button {
                    startAttempt()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)

            case .running:
                statusBanner(
                    icon: "figure.run",
                    text: "Return to the start point to finish!",
                    color: AppTheme.primary
                )

            case .finished(let seconds):
                finishedSection(seconds: seconds)
            }
        }
        .padding(20)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: -4)
    }

    private var timerDisplay: some View {
        Text(formatTimer(elapsedSeconds))
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundStyle(phase == .running ? AppTheme.primary : .primary)
    }

    private func statusBanner(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func finishedSection(seconds: TimeInterval) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.primary)
                Text("Verified!")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primary)
            }

            FormField(title: "Your Name", placeholder: "dane", text: $userName)

            Button {
                let value: Double = switch event.unit {
                case .seconds: seconds
                case .minutes: seconds / 60.0
                default: seconds
                }
                let record = Record(
                    eventID: event.id,
                    value: value,
                    userName: userName.trimmingCharacters(in: .whitespaces),
                    note: "GPS Verified",
                    isVerified: true
                )
                store.addRecord(record)
                locationManager.stopUpdating()
                dismiss()
            } label: {
                Label("Submit Record", systemImage: "trophy.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
            .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - Logic

    private func updatePhase() {
        guard let startCoord = event.startCoordinate else { return }
        guard let distance = locationManager.distance(to: startCoord) else {
            phase = .waitingForLocation
            return
        }

        switch phase {
        case .waitingForLocation, .tooFar:
            if distance <= proximityThreshold {
                phase = .ready
            } else {
                phase = .tooFar(metersAway: distance)
            }
        case .ready:
            if distance > proximityThreshold {
                phase = .tooFar(metersAway: distance)
            }
        case .running:
            if distance <= proximityThreshold && elapsedSeconds > 5 {
                finishAttempt()
            }
        case .finished:
            break
        }
    }

    private func startAttempt() {
        startTime = .now
        elapsedSeconds = 0
        phase = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let startTime {
                elapsedSeconds = Date.now.timeIntervalSince(startTime)
            }
        }
    }

    private func finishAttempt() {
        let finalTime = elapsedSeconds
        stopTimer()
        phase = .finished(seconds: finalTime)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTimer(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let hundredths = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, hundredths)
    }
}

enum AttemptPhase: Equatable {
    case waitingForLocation
    case tooFar(metersAway: Double)
    case ready
    case running
    case finished(seconds: TimeInterval)
}

#Preview {
    VerifiedAttemptView(event: .preview)
        .environment(Store())
}
