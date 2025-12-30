import SwiftUI

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
}

struct OnboardingView: View {
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Feel Braille Patterns",
            subtitle: "Use braille pattern in your devices through touch.\nYou will need help to set up the app and learn to use Haptille.",
            systemImage: "hand.tap.fill",
            accent: Color(red: 0.839, green: 0.271, blue: 0.271)
        ),
        OnboardingPage(
            title: "Read",
            subtitle: "Use Haptille to read text not in braille format without any help from others.",
            systemImage: "document.fill",
            accent: Color(red: 0.145, green: 0.388, blue: 0.922)
        ),
        OnboardingPage(
            title: "Converse",
            subtitle: "Use Haptille to converse with others without any help from others.",
            systemImage: "text.bubble.fill",
            accent: Color(red: 0.173, green: 0.749, blue: 0.631)
        ),
        OnboardingPage(
            title: "Learn",
            subtitle: "Learn the haptille format for easy access to digital services.",
            systemImage: "pencil",
            accent: Color(red: 0.839, green: 0.620, blue: 0.180)
        )
    ]

    let onFinish: () -> Void
    @State private var selection = 0

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(pages.indices, id: \.self) { index in
                    let page = pages[index]
                    OnboardingCard(page: page)
                        .tag(index)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .overlay(alignment: .bottom) {
            Button(selection < pages.count - 1 ? "Next" : "Get Started") {
                if selection < pages.count - 1 {
                    selection += 1
                } else {
                    onFinish()
                }
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(pages[selection].accent)
            .padding(.bottom, 100)
        }
    }
}

private struct OnboardingCard: View {
    let page: OnboardingPage

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

#Preview {
    OnboardingView(onFinish: {})
}
