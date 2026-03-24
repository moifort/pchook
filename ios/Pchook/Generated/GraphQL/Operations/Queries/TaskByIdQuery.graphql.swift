// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class TaskByIdQuery: GraphQLQuery {
    static let operationName: String = "TaskById"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query TaskById($id: ID!) { task(id: $id) { __typename id phase current total message startedAt completedAt } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("task", Task?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TaskByIdQuery.Data.self
      ] }

      /// Get a task by its identifier
      var task: Task? { __data["task"] }

      /// Task
      ///
      /// Parent Type: `Task`
      struct Task: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Task }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("phase", String.self),
          .field("current", Int.self),
          .field("total", Int.self),
          .field("message", String.self),
          .field("startedAt", PchookGraphQL.DateTime?.self),
          .field("completedAt", PchookGraphQL.DateTime?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TaskByIdQuery.Data.Task.self
        ] }

        /// Unique task identifier
        var id: PchookGraphQL.ID { __data["id"] }
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