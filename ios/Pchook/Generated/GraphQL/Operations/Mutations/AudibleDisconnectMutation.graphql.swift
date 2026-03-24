// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleDisconnectMutation: GraphQLMutation {
    static let operationName: String = "AudibleDisconnect"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleDisconnect { audibleDisconnect }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleDisconnect", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleDisconnectMutation.Data.self
      ] }

      /// Déconnecter le compte Audible et nettoyer les données
      var audibleDisconnect: Bool? { __data["audibleDisconnect"] }
    }
  }

}