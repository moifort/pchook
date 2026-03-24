// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class CancelTaskMutation: GraphQLMutation {
    static let operationName: String = "CancelTask"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CancelTask($id: ID!) { cancelTask(id: $id) { __typename id phase } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("cancelTask", CancelTask.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CancelTaskMutation.Data.self
      ] }

      /// Cancel a running or paused task
      var cancelTask: CancelTask { __data["cancelTask"] }

      /// CancelTask
      ///
      /// Parent Type: `Task`
      struct CancelTask: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Task }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("phase", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CancelTaskMutation.Data.CancelTask.self
        ] }

        /// Unique task identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Current phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
      }
    }
  }

}