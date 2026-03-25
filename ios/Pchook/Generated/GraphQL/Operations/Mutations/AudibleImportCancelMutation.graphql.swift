// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleImportCancelMutation: GraphQLMutation {
    static let operationName: String = "AudibleImportCancel"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleImportCancel { audibleImportCancel { __typename phase } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleImportCancel", AudibleImportCancel.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleImportCancelMutation.Data.self
      ] }

      /// Cancel the running or paused Audible import
      var audibleImportCancel: AudibleImportCancel { __data["audibleImportCancel"] }

      /// AudibleImportCancel
      ///
      /// Parent Type: `AudibleImport`
      struct AudibleImportCancel: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleImport }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("phase", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleImportCancelMutation.Data.AudibleImportCancel.self
        ] }

        /// Current task phase (idle, running, paused, cancelled, completed, failed)
        var phase: String { __data["phase"] }
      }
    }
  }

}