// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class FavoriteSeriesQuery: GraphQLQuery {
    static let operationName: String = "FavoriteSeries"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FavoriteSeries { series(isFavorite: true) { __typename id name rating volumes { __typename id title label position language rating } } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("series", [Series].self, arguments: ["isFavorite": true]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        FavoriteSeriesQuery.Data.self
      ] }

      /// List of all series
      var series: [Series] { __data["series"] }

      /// Series
      ///
      /// Parent Type: `Series`
      struct Series: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Series }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("name", PchookGraphQL.SeriesName.self),
          .field("rating", PchookGraphQL.Note?.self),
          .field("volumes", [Volume].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          FavoriteSeriesQuery.Data.Series.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Series name (e.g. "Le Sorceleur", "Fondation")
        var name: PchookGraphQL.SeriesName { __data["name"] }
        /// Personal rating for the series (1-10)
        var rating: PchookGraphQL.Note? { __data["rating"] }
        /// All volumes in this series (filtered by language when accessed from a book)
        var volumes: [Volume] { __data["volumes"] }

        /// Series.Volume
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
            FavoriteSeriesQuery.Data.Series.Volume.self
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