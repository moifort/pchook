// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Editable book fields (all optional)
  struct UpdateBookInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      authors: GraphQLNullable<[PersonName]> = nil,
      awards: GraphQLNullable<[AwardInput]> = nil,
      durationMinutes: GraphQLNullable<Int> = nil,
      estimatedPrice: GraphQLNullable<Eur> = nil,
      format: GraphQLNullable<GraphQLEnum<BookFormat>> = nil,
      genre: GraphQLNullable<Genre> = nil,
      isbn: GraphQLNullable<ISBN> = nil,
      language: GraphQLNullable<GraphQLEnum<Language>> = nil,
      narrators: GraphQLNullable<[PersonName]> = nil,
      pageCount: GraphQLNullable<PageCount> = nil,
      personalNotes: GraphQLNullable<String> = nil,
      publicRatings: GraphQLNullable<[PublicRatingInput]> = nil,
      publishedDate: GraphQLNullable<String> = nil,
      publisher: GraphQLNullable<Publisher> = nil,
      readDate: GraphQLNullable<String> = nil,
      series: GraphQLNullable<SeriesName> = nil,
      seriesLabel: GraphQLNullable<SeriesLabel> = nil,
      seriesNumber: GraphQLNullable<SeriesPosition> = nil,
      status: GraphQLNullable<GraphQLEnum<BookStatus>> = nil,
      synopsis: GraphQLNullable<String> = nil,
      title: GraphQLNullable<BookTitle> = nil,
      translator: GraphQLNullable<PersonName> = nil
    ) {
      __data = InputDict([
        "authors": authors,
        "awards": awards,
        "durationMinutes": durationMinutes,
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

    /// Authors
    var authors: GraphQLNullable<[PersonName]> {
      get { __data["authors"] }
      set { __data["authors"] = newValue }
    }

    /// Literary awards
    var awards: GraphQLNullable<[AwardInput]> {
      get { __data["awards"] }
      set { __data["awards"] = newValue }
    }

    /// Duration in minutes (audiobook)
    var durationMinutes: GraphQLNullable<Int> {
      get { __data["durationMinutes"] }
      set { __data["durationMinutes"] = newValue }
    }

    /// Estimated price in euros (null to remove)
    var estimatedPrice: GraphQLNullable<Eur> {
      get { __data["estimatedPrice"] }
      set { __data["estimatedPrice"] = newValue }
    }

    /// Book format
    var format: GraphQLNullable<GraphQLEnum<BookFormat>> {
      get { __data["format"] }
      set { __data["format"] = newValue }
    }

    /// Literary genre (null to remove)
    var genre: GraphQLNullable<Genre> {
      get { __data["genre"] }
      set { __data["genre"] = newValue }
    }

    /// ISBN number (null to remove)
    var isbn: GraphQLNullable<ISBN> {
      get { __data["isbn"] }
      set { __data["isbn"] = newValue }
    }

    /// Language (ISO 639-1)
    var language: GraphQLNullable<GraphQLEnum<Language>> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// Narrators (audiobook)
    var narrators: GraphQLNullable<[PersonName]> {
      get { __data["narrators"] }
      set { __data["narrators"] = newValue }
    }

    /// Page count (null to remove)
    var pageCount: GraphQLNullable<PageCount> {
      get { __data["pageCount"] }
      set { __data["pageCount"] = newValue }
    }

    /// Personal notes
    var personalNotes: GraphQLNullable<String> {
      get { __data["personalNotes"] }
      set { __data["personalNotes"] = newValue }
    }

    /// Community ratings
    var publicRatings: GraphQLNullable<[PublicRatingInput]> {
      get { __data["publicRatings"] }
      set { __data["publicRatings"] = newValue }
    }

    /// Publication date (ISO 8601)
    var publishedDate: GraphQLNullable<String> {
      get { __data["publishedDate"] }
      set { __data["publishedDate"] = newValue }
    }

    /// Publisher (null to remove)
    var publisher: GraphQLNullable<Publisher> {
      get { __data["publisher"] }
      set { __data["publisher"] = newValue }
    }

    /// Read date (ISO 8601)
    var readDate: GraphQLNullable<String> {
      get { __data["readDate"] }
      set { __data["readDate"] = newValue }
    }

    /// Series name (null to remove from series)
    var series: GraphQLNullable<SeriesName> {
      get { __data["series"] }
      set { __data["series"] = newValue }
    }

    /// Label in series
    var seriesLabel: GraphQLNullable<SeriesLabel> {
      get { __data["seriesLabel"] }
      set { __data["seriesLabel"] = newValue }
    }

    /// Position in series
    var seriesNumber: GraphQLNullable<SeriesPosition> {
      get { __data["seriesNumber"] }
      set { __data["seriesNumber"] = newValue }
    }

    /// Reading status
    var status: GraphQLNullable<GraphQLEnum<BookStatus>> {
      get { __data["status"] }
      set { __data["status"] = newValue }
    }

    /// Synopsis
    var synopsis: GraphQLNullable<String> {
      get { __data["synopsis"] }
      set { __data["synopsis"] = newValue }
    }

    /// Book title
    var title: GraphQLNullable<BookTitle> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }

    /// Translator (null to remove)
    var translator: GraphQLNullable<PersonName> {
      get { __data["translator"] }
      set { __data["translator"] = newValue }
    }
  }

}