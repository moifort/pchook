// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class DeleteBookMutation: GraphQLMutation {
    static let operationName: String = "DeleteBook"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteBook($id: BookId!) { deleteBook(id: $id) }"#
      ))

    public var id: BookId

    public init(id: BookId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteBook", Bool.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeleteBookMutation.Data.self
      ] }

      /// Delete a book and its associated data (review, series)
      var deleteBook: Bool { __data["deleteBook"] }
    }
  }

}