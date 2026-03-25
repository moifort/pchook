// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportResumeMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportResume"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportResume { audibleImportResume { __typename phase current total message } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportResume", AudibleImportResume.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportResumeMutation.Data.self
      ] }

      /// Resume a paused Audible import
      var audibleImportResume: AudibleImportResume { __data["audibleImportResume"] }

      /// AudibleImportResume
      ///
      /// Parent Type: `AudibleImport`
      struct AudibleImportResume: PchookGraphQL.SelectionSet {
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
          AudibleImportResumeMutation.Data.AudibleImportResume.self
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