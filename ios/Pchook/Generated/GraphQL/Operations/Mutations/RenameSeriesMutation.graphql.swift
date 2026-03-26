// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class RenameSeriesMutation: GraphQLMutation {
    static let operationName: String = "RenameSeries"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RenameSeries($id: ID!, $name: SeriesName!) { renameSeries(id: $id, name: $name) { __typename id name rating } }"#
      ))

    public var id: ID
    public var name: SeriesName

    public init(
      id: ID,
      name: SeriesName
    ) {
      self.id = id
      self.name = name
    }

    public var __variables: Variables? { [
      "id": id,
      "name": name
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("renameSeries", RenameSeries.self, arguments: [
          "id": .variable("id"),
          "name": .variable("name")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RenameSeriesMutation.Data.self
      ] }

      /// Rename a series
      var renameSeries: RenameSeries { __data["renameSeries"] }

      /// RenameSeries
      ///
      /// Parent Type: `Series`
      struct RenameSeries: PchookGraphQL.SelectionSet {
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
          RenameSeriesMutation.Data.RenameSeries.self
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