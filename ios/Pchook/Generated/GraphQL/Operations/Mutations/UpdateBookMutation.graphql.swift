// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class UpdateBookMutation: GraphQLMutation {
    static let operationName: String = "UpdateBook"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateBook($id: ID!, $input: UpdateBookInput!) { updateBook(id: $id, input: $input) { __typename id title authors publisher genre status updatedAt } }"#
      ))

    public var id: ID
    public var input: UpdateBookInput

    public init(
      id: ID,
      input: UpdateBookInput
    ) {
      self.id = id
      self.input = input
    }

    public var __variables: Variables? { [
      "id": id,
      "input": input
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateBook", UpdateBook?.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateBookMutation.Data.self
      ] }

      /// Modifier un livre existant
      var updateBook: UpdateBook? { __data["updateBook"] }

      /// UpdateBook
      ///
      /// Parent Type: `Book`
      struct UpdateBook: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID?.self),
          .field("title", String?.self),
          .field("authors", [String]?.self),
          .field("publisher", String?.self),
          .field("genre", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>?.self),
          .field("updatedAt", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateBookMutation.Data.UpdateBook.self
        ] }

        /// Identifiant unique
        var id: PchookGraphQL.ID? { __data["id"] }
        /// Titre du livre
        var title: String? { __data["title"] }
        /// Auteurs du livre
        var authors: [String]? { __data["authors"] }
        /// Éditeur
        var publisher: String? { __data["publisher"] }
        /// Genre littéraire (ex: Romance, SF, Polar)
        var genre: String? { __data["genre"] }
        /// Statut de lecture
        var status: GraphQLEnum<PchookGraphQL.BookStatus>? { __data["status"] }
        /// Date de dernière modification (ISO 8601)
        var updatedAt: String? { __data["updatedAt"] }
      }
    }
  }

}