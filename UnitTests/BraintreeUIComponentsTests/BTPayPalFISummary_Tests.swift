import XCTest
import BraintreeCore
@testable import BraintreePayPal
@testable import BraintreeUIComponents

final class BTPayPalFISummary_Tests: XCTestCase {

    func testInit_whenInstrumentResult_mapsToInstrumentCase() throws {
        let result = try makeResult([
            "paymentMethods": [
                [
                    "label": "Visa",
                    "imageUrl": "https://example.com/visa.png",
                    "lastDigits": "1234",
                    "type": "CARD",
                    "subtype": NSNull()
                ]
            ]
        ])

        guard case .instrument(let instrument) = BTPayPalFISummary(from: result) else {
            return XCTFail("Expected .instrument case")
        }

        XCTAssertEqual(instrument.label, "Visa")
        XCTAssertEqual(instrument.lastDigits, "1234")
        XCTAssertEqual(instrument.type, "CARD")
        XCTAssertEqual(instrument.imageURL, URL(string: "https://example.com/visa.png"))
    }

    func testInit_whenDisplayOnlyResult_mapsToDisplayOnlyCase() throws {
        let result = try makeResult([
            "payer": ["email": "buyer@example.com", "isEditable": true],
            "paymentMethods": []
        ])

        guard case .displayOnly(let email) = BTPayPalFISummary(from: result) else {
            return XCTFail("Expected .displayOnly case")
        }

        XCTAssertEqual(email, "buyer@example.com")
    }

    func testInit_whenEmptyResult_returnsNil() throws {
        let result = try makeResult(["paymentMethods": []])

        XCTAssertNil(BTPayPalFISummary(from: result))
    }

    // MARK: - Helpers

    private func makeResult(_ fetchVaultedPaymentMethod: [String: Any]) throws -> BTPayPalFetchVaultPaymentMethod {
        let body = BTJSON(value: ["data": ["fetchVaultedPaymentMethod": fetchVaultedPaymentMethod]] as [String: Any])
        return try XCTUnwrap(BTPayPalFetchVaultPaymentMethod(json: body))
    }
}
