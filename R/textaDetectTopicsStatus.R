
#' @title Retrieves the status of a topic detection operation submitted for
#' processing.
#'
#' @description This function retrieves the status of an asynchronous topic
#' detection operation previously submitted for processing. If the operation
#' has reached a 'Succeeded' state, this function will also return the results.
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
#' @param operation (textatopics) textatopics S3 object returned by the original
#' call to \code{\link{textaDetectTopics}}.
#'
#' @param verbose (logical) If set to TRUE, print poll status to stdout.
#'
#' @return An S3 object of the class \code{\link{textatopics}} with the results
#' of the topic detection operation. See \code{\link{textatopics}} for details.
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
#'    # Start async topic detection
#'    operation <- textaDetectTopics(
#'      documents,                  # At least 100 docs/sentences
#'      stopWords = NULL,           # Stop word list (optional)
#'      topicsToExclude = NULL,     # Topics to exclude (optional)
#'      minDocumentsPerWord = NULL, # Threshold to exclude rare topics (optional)
#'      maxDocumentsPerWord = NULL, # Threshold to exclude ubiquitous topics (optional)
#'      resultsPollInterval = 0L    # Poll interval (in s, default: 30s, use 0L for async)
#'    )
#'
#'    # Poll the servers until the work completes or until we time out
#'    resultsPollInterval <- 60L
#'    resultsTimeout <- 1200L
#'    startTime <- Sys.time()
#'    endTime <- startTime + resultsTimeout
#'
#'    while (Sys.time() <= endTime) {
#'      sleepTime <- startTime + resultsPollInterval - Sys.time()
#'      if (sleepTime > 0)
#'        Sys.sleep(sleepTime)
#'      startTime <- Sys.time()
#'
#'      # Poll for results
#'      topics <- textaDetectTopicsStatus(operation)
#'      if (topics$status != "NotStarted" && topics$status != "Running")
#'        break;
#'    }
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

textaDetectTopicsStatus <- function(
  operation,       # An S3 object of class "textatopics"
  verbose = FALSE  # If set to TRUE, print poll status to stdout
) {

  # Validate input params
  stopifnot(is.textatopics(operation))
  stopifnot(is.logical(verbose))

  # Call the MSCS Text Analytics REST API
  res <- textaHttr(
    "GET",
    paste0("operations/", operation$operationId)
  )

  # Extract response
  json <- httr::content(res, "text", encoding = "UTF-8")

  # Build dfs from JSON results
  results <- jsonlite::fromJSON(json)
  status <- results$status
  topics <- NULL
  topicAssignments <- NULL
  if (status == "Succeeded") {
    if (exists('operationProcessingResult', where = results)) {
      if (exists('topics', where = results$operationProcessingResult)) {
        if (exists('topicAssignments', where = results$operationProcessingResult)) {
          topics <- results$operationProcessingResult$topics
          topicAssignments <- results$operationProcessingResult$topicAssignments
        }
      }
    }
  }
  if (verbose == TRUE) {
    cat(sprintf("[operationId: %s, status: %s]\n", operation$operationId, status))
  }

  # Return results as S3 object of class "textatopics"
  textatopics(
    status = status,
    operationId = operation$operationId,
    operationType = operation$operationType,
    documents = operation$documents,
    topics = topics,
    topicAssignments = topicAssignments,
    json = json,
    originalRequest = operation$originalRequest,
    request = res$request
  )
}
