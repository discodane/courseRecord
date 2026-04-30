import SwiftUI

struct EventDetailView: View {
    let event: Event

    @Environment(Store.self) private var store
    @State private var showingAddRecord = false
    @State private var showingVerifiedAttempt = false
    @State private var recordToEndorse: Record?

    var sortedRecords: [Record] {
        store.sortedRecords(for: event)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                eventInfoCard

                if event.isVerifiable {
                    verifiedAttemptButton
                }

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
        .sheet(item: $recordToEndorse) { record in
            EndorseRecordView(record: record)
        }
        .fullScreenCover(isPresented: $showingVerifiedAttempt) {
            VerifiedAttemptView(event: event)
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
                if event.isVerifiable {
                    TagBadge(icon: "location.fill", text: "GPS Verified")
                }
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

    private var verifiedAttemptButton: some View {
        Button {
            showingVerifiedAttempt = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.run")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Verified Attempt")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("GPS will verify your time at the start point")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.primaryLight.opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.primary.opacity(0.15), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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
                        RecordRow(rank: index + 1, record: record, unit: event.unit) {
                            recordToEndorse = record
                        }
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
    var onEndorse: (() -> Void)?

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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                rankDisplay

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(record.userName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        if record.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
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

            if !record.isVerified {
                HStack(spacing: 8) {
                    if record.endorsementCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.caption2)
                            Text("\(record.endorsementCount) vouch\(record.endorsementCount == 1 ? "" : "es")")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(AppTheme.primaryDark)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primaryLight)
                        .clipShape(Capsule())
                    }

                    Spacer()

                    if let onEndorse {
                        Button {
                            onEndorse()
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.caption2)
                                Text("Vouch")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(AppTheme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.primary.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 48)
            }
        }
    }
}

// MARK: - Endorse Record Sheet

struct EndorseRecordView: View {
    let record: Record

    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var yourName = ""

    private var isValid: Bool {
        let name = yourName.trimmingCharacters(in: .whitespaces)
        return !name.isEmpty
            && name.lowercased() != record.userName.lowercased()
            && !record.isEndorsedBy(name)
    }

    private var validationMessage: String? {
        let name = yourName.trimmingCharacters(in: .whitespaces)
        if name.lowercased() == record.userName.lowercased() {
            return "You can't vouch for your own record"
        }
        if record.isEndorsedBy(name) {
            return "You've already vouched for this record"
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryLight)
                                .frame(width: 72, height: 72)
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text("Vouch for Record")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("Confirm that \(record.userName) achieved this")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 14) {
                        HStack {
                            Text("Record")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(record.userName)
                                .fontWeight(.semibold)
                        }
                        .padding(12)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)

                        if record.endorsementCount > 0 {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Already vouched by")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 6) {
                                    ForEach(record.endorsements, id: \.self) { name in
                                        Text(name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(AppTheme.primaryLight)
                                            .foregroundStyle(AppTheme.primaryDark)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        FormField(title: "Your Name", placeholder: "your name", text: $yourName)

                        if let message = validationMessage, !yourName.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle")
                                Text(message)
                            }
                            .font(.caption)
                            .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vouch") {
                        store.endorseRecord(record, by: yourName.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: Event.previews[1])
    }
    .environment(Store())
}
