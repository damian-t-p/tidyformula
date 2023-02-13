df1 <- data.frame(
  y  = 1:5,
  x1 = rnorm(5),
  x2 = rnorm(5),
  x3 = rnorm(5)
)

test_that("starts_with works correctly", {

  matched_formula <- tidyformula(
    y ~ starts_with("x") + z,
    df1,
    c("starts_with", "contains")
  )
  
  expect_equal(matched_formula, y ~ x1 + x2 + x3 + z)
})
