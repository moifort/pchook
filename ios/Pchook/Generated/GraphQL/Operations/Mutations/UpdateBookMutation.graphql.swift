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
          .field("id", PchookGraphQL.ID.self),
          .field("title", String.self),
          .field("authors", [String].self),
          .field("publisher", String?.self),
          .field("genre", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>.self),
          .field("updatedAt", PchookGraphQL.DateTime.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateBookMutation.Data.UpdateBook.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Book title
        var title: String { __data["title"] }
        /// Book authors
        var authors: [String] { __data["authors"] }
        /// Publisher
        var publisher: String? { __data["publisher"] }
        /// Literary genre (e.g. Romance, Sci-Fi, Thriller)
        var genre: String? { __data["genre"] }
        /// Reading status
        var status: GraphQLEnum<PchookGraphQL.BookStatus> { __data["status"] }
        /// Last modified date
        var updatedAt: PchookGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}