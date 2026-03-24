// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AnalyzeISBNMutation: GraphQLMutation {
    static let operationName: String = "AnalyzeISBN"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AnalyzeISBN($isbn: String!) { analyzeISBN(isbn: $isbn) { __typename previewId title authors publisher genre isbn language awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } } }"#
      ))

    public var isbn: String

    public init(isbn: String) {
      self.isbn = isbn
    }

    public var __variables: Variables? { ["isbn": isbn] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("analyzeISBN", AnalyzeISBN?.self, arguments: ["isbn": .variable("isbn")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnalyzeISBNMutation.Data.self
      ] }

      /// Scanner un code-barres ISBN. Retourne null si le livre existe déjà.
      var analyzeISBN: AnalyzeISBN? { __data["analyzeISBN"] }

      /// AnalyzeISBN
      ///
      /// Parent Type: `BookPreview`
      struct AnalyzeISBN: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookPreview }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("previewId", String?.self),
          .field("title", String?.self),
          .field("authors", [String]?.self),
          .field("publisher", String?.self),
          .field("genre", String?.self),
          .field("isbn", String?.self),
          .field("language", String?.self),
          .field("awards", [Award]?.self),
          .field("publicRatings", [PublicRating]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AnalyzeISBNMutation.Data.AnalyzeISBN.self
        ] }

        /// Identifiant du preview
        var previewId: String? { __data["previewId"] }
        /// Titre extrait
        var title: String? { __data["title"] }
        /// Auteurs extraits
        var authors: [String]? { __data["authors"] }
        /// Éditeur
        var publisher: String? { __data["publisher"] }
        /// Genre
        var genre: String? { __data["genre"] }
        /// ISBN
        var isbn: String? { __data["isbn"] }
        /// Langue
        var language: String? { __data["language"] }
        /// Prix littéraires
        var awards: [Award]? { __data["awards"] }
        /// Notes communautaires
        var publicRatings: [PublicRating]? { __data["publicRatings"] }

        /// AnalyzeISBN.Award
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
            AnalyzeISBNMutation.Data.AnalyzeISBN.Award.self
          ] }

          /// Nom du prix
          var name: String? { __data["name"] }
          /// Année d'obtention
          var year: Int? { __data["year"] }
        }

        /// AnalyzeISBN.PublicRating
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
            AnalyzeISBNMutation.Data.AnalyzeISBN.PublicRating.self
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
      }
    }
  }

}