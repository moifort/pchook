// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportPauseMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportPause"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportPause { audibleImportPause }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportPause", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportPauseMutation.Data.self
      ] }

      /// Mettre en pause ou reprendre l'import Audible. Retourne true si mis en pause, false si repris.
      var audibleImportPause: Bool? { __data["audibleImportPause"] }
    }
  }

}