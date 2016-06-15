
#' @title Detects the languages used in documents.
#'
#' @description This function returns the language detected in a sentence or
#' documents along with a confidence score between 0 and 1. A scores equal to 1
#' indicates 100% certainty. A total of 120 languages are supported.
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
#' @param documents (character vector) Vector of sentences or documents on
#' which to perform language detection.
#'
#' @param numberOfLanguagesToDetect (integer) Number of languages to detect. Set
#' to 1 by default. Use a higher value if individual documents contain a mix of
#' languages.
#'
#' @return An S3 object of the class \code{\link{texta}}. The results are stored
#' in the \code{results} dataframe inside this object. The dataframe contains
#' the original sentences or documents, the name of the detected language, the
#' ISO 639-1 code of the detected language, and a confidence score. If an error
#' occurred during processing, the dataframe will also have an \code{error}
#' column that describes the error.
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
#'
#' @examples \dontrun{
#'
#'  docsText <- c(
#'    "The Louvre or the Louvre Museum is the world's largest museum.",
#'    "Le musee du Louvre est un musee d'art et d'antiquites situe au centre de Paris.",
#'    "El Museo del Louvre es el museo nacional de Francia.",
#'    "Il Museo del Louvre a Parigi, in Francia, e uno dei piu celebri musei del mondo.",
#'    "Der Louvre ist ein Museum in Paris."
#'  )
#'
#'  tryCatch({
#'
#'    # Detect languages used in documents
#'    docsLanguage <- textaDetectLanguages(
#'      documents = docsText,           # Input sentences or documents
#'      numberOfLanguagesToDetect = 1L  # Number of languages to detect
#'    )
#'
#'    # Class and structure of docsLanguage
#'    class(docsLanguage)
#'    #> [1] "texta"
#
#'    str(docsLanguage, max.level = 1)
#'    #> List of 3
#'    #>  $ results:'data.frame': 5 obs. of  4 variables:
#'    #>  $ json   : chr "{\"documents\":[{\"id\":\"B6e4C\",\"detectedLanguages\": __truncated__ }]}
#'    #>  $ request:List of 7
#'    #>   ..- attr(*, "class")= chr "request"
#'    #>  - attr(*, "class")= chr "texta"
#'
#'    # Print results
#'    docsLanguage
#'    #> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/lan __truncated__ ]
#'    #>
#'    #> -----------------------------------------------------------
#'    #>             text               name    iso6391Name   score
#'    #> ----------------------------- ------- ------------- -------
#'    #>   The Louvre or the Louvre    English      en          1
#'    #> Museum is the world's largest
#'    #>            museum.
#'    #>
#'    #>   Le musee du Louvre est un    French      fr          1
#'    #>  musee d'art et d'antiquites
#'    #>   situe au centre de Paris.
#'    #>
#'    #>   El Museo del Louvre es el   Spanish      es          1
#'    #>  museo nacional de Francia.
#'    #>
#'    #> Il Museo del Louvre a Parigi, Italian      it          1
#'    #>   in Francia, e uno dei piu
#'    #>   celebri musei del mondo.
#'    #>
#'    #>  Der Louvre ist ein Museum in  German      de          1
#'    #>            Paris.
#'    #> -----------------------------------------------------------
#'
#'  }, error = function(err) {
#'
#'    # Print error
#'    geterrmessage()
#'
#'  })
#' }

textaDetectLanguages <- function(
  documents,                      # Input sentences or documents
  numberOfLanguagesToDetect = 1L  # Default: 1L
) {

  # Validate input params
  stopifnot(is.character(documents), length(documents) >= 1)
  stopifnot(is.numeric(numberOfLanguagesToDetect), numberOfLanguagesToDetect >= 1)

  # Buid list of query parameters
  query <- list(numberOfLanguagesToDetect = as.integer(numberOfLanguagesToDetect))

  # Combine documents in df easy to JSON encode in request body
  textaDF <- data.frame(
    id = stringi::stri_rand_strings(length(documents), 8),
    text = documents,
    stringsAsFactors = FALSE
  )

  # Call the MSCS Text Analytics REST API
  res <- textaHttr(
    "POST",
    "languages",
    Filter(Negate(is.null), query),
    jsonlite::toJSON(list(documents = textaDF), auto_unbox = TRUE)
  )

  # Extract response
  json <- httr::content(res, "text", encoding = "UTF-8")

  # Build df from JSON results
  languages <- jsonlite::fromJSON(json)$documents
  languages <- cbind(id = languages$id, do.call("rbind", languages$detectedLanguages), stringsAsFactors = FALSE)
  errors <- jsonlite::fromJSON(json)$errors
  if (length(languages) > 0)
    textaDF <- dplyr::full_join(textaDF, languages, by = "id")
  if (length(errors) > 0) {
    textaDF <- dplyr::full_join(textaDF, errors, by = "id")
    textaDF <- dplyr::rename(textaDF, error = message)
  }

  # Drop unnecessary columns from results
  textaDF$id = NULL

  # Return results as S3 object of class "texta"
  texta(textaDF, json, res$request)
}
