// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class RefreshBookMutation: GraphQLMutation {
    static let operationName: String = "RefreshBook"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RefreshBook($id: ID!) { refreshBook(id: $id) }"#
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
        .field("refreshBook", Bool?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RefreshBookMutation.Data.self
      ] }

      /// Ré-enrichir un livre via Gemini (met à jour les métadonnées)
      var refreshBook: Bool? { __data["refreshBook"] }
    }
  }

}