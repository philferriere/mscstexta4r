# testthat testing instructions are at http://r-pkgs.had.co.nz/tests.html
# quick notes:
#   put all your tests in tests/testthat folder
#   each test file should start with test and end in .R
#   since we use secret API keys, don't run the tests on CRAN

library("testthat")

if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) {
  library("mscstexta4r")
  test_check("mscstexta4r")
}
