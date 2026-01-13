import SwiftUI

struct OnboardingCard: View {
    let page: OnboardingPage
    let onAction: (() -> Void)?
    let statusTitle: String?
    let statusItems: [String]

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(page.accent.opacity(0.2))
                    .frame(width: 160, height: 160)
                Image(systemName: page.systemImage)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(page.accent)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                if let actionTitle = page.actionTitle, let onAction {
                    Button(actionTitle, action: onAction)
                        .buttonStyle(.borderedProminent)
                        .tint(page.accent)
                        .padding(.top, 6)
                }

                if let statusTitle {
                    Text(statusTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                if !statusItems.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(statusItems, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: 520)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(page.accent.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: page.accent.opacity(0.15), radius: 18, x: 0, y: 8)
    }
}
