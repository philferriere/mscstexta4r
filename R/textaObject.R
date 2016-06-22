
#' @title The \code{texta} object
#'
#' @description The \code{texta} object exposes formatted results, the REST API JSON
#' response, and the HTTP request:
#'
#' \itemize{
#'   \item \code{result} the results in \code{data.frame} format
#'   \item \code{json} the REST API JSON response
#'   \item \code{request} the HTTP request
#' }
#'
#' @name texta
#'
#' @family texta methods
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
NULL

texta <- function(results = NULL, json = NULL, request = NULL) {

  # Validate input params
  if (!is.null(results))
    stopifnot(is.data.frame(results))
  if (!is.null(json))
    stopifnot(is.character(json), length(json) == 1)
  if (!is.null(request))
    stopifnot(class(request) == "request")

  # Return results as S3 object of class "texta"
  structure(list(results = results, json = json, request = request), class = "texta")
}

is.texta <- function(x) {
  inherits(x, "texta")
}

#' @export
print.texta <- function(x, ...) {

  if (exists("request", where = x)) {
    if (!is.null(x$request)) {
      if (exists("url", where = x$request)) {
        if (!is.null(x$request$url)) {
          cat("texta [", x$request$url, "]\n", sep = "")
        }
      }
    }
  }

  if (exists("results", where = x)) {
    if (!is.null(x$results)) {
      aintNoVT100NoMo <- panderOptions("table.split.table")
      panderOptions("table.split.table", getOption("width"))
      pandoc.table(x$results)
      panderOptions("table.split.table", aintNoVT100NoMo)
    }
  }

}

