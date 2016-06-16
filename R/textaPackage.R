
#' @title R Client for the Microsoft Cognitive Services Text Analytics REST API
#'
#' @description \pkg{mscstexta4r} is a client/wrapper/interface for the Microsoft
#' Cognitive Services (MSCS) Text Analytics (Text Analytics) REST API. To use this
#' package, you MUST have a valid account with \url{https://www.microsoft.com/cognitive-services}.
#' Once you have an account, Microsoft will provide you with a (free) API key
#' you can use with this package.
#'
#' @section The MSCS Text Analytics REST API:
#'
#' Microsoft Cognitive Services -- formerly known as Project Oxford -- are a set
#' of APIs, SDKs and services that developers can use to add AI features to
#' their apps. Those features include emotion and video detection; facial,
#' speech and vision recognition; as well as speech and NLP.
#'
#' The Text Analytics REST API provides tools for NLP and is documented at
#' \url{https://www.microsoft.com/cognitive-services/en-us/text-analytics/documentation}.
#' This API supports the following operations:
#'
#' \itemize{
#'  \item Sentiment analysis - Is a sentence or document generally positive or negative?
#'  \item Topic detection - What's being discussed across a list of documents/reviews/articles?
#'  \item Language detection - What language is a document written in?
#'  \item Key talking points extraction - What's being discussed in a single document?
#' }
#'
#' @section \pkg{mscstexta4r} Functions:
#'
#' The following \pkg{mscstexta4r} core functions are used to wrap the
#' MSCS Text Analytics REST API:
#'
#' \itemize{
#'  \item Sentiment analysis - \code{\link{textaSentiment}} function
#'  \item Topic detection - \code{\link{textaDetectTopics}} and \code{\link{textaDetectTopicsStatus}} functions
#'  \item Language detection - \code{\link{textaDetectLanguages}} function
#'  \item Extraction of key talking points - \code{\link{textaKeyPhrases}} function
#' }
#'
#' The \code{\link{textaInit}} configuration function is used to set the REST
#' API URL and the private API key. It needs to be called \emph{only once},
#' after package load, or the core functions will not work properly.
#'
#' @section Prerequisites:
#'
#' To use the \pkg{mscstexta4r} R package, you \strong{MUST} have a valid
#' account with Microsoft Cognitive Services (see \url{https://www.microsoft.com/cognitive-services/en-us/pricing}
#' for details). Once you have an account, Microsoft will provide you with an
#' API key listed under your subscriptions. After you've configured
#' \pkg{mscstexta4r} with your API key (as explained in the next section), you
#' will be able to call the Text Analytics REST API from R, up to your
#' maximum number of transactions per month and per minute.
#'
#' @section Package Loading and Configuration:
#'
#' After loading the \pkg{mscstexta4r} package with the \code{library()} function,
#' you must call the \code{\link{textaInit}} before you can call any of
#' the core \pkg{mscstexta4r} functions.
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
#' @section Synchronous vs Asynchronous Execution:
#'
#' All but \strong{ONE} core text analytics functions execute exclusively in
#' synchronous mode: \code{\link{textaDetectTopics}} is the only function that
#' can be executed either synchronously or asynchronously. Why? Because topic
#' detection is typically a "batch" operation meant to be performed on thousands
#' of related documents (product reviews, research articles, etc.).
#'
#' What's the difference?
#'
#' When \code{\link{textaDetectTopics}} executes synchronously, you must wait
#' for it to finish before you can move on to the next task. When
#' \code{\link{textaDetectTopics}} executes asynchronously, you can move on to
#' something else before topic detection has completed. In the latter case, you
#' will need to call \code{\link{textaDetectTopicsStatus}} periodically yourself
#' until the Microsoft Cognitive Services server complete topic detection and
#' results become available.
#'
#' When to run which mode?
#'
#' If you're performing topic detection in batch mode (from an R script), we
#' recommend using the \code{\link{textaDetectTopics}} function in synchronous
#' mode, in which case it will return only after topic detection has completed.
#'
#' \strong{IMPORTANT NOTE: If you're calling \code{\link{textaDetectTopics}} in
#' synchronous mode within the R console REPL (interactive mode), it will
#' appear as if the console has hanged. This is \emph{EXPECTED}. The function
#' hasn't crashed. It is simply in "sleep mode", activating itself periodically
#' and then going back to sleep, until the results have become available. In
#' sleep mode, even though it appears "stuck", \code{\link{textaDetectTopics}}
#' doesn't use any CPU resources. While the function is operating in sleep
#' mode, you \emph{WILL NOT} be able to use the console before the function
#' completes. If you need to operate the console while topic detection is being
#' performed by the Microsoft Cognitive services servers, you should call
#' \code{\link{textaDetectTopics}} in asynchronous mode and then call
#' \code{\link{textaDetectTopicsStatus}} yourself repeteadly afterwards, until
#' results are available.}
#
#' @section S3 Objects of the Classes \code{\link{texta}} and \code{\link{textatopics}}:
#'
#' The sentiment analysis, language detection, and key talking points extraction
#' functions of the \pkg{mscstexta4r} package return S3 objects of the class
#' \code{\link{texta}}. The \code{\link{texta}} object exposes results collected
#' in a single dataframe, the REST API JSON response, and the original HTTP
#' request.
#'
#' The functions \code{\link{textaDetectTopics}} returns a S3 object of the
#' class \code{\link{textatopics}}. The \code{\link{textatopics}} object exposes
#' formatted results using several dataframes (documents and their IDs, topics
#' and their IDs, which topics are assigned to which documents), the REST API
#' JSON response (should you care), and the HTTP request (mostly for debugging
#' purposes).'
#'
#' @section Error Handling:
#'
#' The MSCS Text Analytics API is a REST API. HTTP requests over a network and
#' the Internet can fail. Because of congestion, because the web site is down
#' for maintenance, because of firewall configuration issues, etc. There are
#' many possible points of failure.
#'
#' The API can also fail if you've exhausted your call volume quota or are
#' exceeding the API calls rate limit. Unfortunately, MSCS does not expose an
#' API you can query to check if you're about to exceed your quota for instance.
#' The only way you'll know for sure is by looking at the error code returned
#' after an API call has failed.
#'
#' To help with error handling, we recommend the systematic use of
#' \code{tryCatch()} when calling \pkg{mscstexta4r}'s core functions. Its
#' mechanism may appear a bit daunting at first, but it is well documented at \url{http://www.inside-r.org/r-doc/base/signalCondition}.
#' We use it in many of the code examples.
#'
#' @importFrom methods is
#' @importFrom httr add_headers content http_condition content_type_json
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom pander pandoc.table panderOptions
#' @importFrom stringi stri_rand_strings
#' @importFrom dplyr full_join rename
#' @importFrom utils head tail
#' @name mscstexta4r
#' @docType package
#' @author Phil Ferriere \email{pferriere@hotmail.com}
#' @keywords package
NULL
