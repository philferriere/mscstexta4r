context("testDetectTopics")

# Load yelpChReviews100 text reviews
load("./data/yelpChineseRestaurantReviews100.rda")

test_that("textaDetectTopics returns expected result structure", {

  skip_on_cran()

  shortStopWordList = c(
    "I", "a", "about", "an", "are", "as", "at", "be", "by", "com", "for", "from", "how", "in", "is", "it",
    "of", "on", "or", "that", "the", "this", "to", "was", "what", "when", "where", "who", "will", "with", "www"
  )
  topicsToExclude = c("beef", "pork")

  operation <- textaDetectTopics(
    documents = yelpChReviews100,      # At least 100 documents
    stopWords = shortStopWordList,     # Stop word list (optional)
    topicsToExclude = topicsToExclude, # Topics to exclude (optional)
    minDocumentsPerWord = 6L,    # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = 15L,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 0L,    # Poll interval (in s, default: 30s, use 0L for async)
    resultsTimeout = 1200L,      # Give up timeout (in s, default: 1200s = 20mn)
    verbose = TRUE               # If set to TRUE, print every poll status to stdout
  )

  # Poll the servers ourselves, until the work completes or until we time out
  resultsPollInterval <- 60L
  resultsTimeout <- 1200L
  startTime <- Sys.time()
  endTime <- startTime + resultsTimeout

  while (Sys.time() <= endTime) {
    sleepTime <- startTime + resultsPollInterval - Sys.time()
    if (sleepTime > 0)
      Sys.sleep(sleepTime)
    startTime <- Sys.time()

    # Poll for results
    res <- textaDetectTopicsStatus(operation, verbose = TRUE)
    if (res$status != "NotStarted" && res$status != "Running")
      break;
  }

  # Results without filtering of any kind:
  # topics (first 10):
  # -------------------
  #  keyPhrase   score
  # ----------- -------
  #    soup       19
  #    beef       10
  #    curry       8
  #     egg        7
  #   flavor       7
  #    pork        7
  #    China       6
  #    roll        6
  #   people       5
  #   review       5

  expect_that(res, is_a("textatopics"))
  expect_that(length(res), equals(9))
  expect_that(res[["status"]], is_a("character"))
  expect_that(res[["status"]], equals("Succeeded"))
  expect_that(res[["operationId"]], is_a("character"))
  expect_that(res[["operationType"]], is_a("character"))
  expect_that(res[["operationType"]], equals("topics"))
  expect_that(res[["originalRequest"]], is_a("request"))
  expect_that(res[["request"]], is_a("request"))
  expect_that(res[["json"]], is_a("character"))
  expect_that(res[["documents"]], is_a("data.frame"))
  expect_that(names(res[["documents"]])[1], equals("id"))
  expect_that(names(res[["documents"]])[2], equals("text"))
  expect_that(res[["topics"]], is_a("data.frame"))
  expect_that(names(res[["topics"]])[1], equals("id"))
  expect_that(names(res[["topics"]])[2], equals("score"))
  expect_that(names(res[["topics"]])[3], equals("keyPhrase"))
  expect_that(res[["topicAssignments"]], is_a("data.frame"))
  expect_that(names(res[["topicAssignments"]])[1], equals("documentId"))
  expect_that(names(res[["topicAssignments"]])[2], equals("topicId"))
  expect_that(names(res[["topicAssignments"]])[3], equals("distance"))
})

test_that("textaDetectTopics with bad params fails with an error", {

  skip_on_cran()

  # documents: bad, other params: good, expect error
  expect_that(textaDetectTopics(documents = 0), throws_error())

  # stopWords: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, stopWords = -1), throws_error())

  # topicsToExclude: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, topicsToExclude = -1), throws_error())

  # minDocumentsPerWord: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, minDocumentsPerWord = -1), throws_error())

  # maxDocumentsPerWord: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, maxDocumentsPerWord = -1), throws_error())

  # resultsPollInterval: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, resultsPollInterval = -1), throws_error())

  # resultsTimeout: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, resultsTimeout = -1), throws_error())

  # verbose: bad, other params: good, expect error
  expect_that(textaDetectTopics(yelpChReviews100, verbose = -1), throws_error())

  url <- mscstexta4r:::textaGetURL()
  key <- mscstexta4r:::textaGetKey()

  # URL: good, key: bad, expect error
  mscstexta4r:::textaSetKey("invalid-key")
  expect_that(textaDetectTopics(yelpChReviews100), throws_error())

  # URL: bad, key: bad, expect error
  mscstexta4r:::textaSetURL("invalid-URL")
  expect_that(textaDetectTopics(yelpChReviews100), throws_error())

  # URL: bad, key: good, expect error
  mscstexta4r:::textaSetKey(key)
  expect_that(textaDetectTopics(yelpChReviews100), throws_error())

  mscstexta4r:::textaSetURL(url)
})
