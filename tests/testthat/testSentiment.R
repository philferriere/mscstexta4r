context("testSentiment")

docsText <- c(
  "Loved the food, service and atmosphere! We'll definitely be back.",
  "Very good food, reasonable prices, excellent service.",
  "It was a great restaurant.",
  "If steak is what you want, this is the place.",
  "The atmosphere is pretty bad but the food is quite good.",
  "The food is quite good but the atmosphere is pretty bad.",
  "I'm not sure I would come back to this restaurant.",
  "The food wasn't very good.",
  "While the food was good the service was a disappointment.",
  "I was very disappointed with both the service and my entree."
)
docsText2 <- c(
  "",
  "Very good food, reasonable prices, excellent service.",
  "It was a great restaurant.",
  "If steak is what you want, this is the place.",
  "The atmosphere is pretty bad but the food is quite good.",
  "The food is quite good but the atmosphere is pretty bad.",
  "I'm not sure I would come back to this restaurant.",
  "The food wasn't very good.",
  "While the food was good the service was a disappointment.",
  "I was very disappointed with both the service and my entree."
)
docsLanguage <- rep("en", length(docsText))

test_that("textaSentiment returns expected result structure", {

  skip_on_cran()

  res <- textaSentiment(docsText, docsLanguage)

  expect_that(res, is_a("texta"))
  expect_that(length(res), equals(3))
  expect_that(res[["request"]], is_a("request"))
  expect_that(res[["json"]], is_a("character"))
  expect_that(res[["results"]], is_a("data.frame"))
  expect_that(nrow(res[["results"]]), equals(10))
  expect_that(ncol(res[["results"]]), equals(2))
  expect_that(names(res[["results"]])[1], equals("text"))
  expect_that(names(res[["results"]])[2], equals("score"))

})

test_that("textaSentiment fails with an error", {

  skip_on_cran()

  # documents: bad, other params: good, expect error
  expect_that(textaSentiment(documents = 0), throws_error())

  # languages: bad, other params: good, expect error
  expect_that(textaSentiment(docsText, languages = 0), throws_error())

  # documents: one document is empty, other params: good,
  # note that throwing an error is how it's handled by the underlying sentiment REST API
  # but that is not consistent with the way it is handled by the detect languages REST API
  expect_that(textaSentiment(docsText2), throws_error())

  url <- mscstexta4r:::textaGetURL()
  key <- mscstexta4r:::textaGetKey()

  # URL: good, key: bad, expect error
  mscstexta4r:::textaSetKey("invalid-key")
  expect_that(textaSentiment(docsText, docsLanguage), throws_error())

  # URL: bad, key: bad, expect error
  mscstexta4r:::textaSetURL("invalid-URL")
  expect_that(textaSentiment(docsText, docsLanguage), throws_error())

  # URL: bad, key: good, expect error
  mscstexta4r:::textaSetKey(key)
  expect_that(textaSentiment(docsText, docsLanguage), throws_error())

  mscstexta4r:::textaSetURL(url)
})
