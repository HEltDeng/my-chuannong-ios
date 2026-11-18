import Foundation

public enum PhoneAccountMode: String, Sendable {
    case login, register
    public var needsNewPassword: Bool { self == .register }
    public var title: String {
        switch self {
        case .login: "登录我的川农账号"
        case .register: "创建我的川农账号"
        }
    }
}

public enum PhoneAccountRules {
    public static let reminder = "请妥善保管手机号和密码。需要账号帮助时，可通过“联系支持”核对身份。"
    public static func validConfirmation(password: String, confirmation: String) -> Bool {
        CampusContract.validPassword(password) && !password.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && password == confirmation
    }
}
