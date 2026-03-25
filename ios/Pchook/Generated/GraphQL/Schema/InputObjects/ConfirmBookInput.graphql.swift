// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Data to confirm and create a book from a scan
  struct ConfirmBookInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      authors: GraphQLNullable<[PersonName]> = nil,
      estimatedPrice: GraphQLNullable<Eur> = nil,
      format: GraphQLNullable<String> = nil,
      genre: GraphQLNullable<Genre> = nil,
      language: GraphQLNullable<GraphQLEnum<Language>> = nil,
      pageCount: GraphQLNullable<PageCount> = nil,
      previewId: String,
      publisher: GraphQLNullable<Publisher> = nil,
      replaceBookId: GraphQLNullable<BookId> = nil,
      series: GraphQLNullable<SeriesName> = nil,
      seriesLabel: GraphQLNullable<SeriesLabel> = nil,
      seriesNumber: GraphQLNullable<SeriesPosition> = nil,
      status: String,
      synopsis: GraphQLNullable<String> = nil,
      title: GraphQLNullable<BookTitle> = nil,
      translator: GraphQLNullable<PersonName> = nil
    ) {
      __data = InputDict([
        "authors": authors,
        "estimatedPrice": estimatedPrice,
        "format": format,
        "genre": genre,
        "language": language,
        "pageCount": pageCount,
        "previewId": previewId,
        "publisher": publisher,
        "replaceBookId": replaceBookId,
        "series": series,
        "seriesLabel": seriesLabel,
        "seriesNumber": seriesNumber,
        "status": status,
        "synopsis": synopsis,
        "title": title,
        "translator": translator
      ])
    }

    /// Authors (override)
    var authors: GraphQLNullable<[PersonName]> {
      get { __data["authors"] }
      set { __data["authors"] = newValue }
    }

    /// Price (override)
    var estimatedPrice: GraphQLNullable<Eur> {
      get { __data["estimatedPrice"] }
      set { __data["estimatedPrice"] = newValue }
    }

    /// Format (override)
    var format: GraphQLNullable<String> {
      get { __data["format"] }
      set { __data["format"] = newValue }
    }

    /// Genre (override)
    var genre: GraphQLNullable<Genre> {
      get { __data["genre"] }
      set { __data["genre"] = newValue }
    }

    /// Language (override)
    var language: GraphQLNullable<GraphQLEnum<Language>> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// Pages (override)
    var pageCount: GraphQLNullable<PageCount> {
      get { __data["pageCount"] }
      set { __data["pageCount"] = newValue }
    }

    /// Preview identifier
    var previewId: String {
      get { __data["previewId"] }
      set { __data["previewId"] = newValue }
    }

    /// Publisher (override)
    var publisher: GraphQLNullable<Publisher> {
      get { __data["publisher"] }
      set { __data["publisher"] = newValue }
    }

    /// ID of the book to replace (update)
    var replaceBookId: GraphQLNullable<BookId> {
      get { __data["replaceBookId"] }
      set { __data["replaceBookId"] = newValue }
    }

    /// Series (override)
    var series: GraphQLNullable<SeriesName> {
      get { __data["series"] }
      set { __data["series"] = newValue }
    }

    /// Series label (override)
    var seriesLabel: GraphQLNullable<SeriesLabel> {
      get { __data["seriesLabel"] }
      set { __data["seriesLabel"] = newValue }
    }

    /// Series position (override)
    var seriesNumber: GraphQLNullable<SeriesPosition> {
      get { __data["seriesNumber"] }
      set { __data["seriesNumber"] = newValue }
    }

    /// Initial status (to-read or read)
    var status: String {
      get { __data["status"] }
      set { __data["status"] = newValue }
    }

    /// Synopsis (override)
    var synopsis: GraphQLNullable<String> {
      get { __data["synopsis"] }
      set { __data["synopsis"] = newValue }
    }

    /// Title (override)
    var title: GraphQLNullable<BookTitle> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }

    /// Translator (override)
    var translator: GraphQLNullable<PersonName> {
      get { __data["translator"] }
      set { __data["translator"] = newValue }
    }
  }

}