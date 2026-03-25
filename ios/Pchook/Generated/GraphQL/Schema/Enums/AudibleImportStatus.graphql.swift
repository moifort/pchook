// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Audible import task status
  enum AudibleImportStatus: String, EnumType {
    /// Import cancelled
    case cancelled = "cancelled"
    /// Import completed
    case completed = "completed"
    /// Import failed
    case failed = "failed"
    /// Awaiting start
    case idle = "idle"
    /// Import paused
    case paused = "paused"
    /// Import in progress
    case running = "running"
  }

}