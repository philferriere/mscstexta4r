context("testDetectLanguages")

if (!("package:mscstexta4r" %in% search())) {
  library("mscstexta4r")
  textaInit()
} else {
  textaInit()
}

docsText <- c(
  "The Louvre or the Louvre Museum is the world's largest museum.",
  "Le musée du Louvre est un musée d'art et d'antiquités situé au centre de Paris.",
  "El Museo del Louvre es el museo nacional de Francia.",
  "Il Museo del Louvre a Parigi, in Francia, è uno dei più celebri musei del mondo.",
  "Der Louvre ist ein Museum in Paris."
)
docsText2 <- c(
  "",
  "Le musée du Louvre est un musée d'art et d'antiquités situé au centre de Paris.",
  "El Museo del Louvre es el museo nacional de Francia.",
  "Il Museo del Louvre a Parigi, in Francia, è uno dei più celebri musei del mondo.",
  "Der Louvre ist ein Museum in Paris."
)

test_that("textaDetectLanguages returns expected result structure", {

  skip_on_cran()

  res <- textaDetectLanguages(docsText)

  expect_that(res, is_a("texta"))
  expect_that(length(res), equals(3))
  expect_that(res[["request"]], is_a("request"))
  expect_that(res[["json"]], is_a("character"))
  expect_that(res[["results"]], is_a("data.frame"))
  expect_that(nrow(res[["results"]]), equals(5))
  expect_that(ncol(res[["results"]]), equals(4))
  expect_that(names(res[["results"]])[1], equals("text"))
  expect_that(names(res[["results"]])[2], equals("name"))
  expect_that(names(res[["results"]])[3], equals("iso6391Name"))
  expect_that(names(res[["results"]])[4], equals("score"))

  # documents: one document is empty, other params: good,
  # expect overall success but results to still have an error column
  # note that this is how it is currently handled by the underlying REST API
  # and is not consistent with the way it is handled by the Sentiment REST API
  res <- textaDetectLanguages(docsText2)

  expect_that(res, is_a("texta"))
  expect_that(length(res), equals(3))
  expect_that(res[["request"]], is_a("request"))
  expect_that(res[["json"]], is_a("character"))
  expect_that(res[["results"]], is_a("data.frame"))
  expect_that(ncol(res[["results"]]), equals(5))
  expect_that(names(res[["results"]])[1], equals("text"))
  expect_that(names(res[["results"]])[2], equals("name"))
  expect_that(names(res[["results"]])[3], equals("iso6391Name"))
  expect_that(names(res[["results"]])[4], equals("score"))
  expect_that(names(res[["results"]])[5], equals("error"))
})

test_that("textaDetectLanguages fails with an error", {

  skip_on_cran()

  # documents: bad, other params: good, expect error
  expect_that(textaDetectLanguages(documents = 0), throws_error())

  # numberOfLanguagesToDetect: bad, other params: good, expect error
  expect_that(textaDetectLanguages(docsText, numberOfLanguagesToDetect = -1), throws_error())

  url <- mscstexta4r:::textaGetURL()
  key <- mscstexta4r:::textaGetKey()

  # URL: good, key: bad, expect error
  mscstexta4r:::textaSetKey("invalid-key")
  expect_that(textaDetectLanguages(docsText), throws_error())

  # URL: bad, key: bad, expect error
  mscstexta4r:::textaSetURL("invalid-URL")
  expect_that(textaDetectLanguages(docsText), throws_error())

  # URL: bad, key: good, expect error
  mscstexta4r:::textaSetKey(key)
  expect_that(textaDetectLanguages(docsText), throws_error())

  mscstexta4r:::textaSetURL(url)
})
