import XCTest
@testable import ChuannongCore

final class CommunityBlocksTests: XCTestCase {
    func testBlocksSurviveReloadAreSeparatedByAccountAndCanBeRemoved() {
        var blocks = CommunityBlocks(json: "{}")
        blocks.block("author-a", name: "同学甲", account: "reader-a")
        blocks.block("author-a", name: "重复", account: "reader-a")
        blocks.block("reader-a", name: "自己", account: "reader-a")
        blocks.block("author-b", name: "同学乙", account: "reader-b")

        var restored = CommunityBlocks(json: blocks.json())
        XCTAssertEqual(restored.users(for: "reader-a").map(\.name), ["同学甲"])
        XCTAssertTrue(restored.contains("author-a", account: "reader-a"))
        XCTAssertFalse(restored.contains("author-a", account: "reader-b"))
        XCTAssertTrue(restored.contains("author-b", account: "reader-b"))
        XCTAssertFalse(restored.contains("author-a", account: nil))

        restored.unblock("author-a", account: "reader-a")
        XCTAssertFalse(restored.contains("author-a", account: "reader-a"))
        restored.clear(account: "reader-b")
        XCTAssertTrue(restored.users(for: "reader-b").isEmpty)
    }
}
