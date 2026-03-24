// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleSyncFetchMutation: GraphQLMutation {
    static let operationName: String = "AudibleSyncFetch"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleSyncFetch { audibleSyncFetch }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleSyncFetch", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleSyncFetchMutation.Data.self
      ] }

      /// Récupérer la bibliothèque et wishlist Audible (tâche de fond)
      var audibleSyncFetch: Bool? { __data["audibleSyncFetch"] }
    }
  }

}