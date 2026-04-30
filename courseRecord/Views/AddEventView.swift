import SwiftUI

struct AddEventView: View {
    let spot: Spot

    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var unit: RecordUnit = .minutes
    @State private var sortOrder: SortOrder = .ascending
    @State private var isVerifiable = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
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
                            Image(systemName: "flag.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text("New Event")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("at \(spot.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        FormField(title: "Name", placeholder: "Lap Around the Lake", text: $name)
                        FormField(title: "Description (optional)", placeholder: "Full loop from main entrance", text: $description)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Unit")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(RecordUnit.allCases, id: \.self) { option in
                                        PickerChip(
                                            label: option.label,
                                            isSelected: unit == option
                                        ) {
                                            unit = option
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ranking")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach([SortOrder.ascending, .descending], id: \.self) { option in
                                    PickerChip(
                                        label: option.displayName,
                                        isSelected: sortOrder == option
                                    ) {
                                        sortOrder = option
                                    }
                                }
                            }
                        }

                        verificationToggle
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
                    Button("Add") {
                        let event = Event(
                            spotID: spot.id,
                            name: name.trimmingCharacters(in: .whitespaces),
                            description: description.trimmingCharacters(in: .whitespaces),
                            unit: unit,
                            sortOrder: sortOrder,
                            startLatitude: isVerifiable ? spot.latitude : nil,
                            startLongitude: isVerifiable ? spot.longitude : nil,
                            createdBy: "me"
                        )
                        store.addEvent(event)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }

    private var verificationToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isVerifiable) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GPS Verification")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Require users to be at the spot to start and finish a timed attempt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(AppTheme.primary)
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)

            if isVerifiable {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("The spot's location will be used as the start/finish point.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
            }
        }
    }
}

struct PickerChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .shadow(color: AppTheme.cardShadow, radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddEventView(spot: .preview)
        .environment(Store())
}
