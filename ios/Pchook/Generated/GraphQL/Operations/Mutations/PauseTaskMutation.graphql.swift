// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class PauseTaskMutation: GraphQLMutation {
    static let operationName: String = "PauseTask"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PauseTask($id: ID!) { pauseTask(id: $id) { __typename id phase } }"#
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
        .field("pauseTask", PauseTask.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PauseTaskMutation.Data.self
      ] }

      /// Pause a running task
      var pauseTask: PauseTask { __data["pauseTask"] }

      /// PauseTask
      ///
      /// Parent Type: `Task`
      struct PauseTask: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Task }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("phase", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PauseTaskMutation.Data.PauseTask.self
        ] }

        /// Unique task identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Current phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
      }
    }
  }

}