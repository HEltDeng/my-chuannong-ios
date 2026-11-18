import XCTest
@testable import ChuannongCore

final class PhoneAccountTests: XCTestCase {
    func testRegistrationRequiresConfirmedPassword() {
        XCTAssertFalse(PhoneAccountMode.login.needsNewPassword)
        XCTAssertTrue(PhoneAccountMode.register.needsNewPassword)
        XCTAssertFalse(PhoneAccountRules.validConfirmation(password:"short",confirmation:"short"))
        XCTAssertFalse(PhoneAccountRules.validConfirmation(password:"        ",confirmation:"        "))
        XCTAssertFalse(PhoneAccountRules.validConfirmation(password:"pass1234",confirmation:"pass1235"))
        XCTAssertTrue(PhoneAccountRules.validConfirmation(password:"pass1234",confirmation:"pass1234"))
    }
    func testLegacyPasswordAccountDecode() throws {
        let user=try JSONDecoder().decode(AuthUser.self,from:Data(#"{"id":"synthetic","nickname":"测试","accountType":"PHONE"}"#.utf8))
        XCTAssertEqual(user.accountType,"PHONE")
        XCTAssertNil(user.studentId)
        XCTAssertNil(user.identityStatus)
    }
}
