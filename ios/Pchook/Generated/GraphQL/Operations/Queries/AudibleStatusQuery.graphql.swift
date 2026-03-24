// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AudibleStatusQuery: GraphQLQuery {
    static let operationName: String = "AudibleStatus"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AudibleStatus { audibleStatus { __typename connected fetchInProgress libraryCount wishlistCount lastSyncAt lastFetchedAt rawItemCount importTask { __typename phase current total message startedAt completedAt } } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("audibleStatus", AudibleStatus?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AudibleStatusQuery.Data.self
      ] }

      /// Statut de l'intégration Audible
      var audibleStatus: AudibleStatus? { __data["audibleStatus"] }

      /// AudibleStatus
      ///
      /// Parent Type: `AudibleStatus`
      struct AudibleStatus: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AudibleStatus }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("connected", Bool?.self),
          .field("fetchInProgress", Bool?.self),
          .field("libraryCount", Int?.self),
          .field("wishlistCount", Int?.self),
          .field("lastSyncAt", String?.self),
          .field("lastFetchedAt", String?.self),
          .field("rawItemCount", Int?.self),
          .field("importTask", ImportTask?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AudibleStatusQuery.Data.AudibleStatus.self
        ] }

        /// Credentials configurées
        var connected: Bool? { __data["connected"] }
        /// Fetch en cours
        var fetchInProgress: Bool? { __data["fetchInProgress"] }
        /// Nombre de livres dans la bibliothèque
        var libraryCount: Int? { __data["libraryCount"] }
        /// Nombre de livres dans la wishlist
        var wishlistCount: Int? { __data["wishlistCount"] }
        /// Dernière synchronisation (ISO 8601)
        var lastSyncAt: String? { __data["lastSyncAt"] }
        /// Dernier fetch (ISO 8601)
        var lastFetchedAt: String? { __data["lastFetchedAt"] }
        /// Nombre d'éléments bruts
        var rawItemCount: Int? { __data["rawItemCount"] }
        /// État de la tâche d'import
        var importTask: ImportTask? { __data["importTask"] }

        /// AudibleStatus.ImportTask
        ///
        /// Parent Type: `ImportTaskState`
        struct ImportTask: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.ImportTaskState }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("phase", String?.self),
            .field("current", Int?.self),
            .field("total", Int?.self),
            .field("message", String?.self),
            .field("startedAt", String?.self),
            .field("completedAt", String?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AudibleStatusQuery.Data.AudibleStatus.ImportTask.self
          ] }

          /// Phase (idle, running, paused, cancelled, completed, failed)
          var phase: String? { __data["phase"] }
          /// Nombre d'éléments traités
          var current: Int? { __data["current"] }
          /// Nombre total d'éléments
          var total: Int? { __data["total"] }
          /// Message de progression
          var message: String? { __data["message"] }
          /// Date de début (ISO 8601)
          var startedAt: String? { __data["startedAt"] }
          /// Date de fin (ISO 8601)
          var completedAt: String? { __data["completedAt"] }
        }
      }
    }
  }

}