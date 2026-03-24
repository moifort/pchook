// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookListQuery: GraphQLQuery {
    static let operationName: String = "BookList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookList($genre: String, $status: String, $sort: BookSort, $order: SortOrder) { books(genre: $genre, status: $status, sort: $sort, order: $order) { __typename id title authors genre status estimatedPrice awards { __typename name year } rating language seriesName seriesLabel seriesPosition coverImageUrl createdAt } }"#
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
        .field("books", [Book]?.self, arguments: [
          "genre": .variable("genre"),
          "status": .variable("status"),
          "sort": .variable("sort"),
          "order": .variable("order")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BookListQuery.Data.self
      ] }

      /// Liste des livres avec filtres et tri
      var books: [Book]? { __data["books"] }

      /// Book
      ///
      /// Parent Type: `BookListItem`
      struct Book: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookListItem }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID?.self),
          .field("title", String?.self),
          .field("authors", [String]?.self),
          .field("genre", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>?.self),
          .field("estimatedPrice", Double?.self),
          .field("awards", [Award]?.self),
          .field("rating", Int?.self),
          .field("language", String?.self),
          .field("seriesName", String?.self),
          .field("seriesLabel", String?.self),
          .field("seriesPosition", Int?.self),
          .field("coverImageUrl", String?.self),
          .field("createdAt", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookListQuery.Data.Book.self
        ] }

        /// Identifiant unique
        var id: PchookGraphQL.ID? { __data["id"] }
        /// Titre du livre
        var title: String? { __data["title"] }
        /// Auteurs
        var authors: [String]? { __data["authors"] }
        /// Genre littéraire
        var genre: String? { __data["genre"] }
        /// Statut de lecture
        var status: GraphQLEnum<PchookGraphQL.BookStatus>? { __data["status"] }
        /// Prix estimé en euros
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Prix littéraires
        var awards: [Award]? { __data["awards"] }
        /// Note personnelle (0-10)
        var rating: Int? { __data["rating"] }
        /// Langue
        var language: String? { __data["language"] }
        /// Nom de la série
        var seriesName: String? { __data["seriesName"] }
        /// Label dans la série (ex: Tome 3)
        var seriesLabel: String? { __data["seriesLabel"] }
        /// Position dans la série
        var seriesPosition: Int? { __data["seriesPosition"] }
        /// URL de l'image de couverture
        var coverImageUrl: String? { __data["coverImageUrl"] }
        /// Date d'ajout (ISO 8601)
        var createdAt: String? { __data["createdAt"] }

        /// Book.Award
        ///
        /// Parent Type: `Award`
        struct Award: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Award }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
            .field("year", Int?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookListQuery.Data.Book.Award.self
          ] }

          /// Nom du prix
          var name: String? { __data["name"] }
          /// Année d'obtention
          var year: Int? { __data["year"] }
        }
      }
    }
  }

}