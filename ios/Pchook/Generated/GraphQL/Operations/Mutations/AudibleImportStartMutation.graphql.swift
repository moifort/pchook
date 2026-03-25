// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportStartMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportStart"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportStart { audibleImportStart { __typename id phase current total message startedAt completedAt } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportStart", AudibleImportStart.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportStartMutation.Data.self
      ] }

      /// Start importing Audible books (background task)
      var audibleImportStart: AudibleImportStart { __data["audibleImportStart"] }

      /// AudibleImportStart
      ///
      /// Parent Type: `Task`
      struct AudibleImportStart: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Task }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.TaskId.self),
          .field("phase", String.self),
          .field("current", Int.self),
          .field("total", Int.self),
          .field("message", String.self),
          .field("startedAt", PchookGraphQL.DateTime?.self),
          .field("completedAt", PchookGraphQL.DateTime?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleImportStartMutation.Data.AudibleImportStart.self
        ] }

        /// Unique task identifier
        var id: PchookGraphQL.TaskId { __data["id"] }
        /// Current phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
        /// Number of items processed
        var current: Int { __data["current"] }
        /// Total number of items
        var total: Int { __data["total"] }
        /// Progress message
        var message: String { __data["message"] }
        /// Start date
        var startedAt: PchookGraphQL.DateTime? { __data["startedAt"] }
        /// Completion date
        var completedAt: PchookGraphQL.DateTime? { __data["completedAt"] }
      }
    }
  }

}