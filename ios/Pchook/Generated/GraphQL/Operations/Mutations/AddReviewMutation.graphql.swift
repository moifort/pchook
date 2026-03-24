// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AddReviewMutation: GraphQLMutation {
    static let operationName: String = "AddReview"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddReview($bookId: ID!, $input: CreateReviewInput!) { addReview(bookId: $bookId, input: $input) { __typename bookId rating readDate reviewNotes createdAt } }"#
      ))

    public var bookId: ID
    public var input: CreateReviewInput

    public init(
      bookId: ID,
      input: CreateReviewInput
    ) {
      self.bookId = bookId
      self.input = input
    }

    public var __variables: Variables? { [
      "bookId": bookId,
      "input": input
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("addReview", AddReview?.self, arguments: [
          "bookId": .variable("bookId"),
          "input": .variable("input")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddReviewMutation.Data.self
      ] }

      /// Ajouter une critique à un livre (marque le livre comme lu)
      var addReview: AddReview? { __data["addReview"] }

      /// AddReview
      ///
      /// Parent Type: `Review`
      struct AddReview: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Review }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("bookId", PchookGraphQL.ID?.self),
          .field("rating", Int?.self),
          .field("readDate", String?.self),
          .field("reviewNotes", String?.self),
          .field("createdAt", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddReviewMutation.Data.AddReview.self
        ] }

        /// Identifiant du livre associé
        var bookId: PchookGraphQL.ID? { __data["bookId"] }
        /// Note personnelle (0-10)
        var rating: Int? { __data["rating"] }
        /// Date de lecture (ISO 8601)
        var readDate: String? { __data["readDate"] }
        /// Notes de lecture
        var reviewNotes: String? { __data["reviewNotes"] }
        /// Date de création (ISO 8601)
        var createdAt: String? { __data["createdAt"] }
      }
    }
  }

}