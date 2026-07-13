import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

final class BTPayPalFetchVaultPaymentMethod_Tests: XCTestCase {

    func testInit_whenInstrumentResponse_parsesPaymentMethods() throws {
        let json = BTJSON(value: [
            "data": [
                "fetchVaultedPaymentMethod": [
                    "payer": NSNull(),
                    "paymentMethods": [
                        [
                            "label": "CREDIT UNION 1",
                            "imageUrl": "https://example.com/bank.png",
                            "lastDigits": "3357",
                            "type": "BANK",
                            "subtype": NSNull()
                        ]
                    ]
                ]
            ]
        ] as [String: Any])

        let result = try XCTUnwrap(BTPayPalFetchVaultPaymentMethod(json: json))

        XCTAssertNil(result.payer)
        XCTAssertEqual(result.paymentMethods.count, 1)

        let instrument = try XCTUnwrap(result.primaryInstrument)
        XCTAssertEqual(instrument.label, "CREDIT UNION 1")
        XCTAssertEqual(instrument.imageURL, URL(string: "https://example.com/bank.png"))
        XCTAssertEqual(instrument.lastDigits, "3357")
        XCTAssertEqual(instrument.type, "BANK")
        XCTAssertNil(instrument.subtype)
    }

    func testInit_whenDisplayOnlyResponse_parsesPayer() throws {
        let json = BTJSON(value: [
            "data": [
                "fetchVaultedPaymentMethod": [
                    "payer": [
                        "email": "buyer@example.com",
                        "isEditable": true
                    ],
                    "paymentMethods": []
                ]
            ]
        ] as [String: Any])

        let result = try XCTUnwrap(BTPayPalFetchVaultPaymentMethod(json: json))

        XCTAssertTrue(result.paymentMethods.isEmpty)
        XCTAssertNil(result.primaryInstrument)
        XCTAssertEqual(result.payer?.email, "buyer@example.com")
        XCTAssertEqual(result.payer?.isEditable, true)
    }

    func testInit_whenDataIsNull_returnsNil() {
        let json = BTJSON(value: [
            "data": ["fetchVaultedPaymentMethod": NSNull()]
        ] as [String: Any])

        XCTAssertNil(BTPayPalFetchVaultPaymentMethod(json: json))
    }

    func testInit_whenDataKeyMissing_returnsNil() {
        XCTAssertNil(BTPayPalFetchVaultPaymentMethod(json: BTJSON(value: [:] as [String: Any])))
    }
}
