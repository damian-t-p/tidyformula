#' Build a formula using `tidyselect`-style selection helpers
#'
#' @description
#' `tidyformula` translate formulas containing `tidyselect`-style
#' [selection helpers][tidyselect::language], expanding these helpers by evaluating
#' [`dplyr::select`] with the relevant selection helper and a supplied data frame.
#'
#' When the selection helper appears as the first argument of a function (this
#' includes interaction designators), that function is distributed across the
#' sum of the selected variables.
#' 
#' @param formula An object of class [`formula`]. Can contain selection helpers
#' to be expanded
#' @param data A data frame whose column names should be used for selection
#' @param select_helpers A character vector. The names of selection helpers to
#' be matched and substituted
#' @param env The environment to associate with the result
#'
#' @section Examples:
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' df <- data.frame(
#'   x1 = rnorm(5),
#'   x2 = rnorm(5),
#'   x3 = rnorm(5),
#'   y  = rnorm(5)
#' )
#' 
#' tidyformula(y ~ num_range("x", 1:2) + z, data = df)
#'
#' tidyformula(y ~ poly(starts_with("x"), 3), data = df)
#'
#' tidyformula( ~ everything()*z, data = df)
#' ```
#' @export
tidyformula <- function(formula,
                        data,
                        select_helpers = .select_helpers,
                        env            = rlang::caller_env()) {
  eval(
    replace_expr(formula, data[NULL, ], select_helpers),
    envir = env
  )
}


