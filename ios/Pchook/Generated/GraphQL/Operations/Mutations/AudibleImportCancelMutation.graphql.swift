// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportCancelMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportCancel"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportCancel { audibleImportCancel }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportCancel", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportCancelMutation.Data.self
      ] }

      /// Annuler l'import Audible en cours
      var audibleImportCancel: Bool? { __data["audibleImportCancel"] }
    }
  }

}