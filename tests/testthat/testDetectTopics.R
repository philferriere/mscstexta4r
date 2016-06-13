context("testDetectTopics")

# Load yelpChReviews100 text reviews
load("./data/yelpChineseRestaurantReviews100.rda")

test_that("textaDetectTopics returns expected result structure", {

  skip_on_cran()

  res <- textaDetectTopics(
    documents = yelpChReviews100, # At least 100 documents
    stopWords = NULL,             # Stop word list (optional)
    topicsToExclude = NULL,       # Topics to exclude (optional)
    minDocumentsPerWord = NULL,   # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = NULL,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 30L,    # Poll interval (in s, default: 30s, use 0L for async)
    resultsTimeout = 1200L,       # Give up timeout (in s, default: 1200s = 20mn)
    verbose = FALSE               # If set to TRUE, print every poll status to stdout
  )

  # Expected results
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

test_that("textaDetectTopics topic control works correctly", {

  skip_on_cran()

  topicsToExclude = c("beef", "pork")
  minDocumentsPerWord = 6
  maxDocumentsPerWord = 15

  # Expected results
  # topics (first 10):
  # -------------------
  #  keyPhrase   score
  # ----------- -------
  #    curry       8
  #     egg        7
  #   flavor       7
  #    China       6
  #    roll        6

  res <- textaDetectTopics(
    documents = yelpChReviews100, # At least 100 docs/sentences
    stopWords = NULL,             # Stop word list (optional)
    topicsToExclude = topicsToExclude,       # Topics to exclude (optional)
    minDocumentsPerWord = minDocumentsPerWord,   # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = maxDocumentsPerWord,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 20L,    # Poll interval (in s, default: 20s, use 0L for async)
    resultsTimeout = 600L,        # Give up timeout (in s, default: 600s = 10mn)
    verbose = FALSE                # If set to TRUE, print every poll status to stdout
  )

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

test_that("textaDetectTopics stop word control works correctly", {

  skip_on_cran()

shortStopWordList = c(
  "I", "a", "about", "an", "are", "as", "at", "be", "by", "com", "for", "from", "how", "in", "is", "it",
  "of", "on", "or", "that", "the", "this", "to", "was", "what", "when", "where", "who", "will", "with", "www"
)

#  # Expected results
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

  res <- textaDetectTopics(
    documents = yelpChReviews100, # At least 100 docs/sentences
    stopWords = shortStopWordList,# Stop word list (optional)
    topicsToExclude = NULL,       # Topics to exclude (optional)
    minDocumentsPerWord = NULL,   # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = NULL,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 30L,    # Poll interval (in s, default: 20s, use 0L for async)
    resultsTimeout = 1200L,       # Give up timeout (in s, default: 600s = 10mn)
    verbose = FALSE               # If set to TRUE, print every poll status to stdout
  )

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
