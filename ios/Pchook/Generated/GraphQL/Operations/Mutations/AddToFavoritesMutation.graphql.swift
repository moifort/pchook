// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AddToFavoritesMutation: GraphQLMutation {
    static let operationName: String = "AddToFavorites"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddToFavorites($id: ID!) { addToFavorites(id: $id) { __typename id status } }"#
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
        .field("addToFavorites", AddToFavorites?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddToFavoritesMutation.Data.self
      ] }

      /// Ajouter un livre aux favoris (note de coup de cœur + statut lu)
      var addToFavorites: AddToFavorites? { __data["addToFavorites"] }

      /// AddToFavorites
      ///
      /// Parent Type: `Book`
      struct AddToFavorites: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddToFavoritesMutation.Data.AddToFavorites.self
        ] }

        /// Identifiant unique
        var id: PchookGraphQL.ID? { __data["id"] }
        /// Statut de lecture
        var status: GraphQLEnum<PchookGraphQL.BookStatus>? { __data["status"] }
      }
    }
  }

}