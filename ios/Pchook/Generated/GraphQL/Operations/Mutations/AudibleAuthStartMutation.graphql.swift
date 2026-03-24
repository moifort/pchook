// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleAuthStartMutation: GraphQLMutation {
    static let operationName: String = "AudibleAuthStart"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AudibleAuthStart($locale: String) { audibleAuthStart(locale: $locale) { __typename loginUrl sessionId cookies { __typename name value domain } } }"#
      ))

    public var locale: GraphQLNullable<String>

    public init(locale: GraphQLNullable<String>) {
      self.locale = locale
    }

    public var __variables: Variables? { ["locale": locale] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleAuthStart", AudibleAuthStart?.self, arguments: ["locale": .variable("locale")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleAuthStartMutation.Data.self
      ] }

      /// Démarrer le flux d'authentification OAuth Audible
      var audibleAuthStart: AudibleAuthStart? { __data["audibleAuthStart"] }

      /// AudibleAuthStart
      ///
      /// Parent Type: `AuthStartResponse`
      struct AudibleAuthStart: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AuthStartResponse }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("loginUrl", String?.self),
          .field("sessionId", String?.self),
          .field("cookies", [Cooky]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleAuthStartMutation.Data.AudibleAuthStart.self
        ] }

        /// URL de connexion Audible
        var loginUrl: String? { __data["loginUrl"] }
        /// Identifiant de session d'authentification
        var sessionId: String? { __data["sessionId"] }
        /// Cookies à envoyer avec la requête de connexion
        var cookies: [Cooky]? { __data["cookies"] }

        /// AudibleAuthStart.Cooky
        ///
        /// Parent Type: `AuthCookie`
        struct Cooky: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AuthCookie }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
            .field("value", String?.self),
            .field("domain", String?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleAuthStartMutation.Data.AudibleAuthStart.Cooky.self
          ] }

          /// Nom du cookie
          var name: String? { __data["name"] }
          /// Valeur du cookie
          var value: String? { __data["value"] }
          /// Domaine du cookie
          var domain: String? { __data["domain"] }
        }
      }
    }
  }

}