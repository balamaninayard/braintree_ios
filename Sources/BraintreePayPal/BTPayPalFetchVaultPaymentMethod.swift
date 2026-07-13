import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The parsed result of the shared `fetchVaultedPaymentMethod` GraphQL query.
///
/// The payload is mutually exclusive: an instrument response carries `paymentMethods` with a `nil`
/// `payer`; a display-only response carries `payer` (email) with an empty `paymentMethods`. Callers
/// branch on which is populated. Shared by both the sticky-FI fetch and the post-edit refresh.
public struct BTPayPalFetchVaultPaymentMethod: Equatable {

    /// A single vaulted funding instrument (card / bank / PayPal Credit).
    public struct Instrument: Equatable {

        /// Display label, e.g. `"CREDIT UNION 1"`.
        public let label: String?

        /// Brand / logo icon URL.
        public let imageURL: URL?

        /// Last digits of the instrument, when applicable.
        public let lastDigits: String?

        /// Instrument type: `CARD`, `BANK`, or `PAYPAL_CREDIT`.
        public let type: String?

        /// Instrument subtype, present for `PAYPAL_CREDIT`.
        public let subtype: String?
    }

    /// Display-only payer information, returned when no instrument is available.
    public struct Payer: Equatable {

        /// Payer email.
        public let email: String?

        /// Whether the funding instrument is editable.
        public let isEditable: Bool?
    }

    /// The vaulted funding instrument(s). Empty for display-only responses.
    public let paymentMethods: [Instrument]

    /// Present for display-only (email-only) responses; `nil` when instruments are returned.
    public let payer: Payer?

    /// The primary instrument, if any — the FI shown on the chip.
    public var primaryInstrument: Instrument? { paymentMethods.first }

    /// Parses the GraphQL response body into a result.
    /// Returns `nil` when `data.fetchVaultedPaymentMethod` is absent (No-FI), so the caller can fall back.
    init?(json: BTJSON) {
        let root = json["data"]["fetchVaultedPaymentMethod"]

        guard root.asDictionary() != nil else { return nil }

        self.paymentMethods = (root["paymentMethods"].asArray() ?? []).map { instrument in
            Instrument(
                label: instrument["label"].asString(),
                imageURL: instrument["imageUrl"].asURL(),
                lastDigits: instrument["lastDigits"].asString(),
                type: instrument["type"].asString(),
                subtype: instrument["subtype"].asString()
            )
        }

        let payerJSON = root["payer"]
        if payerJSON.asDictionary() != nil {
            self.payer = Payer(
                email: payerJSON["email"].asString(),
                isEditable: payerJSON["isEditable"].asBool()
            )
        } else {
            self.payer = nil
        }
    }
}
