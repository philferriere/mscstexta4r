
#' @title The \code{textatopics} object
#'
#' @description The \code{textatopics} object exposes formatted results for the
#' \code{\link{textaDetectTopics}} API, this REST API's JSON response, and the
#' HTTP request:
#'
#' \itemize{
#'   \item \code{status} the operation's current status ("NotStarted"|"Running"|"Succeeded"|"Failed")
#'   \item \code{documents} a \code{data.frame} with the documents and a unique
#'   string ID for each
#'   \item \code{topics} a \code{data.frame} with the identified topics, a
#'   unique string ID for each, and a prevalence score for each topic (count of
#'   documents assigned to topic)
#'   \item \code{topicAssignments} a \code{data.frame} with all the topics
#'   (identified by their topic ID) assigned to each document (identified by
#'   their document ID), and a distance score for each topic assignment (between
#'   0 and 1; the lower the distance score the stronger the topic affiliation)
#'   \item \code{json} the REST API JSON response
#'   \item \code{request} the HTTP request
#' }
#'
#' @name textatopics
#'
#' @family textatopics methods
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
NULL

textatopics <- function(
  status = NULL,
  operationId = NULL,
  operationType = NULL,
  documents = NULL,
  topics = NULL,
  topicAssignments = NULL,
  json = NULL,
  originalRequest = NULL,
  request = NULL
  ) {

  # Validate input params
  if (!is.null(status))
    stopifnot(is.character(status), length(status) == 1)
  if (!is.null(operationId))
    stopifnot(is.character(operationId), length(operationId) == 1)
  if (!is.null(operationType))
    stopifnot(is.character(operationType), length(operationType) == 1)
  if (!is.null(documents))
    stopifnot(is.data.frame(documents))
  if (!is.null(topics))
    stopifnot(is.data.frame(topics))
  if (!is.null(topicAssignments))
    stopifnot(is.data.frame(topicAssignments))
  if (!is.null(json))
    stopifnot(is.character(json), length(json) == 1)
  if (!is.null(originalRequest))
    stopifnot(class(originalRequest) == "request")
  if (!is.null(request))
    stopifnot(class(request) == "request")

  # Return results as S3 object of class "textatopics"
  structure(
    list(
      status = status,
      operationId = operationId,
      operationType = operationType,
      documents = documents,
      topics = topics,
      topicAssignments = topicAssignments,
      json = json,
      originalRequest = originalRequest,
      request = request
    ),
    class = "textatopics"
  )
}

is.textatopics <- function(x) {
  inherits(x, "textatopics")
}

#' @export
print.textatopics <- function(x, ...) {

  if (exists("originalRequest", where = x)) {
    if (!is.null(x$originalRequest)) {
      if (exists("url", where = x$originalRequest)) {
        if (!is.null(x$originalRequest$url)) {
          cat("textatopics [", x$originalRequest$url, "]\n", sep = "")
        }
      }
    }
  }

  if (exists("status", where = x)) {
    if (!is.null(x$status)) {
      cat("status: ", x$status, "\n", sep = "")
    }
  }

  if (exists("operationId", where = x)) {
    if (!is.null(x$operationId)) {
      cat("operationId: ", x$operationId, "\n", sep = "")
    }
  }

  if (exists("operationType", where = x)) {
    if (!is.null(x$operationType)) {
      cat("operationType: ", x$operationType, "\n", sep = "")
    }
  }

  if (x$status == "Succeeded") {
    if (exists("topics", where = x)) {
      if (!is.null(x$topics)) {
        aintNoVT100NoMo <- panderOptions("table.split.table")
        panderOptions("table.split.table", getOption("width"))
        if (nrow(x$topics) > 20)
          cat("topics (first 20):\n", sep = "")
        else
          cat("topics:\n", sep = "")
        firstTopics <- utils::head(x$topics[with(x$topics, order(-score)),c(3,2)], 20)
        row.names(firstTopics) <- NULL
        pandoc.table(firstTopics)
        panderOptions("table.split.table", aintNoVT100NoMo)
      }
    }
  }
}
