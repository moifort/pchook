// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class UpdateBookMutation: GraphQLMutation {
    static let operationName: String = "UpdateBook"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateBook($id: BookId!, $input: UpdateBookInput!) { updateBook(id: $id, input: $input) { __typename id title authors publisher genre status updatedAt } }"#
      ))

    public var id: BookId
    public var input: UpdateBookInput

    public init(
      id: BookId,
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
        .field("updateBook", UpdateBook.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateBookMutation.Data.self
      ] }

      /// Update an existing book
      var updateBook: UpdateBook { __data["updateBook"] }

      /// UpdateBook
      ///
      /// Parent Type: `Book`
      struct UpdateBook: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.BookId.self),
          .field("title", PchookGraphQL.BookTitle.self),
          .field("authors", [PchookGraphQL.PersonName].self),
          .field("publisher", PchookGraphQL.Publisher?.self),
          .field("genre", PchookGraphQL.Genre?.self),
          .field("status", PchookGraphQL.BookStatus.self),
          .field("updatedAt", PchookGraphQL.DateTime.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateBookMutation.Data.UpdateBook.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.BookId { __data["id"] }
        /// Book title
        var title: PchookGraphQL.BookTitle { __data["title"] }
        /// Book authors
        var authors: [PchookGraphQL.PersonName] { __data["authors"] }
        /// Publisher (e.g. "Gallimard", "Folio"). Null if unknown
        var publisher: PchookGraphQL.Publisher? { __data["publisher"] }
        /// Literary genre, comma-separated if multiple (e.g. "LitRPG, Science Fantasy")
        var genre: PchookGraphQL.Genre? { __data["genre"] }
        /// Reading status (to-read | read)
        var status: PchookGraphQL.BookStatus { __data["status"] }
        /// Date of last modification
        var updatedAt: PchookGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}