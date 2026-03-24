// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookDetailQuery: GraphQLQuery {
    static let operationName: String = "BookDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookDetail($id: ID!) { book(id: $id) { __typename id title authors publisher publishedDate pageCount genre synopsis isbn language format translator estimatedPrice duration narrators personalNotes status readDate awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } importSource externalUrl createdAt updatedAt coverImageBase64 review { __typename bookId rating readDate reviewNotes createdAt } series { __typename name label position books { __typename id title label position } } } }"#
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
        .field("book", Book?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BookDetailQuery.Data.self
      ] }

      /// Détail d'un livre par son identifiant
      var book: Book? { __data["book"] }

      /// Book
      ///
      /// Parent Type: `Book`
      struct Book: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID?.self),
          .field("title", String?.self),
          .field("authors", [String]?.self),
          .field("publisher", String?.self),
          .field("publishedDate", String?.self),
          .field("pageCount", Int?.self),
          .field("genre", String?.self),
          .field("synopsis", String?.self),
          .field("isbn", String?.self),
          .field("language", String?.self),
          .field("format", GraphQLEnum<PchookGraphQL.BookFormat>?.self),
          .field("translator", String?.self),
          .field("estimatedPrice", Double?.self),
          .field("duration", String?.self),
          .field("narrators", [String]?.self),
          .field("personalNotes", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>?.self),
          .field("readDate", String?.self),
          .field("awards", [Award]?.self),
          .field("publicRatings", [PublicRating]?.self),
          .field("importSource", GraphQLEnum<PchookGraphQL.ImportSource>?.self),
          .field("externalUrl", String?.self),
          .field("createdAt", String?.self),
          .field("updatedAt", String?.self),
          .field("coverImageBase64", String?.self),
          .field("review", Review?.self),
          .field("series", Series?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookDetailQuery.Data.Book.self
        ] }

        /// Identifiant unique
        var id: PchookGraphQL.ID? { __data["id"] }
        /// Titre du livre
        var title: String? { __data["title"] }
        /// Auteurs du livre
        var authors: [String]? { __data["authors"] }
        /// Éditeur
        var publisher: String? { __data["publisher"] }
        /// Date de publication (ISO 8601)
        var publishedDate: String? { __data["publishedDate"] }
        /// Nombre de pages
        var pageCount: Int? { __data["pageCount"] }
        /// Genre littéraire (ex: Romance, SF, Polar)
        var genre: String? { __data["genre"] }
        /// Résumé du livre
        var synopsis: String? { __data["synopsis"] }
        /// Numéro ISBN
        var isbn: String? { __data["isbn"] }
        /// Langue du livre (ex: fr, en)
        var language: String? { __data["language"] }
        /// Format du livre
        var format: GraphQLEnum<PchookGraphQL.BookFormat>? { __data["format"] }
        /// Traducteur
        var translator: String? { __data["translator"] }
        /// Prix estimé en euros
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Durée (livre audio)
        var duration: String? { __data["duration"] }
        /// Narrateurs (livre audio)
        var narrators: [String]? { __data["narrators"] }
        /// Notes personnelles
        var personalNotes: String? { __data["personalNotes"] }
        /// Statut de lecture
        var status: GraphQLEnum<PchookGraphQL.BookStatus>? { __data["status"] }
        /// Date de lecture (ISO 8601)
        var readDate: String? { __data["readDate"] }
        /// Prix littéraires
        var awards: [Award]? { __data["awards"] }
        /// Notes communautaires
        var publicRatings: [PublicRating]? { __data["publicRatings"] }
        /// Source d'import
        var importSource: GraphQLEnum<PchookGraphQL.ImportSource>? { __data["importSource"] }
        /// URL externe (Audible, etc.)
        var externalUrl: String? { __data["externalUrl"] }
        /// Date d'ajout à la bibliothèque (ISO 8601)
        var createdAt: String? { __data["createdAt"] }
        /// Date de dernière modification (ISO 8601)
        var updatedAt: String? { __data["updatedAt"] }
        /// Image de couverture encodée en base64
        var coverImageBase64: String? { __data["coverImageBase64"] }
        /// Critique et note personnelle
        var review: Review? { __data["review"] }
        /// Informations sur la série
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
            .field("name", String?.self),
            .field("year", Int?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Award.self
          ] }

          /// Nom du prix
          var name: String? { __data["name"] }
          /// Année d'obtention
          var year: Int? { __data["year"] }
        }

        /// Book.PublicRating
        ///
        /// Parent Type: `PublicRating`
        struct PublicRating: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.PublicRating }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("source", String?.self),
            .field("score", Double?.self),
            .field("maxScore", Double?.self),
            .field("voterCount", Int?.self),
            .field("url", String?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.PublicRating.self
          ] }

          /// Nom de la plateforme (ex: Hardcover, Goodreads)
          var source: String? { __data["source"] }
          /// Note obtenue
          var score: Double? { __data["score"] }
          /// Note maximale possible
          var maxScore: Double? { __data["maxScore"] }
          /// Nombre de votants
          var voterCount: Int? { __data["voterCount"] }
          /// Lien vers la page du livre sur la plateforme
          var url: String? { __data["url"] }
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
            .field("bookId", PchookGraphQL.ID?.self),
            .field("rating", Int?.self),
            .field("readDate", String?.self),
            .field("reviewNotes", String?.self),
            .field("createdAt", String?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Review.self
          ] }

          /// Identifiant du livre associé
          var bookId: PchookGraphQL.ID? { __data["bookId"] }
          /// Note personnelle (0-10)
          var rating: Int? { __data["rating"] }
          /// Date de lecture (ISO 8601)
          var readDate: String? { __data["readDate"] }
          /// Notes de lecture
          var reviewNotes: String? { __data["reviewNotes"] }
          /// Date de création (ISO 8601)
          var createdAt: String? { __data["createdAt"] }
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
            .field("name", String?.self),
            .field("label", String?.self),
            .field("position", Int?.self),
            .field("books", [Book]?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Series.self
          ] }

          /// Nom de la série
          var name: String? { __data["name"] }
          /// Label du livre dans la série
          var label: String? { __data["label"] }
          /// Position du livre dans la série
          var position: Int? { __data["position"] }
          /// Tous les livres de la série (même langue)
          var books: [Book]? { __data["books"] }

          /// Book.Series.Book
          ///
          /// Parent Type: `SeriesBookEntry`
          struct Book: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesBookEntry }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", PchookGraphQL.ID?.self),
              .field("title", String?.self),
              .field("label", String?.self),
              .field("position", Int?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              BookDetailQuery.Data.Book.Series.Book.self
            ] }

            /// Identifiant du livre
            var id: PchookGraphQL.ID? { __data["id"] }
            /// Titre du livre
            var title: String? { __data["title"] }
            /// Label dans la série (ex: Tome 3)
            var label: String? { __data["label"] }
            /// Position dans la série
            var position: Int? { __data["position"] }
          }
        }
      }
    }
  }

}