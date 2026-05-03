import SwiftUI

struct FBAvatar: View {
    var imageURL: URL? = nil
    var initials: String = ""
    var size: Size = .md
    var isActive: Bool = false

    enum Size {
        case sm, md, lg, xl

        var points: CGFloat {
            switch self {
            case .sm: return 32
            case .md: return 44
            case .lg: return 56
            case .xl: return 80
            }
        }

        var fontSize: Font {
            switch self {
            case .sm: return Theme.Typography.caption
            case .md: return Theme.Typography.subheading
            case .lg: return Theme.Typography.body
            case .xl: return Theme.Typography.title3
            }
        }
    }

    var body: some View {
        ZStack {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size.points, height: size.points)
        .clipShape(Circle())
        .overlay {
            if isActive {
                Circle()
                    .strokeBorder(Theme.Colors.primary, lineWidth: 2.5)
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Theme.Colors.muted
            if initials.isEmpty {
                Image(systemName: "pawprint.fill")
                    .foregroundStyle(Theme.Colors.textTertiary)
                    .font(size.fontSize)
            } else {
                Text(initials.prefix(2).uppercased())
                    .font(size.fontSize)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.md) {
        FBAvatar(initials: "B", size: .sm)
        FBAvatar(initials: "Ma", size: .md, isActive: true)
        FBAvatar(initials: "R", size: .lg)
        FBAvatar(size: .xl)
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
