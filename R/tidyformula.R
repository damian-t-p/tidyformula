#' Build a formula using `tidyselect`-style selection helperts
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
    replace_match(formula, data, select_helpers),
    envir = env
  )
}

replace_call <- function(x, df, matches) {
  if(rlang::as_string(x[[1]]) %in% matches) {

    match_call <- rlang::call2(rlang::expr(dplyr::select), rlang::expr(df), x)
    
    sub_df     <- eval(match_call)
    var_names  <- names(sub_df)
    
    reformulate(var_names)[[2]]
    
  } else {
    
    as.call(c(
      x[[1]],
      purrr::map(x[-1], ~ replace_match(.x, df, matches))
    ))
    
  }
}

replace_match <- function(x, df, matches) {
  switch_expr(
    x,

    # base case: do nothing
    constant = ,
    symbol = x,

    # recursive case
    pairlist = ,
    call =
      if(x[[1]] != quote(`+`) &&
           is.call(x[[2]]) &&
           rlang::as_string(x[[2]][[1]]) %in% matches)
      {
        distribute(
          x = replace_call(x[[2]], df, matches),
          f = x[[1]],
          supp_args = as.list(x[-c(1, 2)])
        )
      } else {
        replace_call(x, df, matches)
      } 
  )
}
