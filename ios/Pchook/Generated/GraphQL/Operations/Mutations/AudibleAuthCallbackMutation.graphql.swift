// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleAuthCallbackMutation: GraphQLMutation {
    static let operationName: String = "AudibleAuthCallback"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleAuthCallback($sessionId: String!, $redirectUrl: String!) { audibleAuthCallback(sessionId: $sessionId, redirectUrl: $redirectUrl) }"#
      ))

    public var sessionId: String
    public var redirectUrl: String

    public init(
      sessionId: String,
      redirectUrl: String
    ) {
      self.sessionId = sessionId
      self.redirectUrl = redirectUrl
    }

    public var __variables: Variables? { [
      "sessionId": sessionId,
      "redirectUrl": redirectUrl
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleAuthCallback", Bool?.self, arguments: [
          "sessionId": .variable("sessionId"),
          "redirectUrl": .variable("redirectUrl")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleAuthCallbackMutation.Data.self
      ] }

      /// Finaliser l'authentification OAuth Audible
      var audibleAuthCallback: Bool? { __data["audibleAuthCallback"] }
    }
  }

}