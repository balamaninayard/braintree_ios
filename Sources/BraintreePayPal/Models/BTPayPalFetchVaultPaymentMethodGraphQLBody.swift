import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable nesting
/// The POST body for the shared GraphQL `query FetchVaultedPaymentMethod`.
///
/// One query, two callers: the initial sticky-FI fetch (`STICKY_FI`, keyed by `paymentMethodIdJwt`)
/// and the post-edit refresh (`FI_FROM_APPROVED_CHECKOUT`, keyed by `orderId`). Everything below the
/// `fetchPaymentMethodType` discriminator — query string, transport, auth, and response parser — is
/// shared between the two; only the discriminator and identity field differ.
struct BTPayPalFetchVaultPaymentMethodGraphQLBody: BTGraphQLEncodableBody {

    var query: String
    var variables: Variables

    /// Fetch FI — initial / sticky display.
    /// - Parameter paymentMethodIDJWT: The PMT JWT extracted from the client token.
    init(paymentMethodIDJWT: String) {
        self.init(fetchPaymentMethodType: "STICKY_FI", paymentMethodIDJWT: paymentMethodIDJWT, orderID: nil)
    }

    /// Refetch FI — post-edit refresh.
    /// - Parameter orderID: The approved-checkout order id.
    init(orderID: String) {
        self.init(fetchPaymentMethodType: "FI_FROM_APPROVED_CHECKOUT", paymentMethodIDJWT: nil, orderID: orderID)
    }

    /// Shared designated initializer that assembles the query and input variables.
    private init(fetchPaymentMethodType: String, paymentMethodIDJWT: String?, orderID: String?) {
        self.query = Self.queryString
        self.variables = Variables(
            input: Variables.Input(
                fetchPaymentMethodType: fetchPaymentMethodType,
                paymentMethodIDJWT: paymentMethodIDJWT,
                orderID: orderID
            )
        )
    }

    // swiftlint:disable:next line_length
    private static let queryString = "query FetchVaultedPaymentMethod($input: FetchVaultedPaymentMethodInput!) { fetchVaultedPaymentMethod(input: $input) { payer { email isEditable } paymentMethods { label imageUrl lastDigits type subtype } } }"

    struct Variables: Encodable {

        let input: Input

        struct Input: Encodable {

            let fetchPaymentMethodType: String
            let paymentMethodIDJWT: String?
            let orderID: String?
            let integrationChannel = "BT_NATIVE_SDK"

            enum CodingKeys: String, CodingKey {
                case fetchPaymentMethodType
                case paymentMethodIDJWT = "paymentMethodIdJwt"
                case orderID = "orderId"
                case integrationChannel
            }
        }
    }
}
// swiftlint:enable nesting
