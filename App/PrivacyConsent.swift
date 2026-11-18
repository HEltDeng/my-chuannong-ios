import SwiftUI

/// Bump this key whenever the scope of processing changes; old consent is not reused.
enum PrivacyConsent {
    static let storageKey = "privacy.ios.v10"
    static let policyVersion = "2026-11-17.1"
    static let receiptVersion = 10
    static var acceptedAt: Int64 { Int64(UserDefaults.standard.double(forKey: "privacy.acceptedAt.v10")) }
    static func accept() {
        UserDefaults.standard.set(Date.now.timeIntervalSince1970 * 1000, forKey: "privacy.acceptedAt.v10")
        UserDefaults.standard.set(true, forKey: storageKey)
    }
    static func decline() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: "privacy.acceptedAt.v10")
    }
}

struct WelcomeView: View {
    @State private var document: LegalDocumentKind?
    @State private var declined = false
    @ScaledMetric(relativeTo: .body) private var bodySize = 15.0
    @ScaledMetric(relativeTo: .headline) private var titleSize = 18.0
    @ScaledMetric(relativeTo: .headline) private var buttonSize = 16.0
    var accept: () -> Void = { PrivacyConsent.accept() }
    var decline: () -> Void = { PrivacyConsent.decline() }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()
                VStack(spacing: 18) {
                    Spacer()
                    Image("BrandMark").resizable().scaledToFit().frame(width: 76, height: 76)
                    Text("欢迎使用我的川农").font(.title2.bold())
                    Spacer()
                    HStack(spacing: 10) {
                        Image("BrandMark").resizable().scaledToFit().frame(width: 28, height: 28)
                        Text("我的川农").font(.system(size: 24, weight: .bold)).lineLimit(1)
                    }.foregroundStyle(ChuannongTheme.green).padding(.bottom, 32)
                }.accessibilityHidden(true)
                Color.black.opacity(0.48).ignoresSafeArea()
                VStack(spacing: 0) {
                    Text("用户协议及隐私保护")
                        .font(.system(size: titleSize, weight: .bold)).multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader).padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 18)
                    ViewThatFits(in: .vertical) {
                        documentLinks.fixedSize(horizontal: false, vertical: true)
                        ScrollView { documentLinks }
                    }
                    VStack(spacing: 4) {
                        Button("同意", action: accept)
                            .font(.system(size: buttonSize, weight: .medium)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(ChuannongTheme.green, in: Capsule())
                            .accessibilityIdentifier("welcome-agree")
                        Button("不同意") { decline(); declined = true }
                            .font(.system(size: bodySize)).foregroundStyle(Color.primary.opacity(0.68))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("welcome-disagree")
                    }.buttonStyle(.plain).padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 12)
                }
                .frame(maxWidth: 420)
                .frame(maxHeight: geometry.size.height * 0.88)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 38)
                .accessibilityAddTraits(.isModal)
            }
        }
        .tint(ChuannongTheme.green)
        .sheet(item: $document) { kind in
            NavigationStack {
                LegalView(kind: kind).toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { document = nil } } }
            }.tint(ChuannongTheme.green)
        }
        .alert("尚未同意", isPresented: $declined) {
            Button("返回协议", role: .cancel) { }
        } message: {
            Text("未同意时无法进入应用，你可以关闭应用或返回阅读。")
        }
    }
    private var documentLinks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("请阅读以下文件。点击“同意”后进入我的川农。")
                .font(.system(size: bodySize))
                .fixedSize(horizontal: false, vertical: true)
            ForEach([LegalDocumentKind.agreement, .privacy]) { kind in
                Button { document = kind } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text")
                        Text(kind.title)
                        Spacer()
                        Image(systemName: "chevron.forward").accessibilityHidden(true)
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .font(.system(size: buttonSize))
                .accessibilityIdentifier("welcome-document-" + kind.rawValue)
            }
        }
        .padding(.horizontal, 20)
    }

}
