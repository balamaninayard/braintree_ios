import UIKit

/// :nodoc: Form of authorization to interact with the Braintree gateway.
@_documentation(visibility: private)
public protocol ClientAuthorization {

    /// :nodoc: Enum to denote Authorization type of Tokenization Key or Client Token.
    var type: AuthorizationType { get }
    
    /// :nodoc: The URL derived from this auth credential used to fetch the configuration.
    var configURL: URL { get }
    
    /// :nodoc: The bearer token to use for authenticating API calls.
    /// The authorization fingerprint if a client token, or the full tokenization key if a tokenization key.
    var bearer: String { get }
    
    /// :nodoc: The original, full string value of the authorization string provided by the merchant.
    /// The full client token or tokenization key.
    var originalValue: String { get }

    /// :nodoc: The `paymentMethodIdJwt` (`pmid`) extracted from a client token, used by the Edit FI flow
    /// to fetch the sticky funding instrument. `nil` for tokenization keys or client tokens without the claim.
    var paymentMethodIDJWT: String? { get }
}

/// :nodoc:
@_documentation(visibility: private)
public extension ClientAuthorization {

    /// Default for authorizations that do not carry a PMT JWT (tokenization keys, client tokens without the claim).
    var paymentMethodIDJWT: String? { nil }
}

/// :nodoc:
@_documentation(visibility: private)
public enum AuthorizationType {
    case tokenizationKey
    case clientToken
    case invalidAuthorization
}
