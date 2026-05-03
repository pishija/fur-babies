import SwiftUI

struct OnboardingView: View {
    var onComplete: (() -> Void)?

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                aiPage.tag(1)
                healthPage.tag(2)
                matchingPage.tag(3)
                ctaPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if currentPage >= 1 && currentPage <= 3 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") { onComplete?() }
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .padding(.top, 64)
                            .padding(.trailing, Theme.Spacing.xl)
                    }
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        pageLayout(bottom: {
            VStack(spacing: Theme.Spacing.lg) {
                dotsIndicator
                FBButton(title: "Get Started \u{2192}", size: .large) { currentPage = 1 }
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }, content: {
            VStack(spacing: Theme.Spacing.xl) {
                iconCircle(
                    size: 160,
                    bgColor: Color(red: 1.0, green: 0.953, blue: 0.902),
                    icon: "pawprint.fill", iconSize: 80, iconColor: Theme.Colors.primary
                )
                VStack(spacing: Theme.Spacing.sm) {
                    Text("FurBabies")
                        .font(Theme.Typography.largeTitle)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Your dog's digital companion")
                        .font(Theme.Typography.title3)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    Text("Health records, reminders, matching,\nand your dog's very own AI friend.")
                        .font(Theme.Typography.subheading)
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
        })
    }

    private var aiPage: some View {
        featurePage(
            bgColor: Color(red: 0.902, green: 0.949, blue: 0.937),
            icon: "sparkles", iconSize: 80, iconColor: Theme.Colors.secondary,
            title: "Meet Your Dog's\nAI Friend",
            description: "Get personalised advice, track milestones, and chat with your dog's breed-aware AI companion.",
            onNext: { currentPage = 2 }
        )
    }

    private var healthPage: some View {
        featurePage(
            bgColor: Color(red: 0.992, green: 0.910, blue: 0.910),
            icon: "calendar.badge.checkmark", iconSize: 72, iconColor: Theme.Colors.accent,
            title: "Never Miss a\nHealth Event",
            description: "Set reminders for vaccinations, vet visits, flea treatments, and more. All in one place.",
            onNext: { currentPage = 3 }
        )
    }

    private var matchingPage: some View {
        featurePage(
            bgColor: Color(red: 0.996, green: 0.953, blue: 0.906),
            icon: "heart.fill", iconSize: 72, iconColor: Theme.Colors.primary,
            title: "Find Perfect\nPlaymates",
            description: "Match your dog with compatible breeds nearby and make new friends on every walk.",
            onNext: { currentPage = 4 }
        )
    }

    private var ctaPage: some View {
        pageLayout(bottom: {
            VStack(spacing: Theme.Spacing.lg) {
                dotsIndicator
                FBButton(title: "+ Add Your First Dog", size: .large) { onComplete?() }
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }, content: {
            VStack(spacing: Theme.Spacing.xl) {
                iconCircle(
                    size: 160,
                    bgColor: Color(red: 0.902, green: 0.957, blue: 0.941),
                    icon: "dog.fill", iconSize: 80, iconColor: Theme.Colors.secondary
                )
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Let's Meet\nYour Dog!")
                        .font(Theme.Typography.title1)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    Text("Create your dog's profile to unlock health tracking, AI companionship, and playmate matching.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
        })
    }

    // MARK: - Helpers

    private func featurePage(
        bgColor: Color, icon: String, iconSize: CGFloat, iconColor: Color,
        title: String, description: String, onNext: @escaping () -> Void
    ) -> some View {
        pageLayout(bottom: {
            VStack(spacing: Theme.Spacing.lg) {
                dotsIndicator
                FBButton(title: "Next", action: onNext)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }, content: {
            VStack(spacing: Theme.Spacing.xl) {
                iconCircle(size: 140, bgColor: bgColor, icon: icon, iconSize: iconSize, iconColor: iconColor)
                VStack(spacing: Theme.Spacing.md) {
                    Text(title)
                        .font(Theme.Typography.title1)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    Text(description)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, Theme.Spacing.xs)
                }
            }
        })
    }

    private func pageLayout<Bottom: View, Content: View>(
        @ViewBuilder bottom: () -> Bottom,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            content()
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, Theme.Spacing.xxl)
            bottom()
                .padding(.bottom, Theme.Spacing.xl)
        }
        .padding(.top, Theme.Spacing.xxxl)
    }

    private func iconCircle(size: CGFloat, bgColor: Color, icon: String, iconSize: CGFloat, iconColor: Color) -> some View {
        ZStack {
            Circle()
                .fill(bgColor)
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundStyle(iconColor)
        }
    }

    private var dotsIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(i == currentPage ? Theme.Colors.primary : Theme.Colors.border)
                    .frame(width: i == currentPage ? 10 : 8, height: i == currentPage ? 10 : 8)
                    .animation(.spring(duration: 0.2), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
