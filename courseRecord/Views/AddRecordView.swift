import SwiftUI

struct AddRecordView: View {
    let event: Event

    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var valueText = ""
    @State private var userName = ""
    @State private var note = ""

    private var parsedValue: Double? {
        Double(valueText)
    }

    private var isValid: Bool {
        parsedValue != nil
            && !userName.trimmingCharacters(in: .whitespaces).isEmpty
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
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text("New Record")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(event.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        FormField(title: "Your Name", placeholder: "dane", text: $userName)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Value (\(event.unit.label))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            TextField("0", text: $valueText)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)
                        }

                        FormField(title: "Note (optional)", placeholder: "New personal best!", text: $note)
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
                    Button("Submit") {
                        guard let value = parsedValue else { return }
                        let record = Record(
                            eventID: event.id,
                            value: value,
                            userName: userName.trimmingCharacters(in: .whitespaces),
                            note: note.trimmingCharacters(in: .whitespaces)
                        )
                        store.addRecord(record)
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
    AddRecordView(event: .preview)
        .environment(Store())
}
