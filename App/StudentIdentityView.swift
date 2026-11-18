import SwiftUI

struct StudentIdentityView: View {
    @Environment(PlatformSession.self) private var platform
    @Environment(SchoolSession.self) private var school
    var body: some View {
        Form {
            Section("学校认证") {
                if let identity = school.identity {
                    LabeledContent("姓名",value:identity.name)
                    LabeledContent("学号",value:identity.studentID)
                    if let grade=identity.grade,!grade.isEmpty { LabeledContent("年级",value:grade) }
                    LabeledContent("状态",value:"已认证")
                } else {
                    NavigationLink("绑定学号") { SchoolBindingView() }
                }
            }
            Section("平台核验") {
                if let studentID=platform.user?.studentId,!studentID.isEmpty {
                    LabeledContent("姓名",value:platform.user?.realName ?? "")
                    LabeledContent("学号",value:studentID)
                    LabeledContent("状态",value:platform.user?.identityStatus == "VERIFIED" ? "已核验" : "待核验")
                } else {
                    LabeledContent("状态",value:"未核验")
                }
            }
            NavigationLink("资料使用与更正规则") { LegalView(kind:.privacy) }
        }.navigationTitle("学生资料").navigationBarTitleDisplayMode(.inline)
    }
}
