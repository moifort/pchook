// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookListQuery: GraphQLQuery {
    static let operationName: String = "BookList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookList($genre: String, $status: String, $sort: BookSort, $order: SortOrder) { books(genre: $genre, status: $status, sort: $sort, order: $order) { __typename id title authors genre status estimatedPrice awards { __typename name year } language coverImageUrl createdAt review { __typename rating } series { __typename name label position } } }"#
      ))

    public var genre: GraphQLNullable<String>
    public var status: GraphQLNullable<String>
    public var sort: GraphQLNullable<GraphQLEnum<BookSort>>
    public var order: GraphQLNullable<GraphQLEnum<SortOrder>>

    public init(
      genre: GraphQLNullable<String>,
      status: GraphQLNullable<String>,
      sort: GraphQLNullable<GraphQLEnum<BookSort>>,
      order: GraphQLNullable<GraphQLEnum<SortOrder>>
    ) {
      self.genre = genre
      self.status = status
      self.sort = sort
      self.order = order
    }

    public var __variables: Variables? { [
      "genre": genre,
      "status": status,
      "sort": sort,
      "order": order
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("books", [Book].self, arguments: [
          "genre": .variable("genre"),
          "status": .variable("status"),
          "sort": .variable("sort"),
          "order": .variable("order")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BookListQuery.Data.self
      ] }

      /// Book list with filters and sorting
      var books: [Book] { __data["books"] }

      /// Book
      ///
      /// Parent Type: `Book`
      struct Book: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("title", String.self),
          .field("authors", [String].self),
          .field("genre", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>.self),
          .field("estimatedPrice", Double?.self),
          .field("awards", [Award].self),
          .field("language", String?.self),
          .field("coverImageUrl", String?.self),
          .field("createdAt", PchookGraphQL.DateTime.self),
          .field("review", Review?.self),
          .field("series", Series?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookListQuery.Data.Book.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Book title
        var title: String { __data["title"] }
        /// Book authors
        var authors: [String] { __data["authors"] }
        /// Literary genre (e.g. Romance, Sci-Fi, Thriller)
        var genre: String? { __data["genre"] }
        /// Reading status
        var status: GraphQLEnum<PchookGraphQL.BookStatus> { __data["status"] }
        /// Estimated price in euros
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Literary awards
        var awards: [Award] { __data["awards"] }
        /// Book language (e.g. fr, en)
        var language: String? { __data["language"] }
        /// Cover image URL
        var coverImageUrl: String? { __data["coverImageUrl"] }
        /// Date added to library
        var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        /// Personal review and rating
        var review: Review? { __data["review"] }
        /// Series information
        var series: Series? { __data["series"] }

        /// Book.Award
        ///
        /// Parent Type: `Award`
        struct Award: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Award }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("year", Int?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Award.self
          ] }

          /// Award name
          var name: String { __data["name"] }
          /// Year awarded
          var year: Int? { __data["year"] }
        }

        /// Book.Review
        ///
        /// Parent Type: `Review`
        struct Review: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Review }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("rating", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Review.self
          ] }

          /// Personal rating (0-10)
          var rating: Int { __data["rating"] }
        }

        /// Book.Series
        ///
        /// Parent Type: `SeriesInfo`
        struct Series: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesInfo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("label", String.self),
            .field("position", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Series.self
          ] }

          /// Series name
          var name: String { __data["name"] }
          /// Book label in series
          var label: String { __data["label"] }
          /// Book position in series
          var position: Int { __data["position"] }
        }
      }
    }
  }

}