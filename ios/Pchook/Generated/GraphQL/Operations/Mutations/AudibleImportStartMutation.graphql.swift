// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportStartMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportStart"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportStart { audibleImportStart }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportStart", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportStartMutation.Data.self
      ] }

      /// Démarrer l'import des livres Audible (tâche de fond)
      var audibleImportStart: Bool? { __data["audibleImportStart"] }
    }
  }

}