// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class ResumeTaskMutation: GraphQLMutation {
    static let operationName: String = "ResumeTask"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ResumeTask($id: ID!) { resumeTask(id: $id) { __typename id phase } }"#
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
        .field("resumeTask", ResumeTask.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ResumeTaskMutation.Data.self
      ] }

      /// Resume a paused task
      var resumeTask: ResumeTask { __data["resumeTask"] }

      /// ResumeTask
      ///
      /// Parent Type: `Task`
      struct ResumeTask: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Task }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("phase", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ResumeTaskMutation.Data.ResumeTask.self
        ] }

        /// Unique task identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Current phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
      }
    }
  }

}