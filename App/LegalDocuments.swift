import SwiftUI

enum LegalDocumentKind: String, CaseIterable, Identifiable {
    case privacy, agreement, collection, thirdParties = "thirdparties", services
    var id: String { rawValue }
    var title: String {
        switch self {
        case .privacy: "隐私政策"
        case .agreement: "用户协议"
        case .collection: "个人信息收集清单"
        case .thirdParties: "第三方服务与 SDK 清单"
        case .services: "服务说明"
        }
    }
}

/// The first-use notice and the profile entry read the same versioned documents.
enum LegalContent {
    static let services: [(String, String)] = [
        ("学校账号与学习数据", "只需登录一次川农 e，应用通过学校 VPN 自动进入教务统一认证并核验学号，无需另填教务账号或密码。川农 e 学号、密码与学校会话保存在不可同步的本机 Keychain，用于自动登录与刷新；学校要求验证码或二次验证时由本人完成，完成后自动继续刷新，解绑时清除。入学年份用于显示年级学期。手动课程在本机保存，刷新学校课表时保留。"),
        ("平台账号", "我的川农账号用于资料库、校园社区、机构预约和意见反馈，与学校账号分别管理。个人资料与主动提交的内容按隐私政策处理。"),
        ("跑腿代取", "跑腿代取暂未开放。开放时展示实际服务提供方、服务内容及联系入口。"),
        ("机构与预约", "驾校、雅思托福、考公考研和健身房资料由运营后台维护。预约是咨询意向登记，由运营人员处理，不产生付款。演示机构不接受真实预约。"),
        ("资料库", "资料库提供运营维护的外部链接，普通用户不上传资料。匹配资料、最近浏览和我的收藏按本人操作显示；请确认来源合法并遵守版权规则。"),
        ("校园社区", "二手与失物信息经审核后公开展示，处理结果在我的发布和消息中查看。公开联系方式仅用于对应物品联系。可举报社区内容，或在本机屏蔽发布者；屏蔽名单可在“我的 → 隐私与合规”中管理。"),
        ("反馈与投诉", "反馈和资料投诉关联当前平台账号，处理结果可在我的反馈中查看。请勿提交密码、验证码或不必要的敏感信息。"),
        ("课表提醒与本机工具", "上课提醒依据本机课表和周次安排最近 60 次提醒，打开应用或修改课表时更新队列。长期未打开应用后需要再次打开补充。小组件使用本机课表；关闭或解绑会清除共享课程。价值账本按学校账号在本机保存，校历周末不等于法定假期。"),
        ("服务开放状态", "板块状态仅由超级管理员设置。不可用服务仍可点进状态页，维护、即将上线或关闭时暂停对应业务。预计时间仅供参考，开放以实际状态为准。")
    ]
}

private struct LegalParagraph: Decodable {
    struct Run: Decodable {
        let text: String
        let bold: Bool?
        let url: URL?
    }
    let kind: String
    let runs: [Run]

    var content: AttributedString {
        runs.reduce(into: AttributedString()) { text, run in
            var part = AttributedString(run.text)
            if run.bold == true { part.inlinePresentationIntent = .stronglyEmphasized }
            part.link = run.url
            text += part
        }
    }
}

private struct LegalEdition: Decodable {
    let version: String
    let documents: [String: [LegalParagraph]]

    static let bundled: LegalEdition? = {
        guard let url = Bundle.main.url(forResource: "MyChuannongLegal", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let edition = try? JSONDecoder().decode(Self.self, from: data),
              edition.version == PrivacyConsent.policyVersion else { return nil }
        return edition
    }()
}

struct LegalView: View {
    var kind: LegalDocumentKind? = nil

    var body: some View {
        if let kind {
            if kind == .services {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(LegalContent.services, id: \.0) { title, text in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(title).font(.headline).accessibilityAddTraits(.isHeader)
                                Text(text).font(.body).lineSpacing(6).textSelection(.enabled)
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(24)
                }.navigationTitle(kind.title).navigationBarTitleDisplayMode(.inline)
            } else if let paragraphs = LegalEdition.bundled?.documents[kind.rawValue],
                      let first = paragraphs.first {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(paragraphs.indices.dropFirst(), id: \.self) { index in
                            let paragraph = paragraphs[index]
                            if paragraph.kind == "heading" || paragraph.kind == "subheading" {
                                Text(paragraph.content)
                                    .font(paragraph.kind == "heading" ? .title3.bold() : .headline)
                                    .padding(.top, 6).accessibilityAddTraits(.isHeader)
                            } else {
                                Text(paragraph.content).font(.body).lineSpacing(5)
                            }
                        }
                    }.textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading).padding(20)
                }.navigationTitle(first.kind == "title" ? first.runs.map(\.text).joined() : kind.title)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("协议正文无法读取。").navigationTitle(kind.title)
            }
        } else {
            List {
                ForEach(LegalDocumentKind.allCases) { document in
                    NavigationLink(document.title) { LegalView(kind: document) }
                }
            }.navigationTitle("隐私政策与用户协议").navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ServiceInformationView: View {
    var body: some View { LegalView(kind: .services) }
}
