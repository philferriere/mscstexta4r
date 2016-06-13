
## @title Uses the \code{httr} package to send an HTTP request.
##
## @param verb (character) HTTP verb ("GET" or "POST").
##
## @param method (character) Action method to add to the REST API base URL.
##
## @param query (character) Query params to follow the method (optional).
##
## @param query (character) HTTP request body (optional).
##
## @return An S3 object of the class \code{response}.
##
## @author Phil Ferriere \email{pferriere@hotmail.com}

textaHttr <- function(verb, method, query = NULL, body = NULL) {

  VERB <- getExportedValue("httr", verb)
  apikeyHeader <- httr::add_headers("Ocp-Apim-Subscription-Key" = textaGetKey())
  res.request <- paste0(textaGetURL(), method)

  if (is.null(body) || length(body) == 0) {

    res <- VERB(
      res.request,
      httr::content_type_json(),
      apikeyHeader,
      query = query
    )

  } else {

    res <- VERB(
      res.request,
      body = body,
      apikeyHeader,
      query = query
    )

  }

  # Note: The topic detection API returns 202 to signal it's
  # processing the request, so don't fail the call in that case
  if (res$status_code > 202) {

    # Try to extract a formatted error message
    obj <- try({err <- jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"))$error}, silent = TRUE)

    if (class(obj) != "try-error" && !is.null(err)) {

      # We could extract a formatted error message
      if (err$code == "Unspecified")
        err$code <- res$status_code
      list(statusCode = err$code, errorMessage = err$message)

      stop(sprintf("mscstexta4r: %s - %s", err$code, err$message), call. = FALSE)

    } else {

      # We couldn't extract a formatted error message
      err <- httr::http_condition(res, "error")
      errmsg <- httr::content(res, "text", encoding = "UTF-8")
      list(statusCode = err$message, errorMessage = errmsg)

      stop(sprintf("mscstexta4r: %s - %s", err$message, errmsg), call. = FALSE)
    }

  }

  res
}
