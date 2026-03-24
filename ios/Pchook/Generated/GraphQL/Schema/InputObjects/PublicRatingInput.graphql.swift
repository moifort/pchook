// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Note communautaire externe
  struct PublicRatingInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      maxScore: Double,
      score: Double,
      source: String,
      url: String,
      voterCount: Int
    ) {
      __data = InputDict([
        "maxScore": maxScore,
        "score": score,
        "source": source,
        "url": url,
        "voterCount": voterCount
      ])
    }

    /// Note maximale possible
    var maxScore: Double {
      get { __data["maxScore"] }
      set { __data["maxScore"] = newValue }
    }

    /// Note obtenue
    var score: Double {
      get { __data["score"] }
      set { __data["score"] = newValue }
    }

    /// Nom de la plateforme
    var source: String {
      get { __data["source"] }
      set { __data["source"] = newValue }
    }

    /// URL de la page du livre
    var url: String {
      get { __data["url"] }
      set { __data["url"] = newValue }
    }

    /// Nombre de votants
    var voterCount: Int {
      get { __data["voterCount"] }
      set { __data["voterCount"] = newValue }
    }
  }

}