// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class RateSeriesMutation: GraphQLMutation {
    static let operationName: String = "RateSeries"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RateSeries($id: ID!, $rating: Note!) { rateSeries(id: $id, rating: $rating) { __typename id name rating } }"#
      ))

    public var id: ID
    public var rating: Note

    public init(
      id: ID,
      rating: Note
    ) {
      self.id = id
      self.rating = rating
    }

    public var __variables: Variables? { [
      "id": id,
      "rating": rating
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("rateSeries", RateSeries.self, arguments: [
          "id": .variable("id"),
          "rating": .variable("rating")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RateSeriesMutation.Data.self
      ] }

      /// Rate a series (personal rating)
      var rateSeries: RateSeries { __data["rateSeries"] }

      /// RateSeries
      ///
      /// Parent Type: `Series`
      struct RateSeries: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Series }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("name", PchookGraphQL.SeriesName.self),
          .field("rating", PchookGraphQL.Note?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          RateSeriesMutation.Data.RateSeries.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Series name (e.g. "Le Sorceleur", "Fondation")
        var name: PchookGraphQL.SeriesName { __data["name"] }
        /// Personal rating for the series (1-10)
        var rating: PchookGraphQL.Note? { __data["rating"] }
      }
    }
  }

}