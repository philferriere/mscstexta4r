
#' @title Initializes the \pkg{mscstexta4r} package.
#'
#' @description This function initializes the Microsoft Cognitive Services
#' Text Analytics REST API key and URL by reading them either from a
#' configuration file or environment variables.
#'
#' This function \strong{MUST} be called right after package load and before calling
#' any \pkg{mscstexta4r} core functions, or these functions will fail.
#'
#' The \code{\link{textaInit}} configuration function will first check to see
#' if the variable \code{MSCS_TEXTANALYTICS_CONFIG_FILE} exists in the system
#' environment. If it does, the package will use that as the path to the
#' configuration file.
#'
#' If \code{MSCS_TEXTANALYTICS_CONFIG_FILE} doesn't exist, it will look for
#' the file \code{.mscskeys.json} in the current user's home directory (that's
#' \code{~/.mscskeys.json} on Linux, and something like \code{C:/Users/Phil/Documents/.mscskeys.json}
#' on Windows). If the file is found, the package will load the API key and URL
#' from it.
#'
#' If using a file, please make sure it has the following structure:
#'
#' \preformatted{
#' {
#'   "textanalyticsurl": "https://westus.api.cognitive.microsoft.com/texta/analytics/v2.0/",
#'   "textanalyticskey": "...MSCS Text Analytics API key goes here..."
#' }
#' }
#'
#' If no configuration file is found, \code{\link{textaInit}} will attempt to
#' pick up its configuration information from two Sys env variables instead:
#'
#' \code{MSCS_TEXTANALYTICS_URL} - the URL for the Text Analytics REST API.
#'
#' \code{MSCS_TEXTANALYTICS_KEY} -  your personal Text Analytics REST API key.
#'
#' \code{\link{textaInit}} needs to be called \emph{only once}, after package
#' load.
#'
#' @export
#'
#' @author Phil Ferriere \email{pferriere@hotmail.com}
#'
#' @examples \dontrun{
#'  textaInit()
#' }
textaInit <- function() {

  # Get config info from file
  configFile <- textaGetConfigFile()

  if (file.exists(configFile)) {

    texta <- jsonlite::fromJSON(configFile)

    if (is.null(texta[["textanalyticskey"]])) {
      assign("texta", NULL, envir = .textapkgenv)
      stop(paste0("mscstexta4r: Field 'textanalyticskey' either empty or missing from ", configFile), call. = FALSE)
    } else if (is.null(texta[["textanalyticsurl"]])) {
      assign("texta", NULL, envir = .textapkgenv)
      stop(paste0("mscstexta4r: Field 'textanalyticsurl' either empty or missing from ", configFile), call. = FALSE)
    } else {
      texta[["textanalyticsconfig"]] <- configFile
      assign("texta", texta, envir = .textapkgenv)
    }

  } else {

    # Get config info from Sys env, if config file is missing
    texta <- list(
      textanalyticskey = Sys.getenv("MSCS_TEXTANALYTICS_KEY", ""),
      textanalyticsurl = Sys.getenv("MSCS_TEXTANALYTICS_URL", ""),
      textanalyticsconfig = ""
    )

    if (texta[["textanalyticskey"]] == "" || texta[["textanalyticsurl"]] == "") {
      assign("texta", NULL, envir = .textapkgenv)
      stop("mscstexta4r: could not load config info from Sys env nor from file", call. = FALSE)
    } else {
      assign("texta", texta, envir = .textapkgenv)
    }

  }
}

## The next seven \pkg{mscstexta4r} internal functions are used to facilitate
## configuration and assist with error handling:
##
## \itemize{
##  \item API URL configuration - \code{\link{textaGetURL}}, \code{\link{textaSetURL}} functions
##  \item API key configuration - \code{\link{textaGetKey}}, \code{\link{textaSetKey}} functions
##  \item Package configuration file - \code{\link{textaGetConfigFile}}, \code{\link{textaSetConfigFile}} functions
##  \item Httr assist - \code{\link{textaHttr}} function
## }
##

## @title Retrieves the Microsoft Cognitive Services Text Analytics REST API key.
##
## Do not call this internal function outside this package.
##
## @return A character string with the value of the API key.
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  textaGetKey()
## }
textaGetKey <- function() {

  if (!is.null(.textapkgenv$texta))
    .textapkgenv$texta[["textanalyticskey"]]
  else
    stop("mscstexta4r: REST API key not found in package environment.", call. = FALSE)

}

## @title Retrieves the Microsoft Cognitive Services Text Analytics REST API base URL.
##
## @return A character string with the value of the REST API base URL.
##
## Do not call this internal function outside this package.
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  textaGetURL()
## }
textaGetURL <- function() {

  if (!is.null(.textapkgenv$texta))
    .textapkgenv$texta[["textanalyticsurl"]]
  else
    stop("mscstexta4r: REST API URL not found in package environment.", call. = FALSE)

}

## @title Retrieves the path to the configuration file.
##
## @return A character string with the path to the configuration file. This path
## may be empty if the package was configured using environment variables.'
##
## Do not call this internal function outside this package.
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  textaGetConfigFile()
## }
textaGetConfigFile <- function() {

  if (!is.null(.textapkgenv$texta))
    .textapkgenv$texta[["textanalyticsconfig"]]
  else {
    textanalyticsconfig = Sys.getenv("MSCS_TEXTANALYTICS_CONFIG_FILE", "")
    if (textanalyticsconfig == "") {
      if (file.exists("~/.mscskeys.json"))
        textanalyticsconfig = "~/.mscskeys.json"
    }
    textanalyticsconfig
  }

}

## @title Sets the Microsoft Cognitive Services Text Analytics REST API key.
##
## @description This function sets the Microsoft Cognitive Services Text
## Analytics REST API key. It is only used for testing purposes, to make sure
## that the package fails with an error when using an invalid key.
##
## Do not call this internal function outside this package.
##
## @param key (character) REST API key to use
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  mscstexta4r:::textaSetKey("invalid-key")
## }
textaSetKey <- function(key) {

  if (!is.null(.textapkgenv$texta)) {
    .textapkgenv$texta[["textanalyticskey"]] <- key
  }
  else
    stop("mscstexta4r: The package wasn't initialized properly.", call. = FALSE)

}

## @title Sets the Microsoft Cognitive Services Text Analytics REST API URL.
##
## @description This function sets the Microsoft Cognitive Services Web Language
## Model REST API URL. It is only used for testing purposes, to make sure that
## the package fails with an error when the URL is misconfigured.
##
## Do not call this internal function outside this package.
##
## @param url (character) REST API URL to use
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  mscstexta4r:::textaSetURL("invalid-URL")
## }
textaSetURL <- function(url) {

  if (!is.null(.textapkgenv$texta))
    .textapkgenv$texta[["textanalyticsurl"]] <- url
  else
    stop("mscstexta4r: The package wasn't initialized properly.", call. = FALSE)

}

## @title Sets the file path for the configuration file.
##
## @description This function sets the file path for the configuration file. It
## is only used for testing purposes, to make sure that the package fails
## gracefully when the the configuration file is missing/compromised.
##
## Do not call this internal function outside this package.
##
## @param path (character) File path for the configuration file
##
## @author Phil Ferriere \email{pferriere@hotmail.com}
##
## @examples \dontrun{
##  textaSetConfigFile("invalid-path")
## }
textaSetConfigFile <- function(path) {

  if (!is.null(.textapkgenv$texta))
    .textapkgenv$texta[["textanalyticsconfig"]] <- path
  else
    stop("mscstexta4r: The package wasn't initialized properly.", call. = FALSE)

}
