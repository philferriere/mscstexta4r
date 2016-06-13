
#' @title Assesses the sentiment of sentences or documents.
#'
#' @description This function returns a numeric score between 0 and 1 with
#' scores close to 1 indicating positive sentiment and scores close to 0
#' indicating negative sentiment.
#'
#' Sentiment score is generated using classification techniques. The input
#' features of the classifier include n-grams, features generated from
#' part-of-speech tags, and word embeddings. English, French, Spanish and
#' Portuguese text are supported.
#'
#' Internally, this function invokes the Microsoft Cognitive Services Text
#' Analytics REST API documented at \url{https://www.microsoft.com/cognitive-services/en-us/text-analytics/documentation}.
#'
#' You MUST have a valid Microsoft Cognitive Services account and an API key for
#' this function to work properly. See \url{https://www.microsoft.com/cognitive-services/en-us/pricing}
#' for details.
#'
#' @export
#'
#' @param documents (character vector) Vector of sentences or documents for
#' which to assess sentiment.
#'
#' @param languages (character vector) Languages of the sentences or documents,
#' supported values: "en"(English, default), "es"(Spanish), "fr"(French),
#' "pt"(Portuguese)
#'
#' @return An S3 object of the class \code{\link{texta}}. The results are stored
#' in the \code{results} dataframe inside this object. The dataframe contains
#' the original sentences or documents and their sentiment score. If an error
#' occurred during processing, the dataframe will also have an \code{error}
#' column that describes the error.
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
#'
#' @examples \dontrun{
#'
#'  docsText <- c(
#'    "Loved the food, service and atmosphere! We'll definitely be back.",
#'    "Very good food, reasonable prices, excellent service.",
#'    "It was a great restaurant.",
#'    "If steak is what you want, this is the place.",
#'    "The atmosphere is pretty bad but the food is quite good.",
#'    "The food is quite good but the atmosphere is pretty bad.",
#'    "I'm not sure I would come back to this restaurant.",
#'    "The food wasn't very good.",
#'    "While the food was good the service was a disappointment.",
#'    "I was very disappointed with both the service and my entree."
#'  )
#'  docsLanguage <- rep("en", length(docsText))
#'
#'  tryCatch({
#'
#'    # Perform sentiment analysis
#'    docsSentiment <- textaSentiment(
#'      documents = docsText,    # Input sentences or documents
#'      languages = docsLanguage
#'      # "en"(English, default)|"es"(Spanish)|"fr"(French)|"pt"(Portuguese)
#'    )
#'
#'    # Class and structure of docsSentiment
#'    class(docsSentiment)
#'    #> [1] "texta"
#
#'    str(docsSentiment, max.level = 1)
#'    #> List of 3
#'    #>  $ results:'data.frame': 10 obs. of  2 variables:
#'    #>  $ json   : chr "{\"documents\":[{\"score\":0.9903013,\"id\":\"hDgKc\", __truncated__ }]}
#'    #>  $ request:List of 7
#'    #>   ..- attr(*, "class")= chr "request"
#'    #>  - attr(*, "class")= chr "texta"
#'
#'    # Print results
#'    docsSentiment
#'    #> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment]
#'    #>
#'    #> --------------------------------------
#'    #>              text               score
#'    #> ------------------------------ -------
#'    #>  Loved the food, service and    0.9847
#'    #>  atmosphere! We'll definitely
#'    #>            be back.
#'    #>
#'    #>  Very good food, reasonable     0.9831
#'    #>  prices, excellent service.
#'    #>
#'    #>  It was a great restaurant.     0.9306
#'    #>
#'    #>  If steak is what you want,     0.8014
#'    #>      this is the place.
#'    #>
#'    #> The atmosphere is pretty bad    0.4998
#'    #>  but the food is quite good.
#'    #>
#'    #> The food is quite good but the   0.475
#'    #>   atmosphere is pretty bad.
#'    #>
#'    #> I'm not sure I would come back  0.2857
#'    #>      to this restaurant.
#'    #>
#'    #>   The food wasn't very good.    0.1877
#'    #>
#'    #>  While the food was good the   0.08727
#'    #> service was a disappointment.
#'    #>
#'    #>  I was very disappointed with  0.01877
#'    #>    both the service and my
#'    #>            entree.
#'    #> --------------------------------------
#'
#'  }, error = function(err) {
#'
#'    # Print error
#'    geterrmessage()
#'
#'  })
#' }

textaSentiment <- function(
  documents,                                 # Input sentences or documents
  languages = rep("en", length(documents))
  # "en"(English, default)|"es"(Spanish)|"fr"(French)|"pt"(Portuguese)
) {

  # Validate input params
  stopifnot(is.character(documents), length(documents) >= 1)
  stopifnot(is.character(languages), length(languages) >= 1, length(languages) == length(documents))

  # Combine documents in df easy to JSON encode in request body
  textaDF <- data.frame(
    language = languages,
    id = stringi::stri_rand_strings(length(documents), 5),
    text = documents,
    stringsAsFactors = FALSE
  )

  # Call the MSCS Text Analytics REST API
  res <- textaHttr(
    "POST",
    "sentiment",
    body = jsonlite::toJSON(list(documents = textaDF), auto_unbox = TRUE)
  )

  # Extract response
  json <- httr::content(res, "text", encoding = "UTF-8")

  # Build df from JSON results
  results <- jsonlite::fromJSON(json)$documents
  errors <- jsonlite::fromJSON(json)$errors
  if (length(results) > 0)
    textaDF <- dplyr::full_join(textaDF, results, by = "id")
  if (length(errors) > 0) {
    textaDF <- dplyr::full_join(textaDF, errors, by = "id")
    textaDF <- dplyr::rename(textaDF, error = message)
  }

  # Drop unnecessary columns from results
  textaDF$language = NULL
  textaDF$id = NULL

  # Return results as S3 object of class "texta"
  texta(textaDF, json, res$request)
}
