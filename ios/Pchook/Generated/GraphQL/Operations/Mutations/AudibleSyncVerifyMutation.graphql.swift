// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleSyncVerifyMutation: GraphQLMutation {
    static let operationName: String = "AudibleSyncVerify"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleSyncVerify { audibleSyncVerify }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleSyncVerify", Bool?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleSyncVerifyMutation.Data.self
      ] }

      /// Vérifier la validité des credentials Audible
      var audibleSyncVerify: Bool? { __data["audibleSyncVerify"] }
    }
  }

}