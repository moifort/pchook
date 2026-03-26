// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class SeriesDetailQuery: GraphQLQuery {
    static let operationName: String = "SeriesDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SeriesDetail($id: ID!) { seriesById(id: $id) { __typename id name rating createdAt volumes { __typename id title label position language rating } } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("seriesById", SeriesById?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SeriesDetailQuery.Data.self
      ] }

      /// Series detail by ID
      var seriesById: SeriesById? { __data["seriesById"] }

      /// SeriesById
      ///
      /// Parent Type: `Series`
      struct SeriesById: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Series }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("name", PchookGraphQL.SeriesName.self),
          .field("rating", PchookGraphQL.Note?.self),
          .field("createdAt", PchookGraphQL.DateTime.self),
          .field("volumes", [Volume].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          SeriesDetailQuery.Data.SeriesById.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Series name (e.g. "Le Sorceleur", "Fondation")
        var name: PchookGraphQL.SeriesName { __data["name"] }
        /// Personal rating for the series (1-10)
        var rating: PchookGraphQL.Note? { __data["rating"] }
        /// Date the series was first added to the library
        var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        /// All volumes in this series (filtered by language when accessed from a book)
        var volumes: [Volume] { __data["volumes"] }

        /// SeriesById.Volume
        ///
        /// Parent Type: `SeriesVolume`
        struct Volume: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesVolume }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("title", String.self),
            .field("label", String.self),
            .field("position", PchookGraphQL.SeriesPosition.self),
            .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
            .field("rating", PchookGraphQL.Note?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SeriesDetailQuery.Data.SeriesById.Volume.self
          ] }

          /// Book ID (can be used to fetch full Book details)
          var id: PchookGraphQL.ID { __data["id"] }
          /// Book title
          var title: String { __data["title"] }
          /// Display label in series (e.g. "1", "1.5", "Hors-série", "Préquelle")
          var label: String { __data["label"] }
          /// Sort position in series (e.g. 1, 2, 99 for hors-série)
          var position: PchookGraphQL.SeriesPosition { __data["position"] }
          /// Book language as ISO 639-1 code
          var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
          /// Personal rating of this volume (null if not reviewed)
          var rating: PchookGraphQL.Note? { __data["rating"] }
        }
      }
    }
  }

}