// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class ImportStateQuery: GraphQLQuery {
    static let operationName: String = "ImportState"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ImportState { importState { __typename phase current total message startedAt completedAt } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("importState", ImportState?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ImportStateQuery.Data.self
      ] }

      /// État de la tâche d'import Audible
      var importState: ImportState? { __data["importState"] }

      /// ImportState
      ///
      /// Parent Type: `ImportTaskState`
      struct ImportState: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.ImportTaskState }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("phase", String?.self),
          .field("current", Int?.self),
          .field("total", Int?.self),
          .field("message", String?.self),
          .field("startedAt", String?.self),
          .field("completedAt", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ImportStateQuery.Data.ImportState.self
        ] }

        /// Phase (idle, running, paused, cancelled, completed, failed)
        var phase: String? { __data["phase"] }
        /// Nombre d'éléments traités
        var current: Int? { __data["current"] }
        /// Nombre total d'éléments
        var total: Int? { __data["total"] }
        /// Message de progression
        var message: String? { __data["message"] }
        /// Date de début (ISO 8601)
        var startedAt: String? { __data["startedAt"] }
        /// Date de fin (ISO 8601)
        var completedAt: String? { __data["completedAt"] }
      }
    }
  }

}