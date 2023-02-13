#' Build a formula using `tidyselect`-style selection helperts
#'
#' `tidyformula` translate formulas containing `tidyselect`-style
#' [selection helpers][tidyselect::language], expanding these helpers by evaluating
#' [`dplyr::select`] with the relevant selection helper and a supplied data frame.
#' 
#' @param formula An object of class [`formula`]. Can contain selection helpers
#' to be expanded
#' @param df A data frame whose column names should be used for selection
#' @param select_helpers A character vector. The names of selection helpers to
#' be matched and substituted
#' @param env The environment to associate with the result
#'
#' @section Examples:
#' 
#' ```{r, comment = "#>", collapse = TRUE}
#' df1 <- data.frame(
#'   x1 = rnorm(5),
#'   x2 = rnorm(5),
#'   y  = rnorm(5)
#' )
#' 
#' tidyformula(y ~ starts_with("x") + z, data = df1)
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
      list(x[[1]]),
      purrr::map(x[-1], ~ replace_match(.x, df, matches))
    ))
  }
}

replace_match <- function(x, ...) {
  switch_expr(
    x,

    # base case: do nothing
    constant = ,
    symbol = x,

    # recursive case
    pairlist = ,
    call = replace_call(x, ...)
  )
}
