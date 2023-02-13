distribute <- function(x, f, supp_args = NULL) {

  switch_expr(
    x,

    constant = x,
    symbol = rlang::call2(f, x, !!!supp_args),

    pairlist = ,
    call = as.call(c(
      x[[1]],
      purrr::map(x[-1], ~ distribute(.x, f, supp_args))
    ))
  )
}
