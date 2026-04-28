import SwiftUI

struct AddSpotView: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !address.trimmingCharacters(in: .whitespaces).isEmpty
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
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text("New Spot")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        FormField(title: "Name", placeholder: "Riverside Park", text: $name)
                        FormField(title: "Address", placeholder: "123 Main St", text: $address)
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
                        let spot = Spot(
                            name: name.trimmingCharacters(in: .whitespaces),
                            latitude: 0,
                            longitude: 0,
                            address: address.trimmingCharacters(in: .whitespaces),
                            createdBy: "me"
                        )
                        store.addSpot(spot)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .padding(12)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)
        }
    }
}

#Preview {
    AddSpotView()
        .environment(Store())
}
