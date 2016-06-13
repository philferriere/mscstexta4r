
#' @title Detects the top topics in a group of text documents.
#'
#' @description This function returns the top detected topics for a list of
#' submitted text documents. A topic is identified with a key phrase, which can
#' be one or more related words. At least 100 text documents must be submitted,
#' however this API is designed to detect topics across hundreds to thousands of
#' documents. For best performance, limit each document to a short, human
#' written text paragraph such as review, conversation or user feedback.
#'
#' You can provide a list of stop words to control which words or documents are
#' filtered out. You can also supply a list of topics to exclude from the
#' response. Finally, you can also provide min/max word frequency count
#' thresholds to exclude rare/ubiquitous document topics.
#'
#' We recommend using the \code{\link{textaDetectTopics}} function in synchronous
#' mode, in which case it will return only after topic detection has completed.
#' If you decide to call this function in asynchronous mode, you will need to
#' call the \code{\link{textaDetectTopicsStatus}} function periodically yourself
#' until the Microsoft Cognitive Services server complete topic detection and
#' results become available.
#'
#' \strong{IMPORTANT NOTE: If you're calling \code{\link{textaDetectTopics}} in
#' synchronous mode within the R console REPL (interactive mode), it will
#' appear as if the console has hanged. This is \emph{EXPECTED}. The function
#' hasn't crashed. It is simply in "sleep mode", activating itself periodically
#' and then going back to sleep, until the results have become available. In
#' sleep mode, even though it appears "stuck", \code{\link{textaDetectTopics}}
#' dodesn't use any CPU resources. While the function is operating in sleep
#' mode, you \emph{WILL NOT} be able to use the console until the function
#' completes. If need to operate the console while topic detection is being
#' performed by the Microsoft Cognitive services servers, you should call
#' \code{\link{textaDetectTopics}} in asynchronous mode and then call
#' \code{\link{textaDetectTopicsStatus}} yourself repeteadly afterwards, until
#' results are available.}
#'
#' Note that one transaction is charged per text document submitted.
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
#' which to perform topic detection. At least 100 text documents must be
#' submitted.
#'
#' @param stopWords (character vector) Vector of stop words to ignore while
#' performing topic detection (optional)
#'
#' @param topicsToExclude (character vector) Vector of topics to exclude from
#' the response (optional)
#'
#' @param minDocumentsPerWord (integer) Words that occur in less than this many
#' documents are ignored. Use this parameter to help exclude rare document
#' topics. Omit to let the service choose appropriate value. (optional)
#'
#' @param maxDocumentsPerWord (integer) Words that occur in more than this many
#' documents are ignored. Use this parameter to help exclude ubiquitous document
#' topics. Omit to let the service choose appropriate value. (optional)
#'
#' @param resultsPollInterval (integer) Interval (in seconds) at which this function
#' will query the Microsoft Cognitive Services servers for results (optional,
#' default: 30L). If set to 0L, this function will return immediately and you
#' will have to call \code{\link{textaDetectTopicsStatus}} periodically to collect
#' results. If set to a non-zero integer value, this function will only return
#' after all results have been collected. It does so by repeatedly calling
#' \code{\link{textaDetectTopicsStatus}} on its own until topic detection has
#' completed. In the latter case, you do not need to call
#' \code{\link{textaDetectTopicsStatus}}.
#'
#' @param resultsTimeout (integer) Interval (in seconds) at which point this function
#' will give up and stop querying the Microsoft Cognitive Services servers for
#' results (optional, default: 1200L). As soon as all results are available,
#' this function will return them to the caller. If the Microsoft Cognitive
#' Services servers within resultsTimeout seconds, this function will
#' stop polling the servers and return the most current results.
#'
#' @param verbose (logical) If set to TRUE, print every poll status to stdout.
#'
#' @return An S3 object of the class \code{\link{textatopics}}. The results are stored in
#' the \code{results} dataframes inside this object. See \code{\link{textatopics}}
#' for details. In the synchronous case (i.e., the function only returns after
#' completion), the dataframes contain the documents, the topics, and which
#' topics are assigned to which documents. In the asynchonous case (i.e., the
#' function returns immediately), the dataframes contain the documents, their
#' unique identifiers, their current operation status code, but they don't
#' contain the topics yet, nor their assignments. To get the topics and their
#' assignments, you must call \code{\link{textaDetectTopicsStatus}} until the
#' Microsoft Services servers have completed topic detection.
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
#'
#' @examples \dontrun{
#'  load("./data/yelpChineseRestaurantReviews.rda")
#'  set.seed(1234)
#'  documents <- sample(yelpChReviews$text, 1000)
#'
#'  tryCatch({
#'
#'    # Detect top topics in group of documents
#'    topics <- textaDetectTopics(
#'      documents,                  # At least 100 documents
#'      stopWords = NULL,           # Stop word list (optional)
#'      topicsToExclude = NULL,     # Topics to exclude (optional)
#'      minDocumentsPerWord = NULL, # Threshold to exclude rare topics (optional)
#'      maxDocumentsPerWord = NULL, # Threshold to exclude ubiquitous topics (optional)
#'      resultsPollInterval = 30L,  # Poll interval (in s, default:30s, use 0L for async)
#'      resultsTimeout = 1200L,     # Give up timeout (in s, default: 1200s = 20mn)
#'      verbose = TRUE              # If set to TRUE, print every poll status to stdout
#'    )
#'
#'    # Class and structure of topics
#'    class(topics)
#'    #> [1] "textatopics"
#'
#'    str(topics, max.level = 1)
#'    #> List of 8
#'    #> $ status          : chr "Succeeded"
#'    #> $ operationId     : chr "30334a3e1e28406a80566bb76ff04884"
#'    #> $ operationType   : chr "topics"
#'    #> $ documents       :'data.frame':  1000 obs. of  2 variables:
#'    #> $ topics          :'data.frame':  71 obs. of  3 variables:
#'    #> $ topicAssignments:'data.frame':  502 obs. of  3 variables:
#'    #> $ json            : chr "{\"status\":\"Succeeded\",\"createdDateTime\": __truncated__ }
#'    #> $ request         :List of 7
#'    #> ..- attr(*, "class")= chr "request"
#'    #> - attr(*, "class")= chr "textatopics"
#'
#'    # Print results
#'    topics
#'    #> textatopics [https://westus.api.cognitive.microsoft.com/text/analytics/ __truncated__ ]
#'    #> status: Succeeded
#'    #> operationId: 30334a3e1e28406a80566bb76ff04884
#'    #> operationType: topics
#'    #> topics (first 20):
#'    #> ------------------------
#'    #>    keyPhrase      score
#'    #> ---------------- -------
#'    #>     portions       35
#'    #>   noodle soup      30
#'    #>    vegetables      20
#'    #>       tofu         19
#'    #>      garlic        17
#'    #>     Eggplant       15
#'    #>       Pad          15
#'    #>      combo         13
#'    #> Beef Noodle Soup   13
#'    #>      House         12
#'    #>      entree        12
#'    #>     wontons        12
#'    #>     Pei Wei        12
#'    #>  mongolian beef    11
#'    #>       crab         11
#'    #>      Panda         11
#'    #>       bean         10
#'    #>    dumplings        9
#'    #>     veggies         9
#'    #>      decor          9
#'    #> ------------------------
#'
#'  }, error = function(err) {
#'
#'    # Print error
#'    geterrmessage()
#'
#'  })
#' }

textaDetectTopics <- function(
  documents,                  # At least 100 documents
  stopWords = NULL,           # Stop word list (optional)
  topicsToExclude = NULL,     # Topics to exclude (optional)
  minDocumentsPerWord = NULL, # Threshold to exclude rare topics (optional)
  maxDocumentsPerWord = NULL, # Threshold to exclude ubiquitous topics (optional)
  resultsPollInterval = 30L,  # Poll interval (in s, default: 30s, use 0L for async)
  resultsTimeout = 1200L,     # Give up timeout (in s, default: 1200s = 20mn)
  verbose = FALSE             # If set to TRUE, print every poll status to stdout
) {

  # Validate input params
  stopifnot(is.character(documents), length(documents) >= 1)
  if (!is.null(stopWords))
    stopifnot(is.character(stopWords), length(stopWords) >= 1)
  if (!is.null(topicsToExclude))
    stopifnot(is.character(topicsToExclude), length(topicsToExclude) >= 1)
  if (!is.null(minDocumentsPerWord))
    stopifnot(is.numeric(minDocumentsPerWord), minDocumentsPerWord >= 0)
  if (!is.null(maxDocumentsPerWord))
    stopifnot(is.numeric(maxDocumentsPerWord), maxDocumentsPerWord >= 0)
  stopifnot(is.numeric(resultsPollInterval), resultsPollInterval >= 0)
  stopifnot(is.numeric(resultsTimeout), resultsTimeout >= 0)
  stopifnot(is.logical(verbose))

  # Buid list of query parameters
  query <- list(
    minDocumentsPerWord = minDocumentsPerWord,
    maxDocumentsPerWord = maxDocumentsPerWord
  )

  # Combine documents in df easy to JSON encode in request body
  textaDF <- data.frame(
    id = stringi::stri_rand_strings(length(documents), 5),
    text = documents,
    stringsAsFactors = FALSE
  )
  body <- list(
    documents = textaDF,
    stopWords = stopWords,
    topicsToExclude = topicsToExclude
  )

  # Call the MSCS Text Analytics REST API
  if (verbose == TRUE) {
    cat("[Submitting topic detection operation...]\n")
  }
  res <- textaHttr(
    "POST",
    "topics",
    Filter(Negate(is.null), query),
    jsonlite::toJSON(
      Filter(Negate(is.null), body),
      auto_unbox = TRUE
    )
  )

  # Extract response, headers, original request, and operation ID
  json <- httr::content(res, "text", encoding = "UTF-8")
  headers <- httr::headers(res)
  operationId <- utils::tail(strsplit(headers$`operation-location`, split = "/")[[1]], 1)
  originalRequest <- res$request

  # Poll the servers until the work completes or until we time out
  operation <- textatopics(
    operationId = operationId,
    operationType = "topics",
    documents = textaDF,
    originalRequest = originalRequest
  )
  if (resultsPollInterval > 0L) {

    startTime <- Sys.time()
    endTime <- startTime + as.integer(resultsTimeout)

    while (Sys.time() <= endTime) {
      sleepTime <- startTime + as.integer(resultsPollInterval) - Sys.time()
      if (sleepTime > 0) {
        if (verbose == TRUE) {
          cat(sprintf(
            "[Sleeping for %d s, timeout in %d s...]\n",
            as.integer(as.difftime(sleepTime, units = "secs")),
            as.integer(difftime(endTime, Sys.time(), units = "secs"))
          ))
        }
        Sys.sleep(sleepTime)
      }
      startTime <- Sys.time()

      # Poll for results
      results <- textaDetectTopicsStatus(operation)
      if (verbose == TRUE) {
        cat(sprintf("[operationId: %s, status: %s]\n", operationId, results$status))
      }
      if (results$status != "NotStarted" && results$status != "Running")
        break;
    }

    if (verbose == TRUE && results$status != "Succeeded") {
      cat(sprintf("[operationId: %s timed out!]\n", operationId))
    }

  } else {
    # Poll just once and return
    results <- textaDetectTopicsStatus(operation)
    if (verbose == TRUE) {
      cat(sprintf("[operationId: %s, status: %s]\n", operationId, results$status))
    }
  }

  results
}
