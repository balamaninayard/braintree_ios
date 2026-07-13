import Foundation

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// The funding-instrument (FI) display model for the Edit FI component.
///
/// Maps the mutually-exclusive `fetchVaultedPaymentMethod` payload to a UI-ready value: an
/// `.instrument` when a vaulted FI is returned, or `.displayOnly` when only a payer email is
/// available. A `nil` mapping represents the No-FI case, where the caller shows the fallback tile.
public enum BTPayPalFISummary: Equatable {

    /// A vaulted funding instrument to render as an FI chip (icon + label + last digits).
    case instrument(Instrument)

    /// A display-only response carrying just the payer email (no editable instrument).
    case displayOnly(email: String)

    /// A vaulted funding instrument's display fields.
    public struct Instrument: Equatable {

        /// Display label, e.g. `"Visa"` or `"CREDIT UNION 1"`.
        public let label: String?

        /// Last digits of the instrument, when applicable.
        public let lastDigits: String?

        /// Instrument type: `CARD`, `BANK`, or `PAYPAL_CREDIT`.
        public let type: String?

        /// Instrument subtype, present for `PAYPAL_CREDIT`.
        public let subtype: String?

        /// Brand / logo icon URL.
        public let imageURL: URL?
    }

    // MARK: - Mapping

    /// Builds a `BTPayPalFISummary` from the PayPal fetch/refetch result.
    /// - Parameter result: The parsed `BTPayPalFetchVaultPaymentMethod` returned by the client.
    /// - Returns: `nil` for the No-FI case (no instrument and no payer email), so the caller can
    ///   render the No-FI-load fallback tile.
    public init?(from result: BTPayPalFetchVaultPaymentMethod) {
        if let instrument = result.primaryInstrument {
            self = .instrument(
                Instrument(
                    label: instrument.label,
                    lastDigits: instrument.lastDigits,
                    type: instrument.type,
                    subtype: instrument.subtype,
                    imageURL: instrument.imageURL
                )
            )
        } else if let email = result.payer?.email {
            self = .displayOnly(email: email)
        } else {
            return nil
        }
    }
}
