// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class ConfirmBookMutation: GraphQLMutation {
    static let operationName: String = "ConfirmBook"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ConfirmBook($input: ConfirmBookInput!) { confirmBook(input: $input) { __typename tag book { __typename id title authors status } } }"#
      ))

    public var input: ConfirmBookInput

    public init(input: ConfirmBookInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("confirmBook", ConfirmBook.self, arguments: ["input": .variable("input")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConfirmBookMutation.Data.self
      ] }

      /// Confirm and create a book from a scan preview
      var confirmBook: ConfirmBook { __data["confirmBook"] }

      /// ConfirmBook
      ///
      /// Parent Type: `ConfirmBookResult`
      struct ConfirmBook: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.ConfirmBookResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("tag", String.self),
          .field("book", Book.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConfirmBookMutation.Data.ConfirmBook.self
        ] }

        /// Result: created, duplicate, or replaced
        var tag: String { __data["tag"] }
        /// Created or found book
        var book: Book { __data["book"] }

        /// ConfirmBook.Book
        ///
        /// Parent Type: `Book`
        struct Book: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.BookId.self),
            .field("title", PchookGraphQL.BookTitle.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("status", PchookGraphQL.BookStatus.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConfirmBookMutation.Data.ConfirmBook.Book.self
          ] }

          /// Unique identifier
          var id: PchookGraphQL.BookId { __data["id"] }
          /// Book title
          var title: PchookGraphQL.BookTitle { __data["title"] }
          /// Book authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Reading status (to-read | read)
          var status: PchookGraphQL.BookStatus { __data["status"] }
        }
      }
    }
  }

}