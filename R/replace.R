#' Replaces matching selection helpers in a call with the selected variables
#'
#' @param x A call
#' @param df A data frame
#' @param matches A character vector of selection helpers to match
#'
#' @noRd
replace_call <- function(x, df, matches) {
  if(rlang::as_string(x[[1]]) %in% matches) {

    match_call <- rlang::call2(rlang::expr(dplyr::select), rlang::expr(df), x)
    
    sub_df     <- eval(match_call)
    var_names  <- names(sub_df)
    
    reformulate(var_names)[[2]]
    
  } else if (x[[1]] != quote(`+`) &&
               is.call(x[[2]]) &&
               rlang::as_string(x[[2]][[1]]) %in% matches)  {

    # The call is a function other than `+` whose first argument is a selection helper
    # In this case, the function should be distributes over the selected variables
    
    distribute(
          x = replace_call(x[[2]], df, matches),
          f = x[[1]],
          supp_args = as.list(x[-c(1, 2)])
    )
    
  } else {
    
    as.call(c(
      x[[1]],
      purrr::map(x[-1], ~ replace_expr(.x, df, matches))
    ))
    
  }
}

#' Replaces matching selection helpers in an expr with the selected variables
#'
#' @param x An expression
#' @param ... Other arguments to pass to replace_call
#'
#' @noRd
replace_expr <- function(x, ...) {
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
