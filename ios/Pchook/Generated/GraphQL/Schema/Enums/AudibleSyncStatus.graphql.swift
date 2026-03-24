// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Audible synchronization status
  enum AudibleSyncStatus: String, EnumType {
    /// Connected, not yet fetched
    case connected = "CONNECTED"
    /// Not connected to Audible
    case disconnected = "DISCONNECTED"
    /// Library data fetched
    case fetched = "FETCHED"
    /// Currently fetching library data
    case fetching = "FETCHING"
  }

}