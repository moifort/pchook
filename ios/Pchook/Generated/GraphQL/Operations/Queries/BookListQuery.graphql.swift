// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookListQuery: GraphQLQuery {
    static let operationName: String = "BookList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookList($genre: Genre, $status: String, $sort: BookSort, $order: SortOrder) { books(genre: $genre, status: $status, sort: $sort, order: $order) { __typename id title authors genre status estimatedPrice awards { __typename name year } review { __typename rating } language series { __typename name } seriesVolume { __typename label position } coverImageUrl createdAt } }"#
      ))

    public var genre: GraphQLNullable<Genre>
    public var status: GraphQLNullable<String>
    public var sort: GraphQLNullable<GraphQLEnum<BookSort>>
    public var order: GraphQLNullable<GraphQLEnum<SortOrder>>

    public init(
      genre: GraphQLNullable<Genre>,
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
          .field("id", PchookGraphQL.BookId.self),
          .field("title", PchookGraphQL.BookTitle.self),
          .field("authors", [PchookGraphQL.PersonName].self),
          .field("genre", PchookGraphQL.Genre?.self),
          .field("status", PchookGraphQL.BookStatus.self),
          .field("estimatedPrice", PchookGraphQL.Eur?.self),
          .field("awards", [Award].self),
          .field("review", Review?.self),
          .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
          .field("series", Series?.self),
          .field("seriesVolume", SeriesVolume?.self),
          .field("coverImageUrl", PchookGraphQL.Url?.self),
          .field("createdAt", PchookGraphQL.DateTime.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookListQuery.Data.Book.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.BookId { __data["id"] }
        /// Book title
        var title: PchookGraphQL.BookTitle { __data["title"] }
        /// Book authors
        var authors: [PchookGraphQL.PersonName] { __data["authors"] }
        /// Literary genre, comma-separated if multiple (e.g. "LitRPG, Science Fantasy")
        var genre: PchookGraphQL.Genre? { __data["genre"] }
        /// Reading status (to-read | read)
        var status: PchookGraphQL.BookStatus { __data["status"] }
        /// Estimated retail price in euros. Null if unknown
        var estimatedPrice: PchookGraphQL.Eur? { __data["estimatedPrice"] }
        /// Literary awards received. Empty array if none
        var awards: [Award] { __data["awards"] }
        /// Personal review and rating
        var review: Review? { __data["review"] }
        /// Book language as ISO 639-1 code. Null if unknown
        var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
        /// Series this book belongs to
        var series: Series? { __data["series"] }
        /// This book's volume entry in its series (label and position)
        var seriesVolume: SeriesVolume? { __data["seriesVolume"] }
        /// Absolute URL to the cover image. Null if no cover
        var coverImageUrl: PchookGraphQL.Url? { __data["coverImageUrl"] }
        /// Date the book was added to the library
        var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }

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

          /// Short award name (e.g. "Prix Hugo", "Prix Goncourt")
          var name: String { __data["name"] }
          /// Year awarded (e.g. 2023)
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
            .field("rating", PchookGraphQL.Note.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Review.self
          ] }

          /// Personal rating (0-10)
          var rating: PchookGraphQL.Note { __data["rating"] }
        }

        /// Book.Series
        ///
        /// Parent Type: `Series`
        struct Series: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Series }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", PchookGraphQL.SeriesName.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Series.self
          ] }

          /// Series name (e.g. "Le Sorceleur", "Fondation")
          var name: PchookGraphQL.SeriesName { __data["name"] }
        }

        /// Book.SeriesVolume
        ///
        /// Parent Type: `SeriesVolume`
        struct SeriesVolume: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesVolume }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("label", String.self),
            .field("position", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.SeriesVolume.self
          ] }

          /// Display label in series (e.g. "1", "1.5", "Hors-série", "Préquelle")
          var label: String { __data["label"] }
          /// Sort position in series (e.g. 1, 2, 99 for hors-série)
          var position: Int { __data["position"] }
        }
      }
    }
  }

}