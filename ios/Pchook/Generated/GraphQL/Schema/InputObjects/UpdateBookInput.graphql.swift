// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Champs modifiables d'un livre (tous optionnels)
  struct UpdateBookInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      authors: GraphQLNullable<[String]> = nil,
      awards: GraphQLNullable<[AwardInput]> = nil,
      duration: GraphQLNullable<String> = nil,
      estimatedPrice: GraphQLNullable<Double> = nil,
      format: GraphQLNullable<GraphQLEnum<BookFormat>> = nil,
      genre: GraphQLNullable<String> = nil,
      isbn: GraphQLNullable<String> = nil,
      language: GraphQLNullable<String> = nil,
      narrators: GraphQLNullable<[String]> = nil,
      pageCount: GraphQLNullable<Int> = nil,
      personalNotes: GraphQLNullable<String> = nil,
      publicRatings: GraphQLNullable<[PublicRatingInput]> = nil,
      publishedDate: GraphQLNullable<String> = nil,
      publisher: GraphQLNullable<String> = nil,
      readDate: GraphQLNullable<String> = nil,
      series: GraphQLNullable<String> = nil,
      seriesLabel: GraphQLNullable<String> = nil,
      seriesNumber: GraphQLNullable<Double> = nil,
      status: GraphQLNullable<GraphQLEnum<BookStatus>> = nil,
      synopsis: GraphQLNullable<String> = nil,
      title: GraphQLNullable<String> = nil,
      translator: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "authors": authors,
        "awards": awards,
        "duration": duration,
        "estimatedPrice": estimatedPrice,
        "format": format,
        "genre": genre,
        "isbn": isbn,
        "language": language,
        "narrators": narrators,
        "pageCount": pageCount,
        "personalNotes": personalNotes,
        "publicRatings": publicRatings,
        "publishedDate": publishedDate,
        "publisher": publisher,
        "readDate": readDate,
        "series": series,
        "seriesLabel": seriesLabel,
        "seriesNumber": seriesNumber,
        "status": status,
        "synopsis": synopsis,
        "title": title,
        "translator": translator
      ])
    }

    /// Auteurs
    var authors: GraphQLNullable<[String]> {
      get { __data["authors"] }
      set { __data["authors"] = newValue }
    }

    /// Prix littéraires
    var awards: GraphQLNullable<[AwardInput]> {
      get { __data["awards"] }
      set { __data["awards"] = newValue }
    }

    /// Durée (livre audio)
    var duration: GraphQLNullable<String> {
      get { __data["duration"] }
      set { __data["duration"] = newValue }
    }

    /// Prix estimé en euros (null pour supprimer)
    var estimatedPrice: GraphQLNullable<Double> {
      get { __data["estimatedPrice"] }
      set { __data["estimatedPrice"] = newValue }
    }

    /// Format du livre
    var format: GraphQLNullable<GraphQLEnum<BookFormat>> {
      get { __data["format"] }
      set { __data["format"] = newValue }
    }

    /// Genre littéraire (null pour supprimer)
    var genre: GraphQLNullable<String> {
      get { __data["genre"] }
      set { __data["genre"] = newValue }
    }

    /// Numéro ISBN (null pour supprimer)
    var isbn: GraphQLNullable<String> {
      get { __data["isbn"] }
      set { __data["isbn"] = newValue }
    }

    /// Langue (ex: fr, en)
    var language: GraphQLNullable<String> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// Narrateurs (livre audio)
    var narrators: GraphQLNullable<[String]> {
      get { __data["narrators"] }
      set { __data["narrators"] = newValue }
    }

    /// Nombre de pages (null pour supprimer)
    var pageCount: GraphQLNullable<Int> {
      get { __data["pageCount"] }
      set { __data["pageCount"] = newValue }
    }

    /// Notes personnelles
    var personalNotes: GraphQLNullable<String> {
      get { __data["personalNotes"] }
      set { __data["personalNotes"] = newValue }
    }

    /// Notes communautaires
    var publicRatings: GraphQLNullable<[PublicRatingInput]> {
      get { __data["publicRatings"] }
      set { __data["publicRatings"] = newValue }
    }

    /// Date de publication (ISO 8601)
    var publishedDate: GraphQLNullable<String> {
      get { __data["publishedDate"] }
      set { __data["publishedDate"] = newValue }
    }

    /// Éditeur (null pour supprimer)
    var publisher: GraphQLNullable<String> {
      get { __data["publisher"] }
      set { __data["publisher"] = newValue }
    }

    /// Date de lecture (ISO 8601)
    var readDate: GraphQLNullable<String> {
      get { __data["readDate"] }
      set { __data["readDate"] = newValue }
    }

    /// Nom de la série (null pour retirer de la série)
    var series: GraphQLNullable<String> {
      get { __data["series"] }
      set { __data["series"] = newValue }
    }

    /// Label dans la série
    var seriesLabel: GraphQLNullable<String> {
      get { __data["seriesLabel"] }
      set { __data["seriesLabel"] = newValue }
    }

    /// Position dans la série
    var seriesNumber: GraphQLNullable<Double> {
      get { __data["seriesNumber"] }
      set { __data["seriesNumber"] = newValue }
    }

    /// Statut de lecture
    var status: GraphQLNullable<GraphQLEnum<BookStatus>> {
      get { __data["status"] }
      set { __data["status"] = newValue }
    }

    /// Résumé
    var synopsis: GraphQLNullable<String> {
      get { __data["synopsis"] }
      set { __data["synopsis"] = newValue }
    }

    /// Titre du livre
    var title: GraphQLNullable<String> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }

    /// Traducteur (null pour supprimer)
    var translator: GraphQLNullable<String> {
      get { __data["translator"] }
      set { __data["translator"] = newValue }
    }
  }

}