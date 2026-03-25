// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportPauseMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportPause"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportPause { audibleImportPause { __typename phase current total message } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportPause", AudibleImportPause.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportPauseMutation.Data.self
      ] }

      /// Pause the running Audible import
      var audibleImportPause: AudibleImportPause { __data["audibleImportPause"] }

      /// AudibleImportPause
      ///
      /// Parent Type: `AudibleImport`
      struct AudibleImportPause: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleImport }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("phase", String.self),
          .field("current", Int.self),
          .field("total", Int.self),
          .field("message", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleImportPauseMutation.Data.AudibleImportPause.self
        ] }

        /// Current task phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
        /// Number of items processed in current run
        var current: Int { __data["current"] }
        /// Total items to process in current run
        var total: Int { __data["total"] }
        /// Current progress message
        var message: String { __data["message"] }
      }
    }
  }

}