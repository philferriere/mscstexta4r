
#' @title Returns the key talking points in sentences or documents.
#'
#' @description This function returns the the key talking points in a list of
#' sentences or documents. The following languages are currently supported:
#' English, German, Spanish and Japanese.
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
#' which to extract key talking points.
#'
#' @param languages (character vector) Languages of the sentences or documents,
#' supported values: "en"(English, default), "de"(German), "es"(Spanish),
#' "fr"(French), "ja"(Japanese)
#'
#' @return An S3 object of the class \code{\link{texta}}. The results are stored
#' in the \code{results} dataframe inside this object. The dataframe contains
#' the original sentences or documents and their key talking points. If an error
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
#'    # Get key talking points in documents
#'    docsKeyPhrases <- textaKeyPhrases(
#'      documents = docsText,    # Input sentences or documents
#'      languages = docsLanguage
#'      # "en"(English, default)|"de"(German)|"es"(Spanish)|"fr"(French)|"ja"(Japanese)
#'    )
#'
#'    # Class and structure of docsKeyPhrases
#'    class(docsKeyPhrases)
#'    #> [1] "texta"
#
#'    str(docsKeyPhrases, max.level = 1)
#'    #> List of 3
#'    #>  $ results:'data.frame': 10 obs. of  2 variables:
#'    #>  $ json   : chr "{\"documents\":[{\"keyPhrases\":[\"atmosphere\",\"food\", __truncated__ ]}]}
#'    #>  $ request:List of 7
#'    #>   ..- attr(*, "class")= chr "request"
#'    #>  - attr(*, "class")= chr "texta"
#'
#'    # Print results
#'    docsKeyPhrases
#'    #> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases]
#'    #>
#'    #> -----------------------------------------------------------
#'    #>              text                       keyPhrases
#'    #> ------------------------------ ----------------------------
#'    #>  Loved the food, service and    atmosphere, food, service
#'    #>  atmosphere! We'll definitely
#'    #>            be back.
#'    #>
#'    #>   Very good food, reasonable   reasonable prices, good food
#'    #>   prices, excellent service.
#'    #>
#'    #>   It was a great restaurant.         great restaurant
#'    #>
#'    #>   If steak is what you want,           steak, place
#'    #>       this is the place.
#'    #>
#'    #>  The atmosphere is pretty bad        atmosphere, food
#'    #>  but the food is quite good.
#'    #>
#'    #>  The food is quite good but the       food, atmosphere
#'    #>   atmosphere is pretty bad.
#'    #>
#'    #> I'm not sure I would come back          restaurant
#'    #>      to this restaurant.
#'    #>
#'    #>   The food wasn't very good.               food
#'    #>
#'    #>  While the food was good the          service, food
#'    #> service was a disappointment.
#'    #>
#'    #>  I was very disappointed with        service, entree
#'    #>    both the service and my
#'    #>            entree.
#'    #> -----------------------------------------------------------
#'
#'  }, error = function(err) {
#'
#'    # Print error
#'    geterrmessage()
#'
#'  })
#' }

textaKeyPhrases <- function(
  documents,                                 # Input sentences or documents
  languages = rep("en", length(documents))
  # "en"(English, default)|"de"(German)|"es"(Spanish)|"fr"(French)|"ja"(Japanese)
) {

  # Validate input params
  stopifnot(is.character(documents), length(documents) >= 1)
  stopifnot(is.character(languages), length(languages) >= 1, length(languages) == length(documents))

  # Combine documents in df easy to JSON encode in request body
  textaDF <- data.frame(
    language = languages,
    id = stringi::stri_rand_strings(length(documents), 8),
    text = documents,
    stringsAsFactors = FALSE
  )

  # Call the MSCS Text Analytics REST API
  res <- textaHttr(
    "POST",
    "keyPhrases",
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
