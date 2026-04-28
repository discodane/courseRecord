import SwiftUI

struct AddEventView: View {
    let spot: Spot

    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var unit: RecordUnit = .minutes
    @State private var sortOrder: SortOrder = .ascending

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
