#' @export
tidyformula <- function(formula, df, matches, env = parent.frame()) {
  eval(
    replace_match(formula, df, matches),
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
