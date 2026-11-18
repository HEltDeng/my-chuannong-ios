import Foundation

public struct BlockedCommunityUser: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
}

/// Blocks are local to this installation and separated by the signed-in platform account.
public struct CommunityBlocks: Codable, Sendable {
    public static let storageKey = "community.blockedUsers.v1"
    private var accounts: [String: [BlockedCommunityUser]] = [:]

    public init(json: String) {
        if let data = json.data(using: .utf8), let saved = try? JSONDecoder().decode(Self.self, from: data) {
            self = saved
        }
    }

    public func users(for account: String?) -> [BlockedCommunityUser] {
        guard let account, !account.isEmpty else { return [] }
        return accounts[account] ?? []
    }

    public func contains(_ author: String, account: String?) -> Bool {
        !author.isEmpty && users(for: account).contains { $0.id == author }
    }

    public mutating func block(_ author: String, name: String, account: String?) {
        guard let account, !account.isEmpty, !author.isEmpty, author != account else { return }
        var list = users(for: account)
        guard !list.contains(where: { $0.id == author }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        list.append(BlockedCommunityUser(id: author, name: trimmed.isEmpty ? "校园用户" : String(trimmed.prefix(30))))
        accounts[account] = list
    }

    public mutating func unblock(_ author: String, account: String?) {
        guard let account, !account.isEmpty else { return }
        let remaining = users(for: account).filter { $0.id != author }
        accounts[account] = remaining.isEmpty ? nil : remaining
    }

    public mutating func clear(account: String?) {
        guard let account, !account.isEmpty else { return }
        accounts[account] = nil
    }

    public func json() -> String {
        guard let data = try? JSONEncoder().encode(self), let value = String(data: data, encoding: .utf8) else { return "{}" }
        return value
    }
}
