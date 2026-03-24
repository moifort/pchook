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
        .field("confirmBook", ConfirmBook?.self, arguments: ["input": .variable("input")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConfirmBookMutation.Data.self
      ] }

      /// Confirmer et créer un livre depuis un preview de scan
      var confirmBook: ConfirmBook? { __data["confirmBook"] }

      /// ConfirmBook
      ///
      /// Parent Type: `ConfirmBookResult`
      struct ConfirmBook: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.ConfirmBookResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("tag", String?.self),
          .field("book", Book?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConfirmBookMutation.Data.ConfirmBook.self
        ] }

        /// Résultat: created, duplicate, ou replaced
        var tag: String? { __data["tag"] }
        /// Livre créé ou trouvé
        var book: Book? { __data["book"] }

        /// ConfirmBook.Book
        ///
        /// Parent Type: `Book`
        struct Book: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID?.self),
            .field("title", String?.self),
            .field("authors", [String]?.self),
            .field("status", GraphQLEnum<PchookGraphQL.BookStatus>?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConfirmBookMutation.Data.ConfirmBook.Book.self
          ] }

          /// Identifiant unique
          var id: PchookGraphQL.ID? { __data["id"] }
          /// Titre du livre
          var title: String? { __data["title"] }
          /// Auteurs du livre
          var authors: [String]? { __data["authors"] }
          /// Statut de lecture
          var status: GraphQLEnum<PchookGraphQL.BookStatus>? { __data["status"] }
        }
      }
    }
  }

}