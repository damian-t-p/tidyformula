
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyformula

<!-- badges: start -->
<!-- badges: end -->

`tidyformula` translate formulas containing `tidyselect`-style selection
helpers\], expanding these helpers by evaluating `dplyr::select` with
the relevant selection helper and a supplied data frame.

## Installation

You can install the development version of tidyformula from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("damian-t-p/tidyformula")
#> cli   (3.4.1  -> 3.6.0) [CRAN]
#> vctrs (0.5.1  -> 0.5.2) [CRAN]
#> utf8  (1.2.2  -> 1.2.3) [CRAN]
#> fansi (1.0.3  -> 1.0.4) [CRAN]
#> purrr (0.3.5  -> 1.0.1) [CRAN]
#> dplyr (1.0.10 -> 1.1.0) [CRAN]
#> package 'cli' successfully unpacked and MD5 sums checked
#> package 'vctrs' successfully unpacked and MD5 sums checked
#> package 'utf8' successfully unpacked and MD5 sums checked
#> package 'fansi' successfully unpacked and MD5 sums checked
#> package 'purrr' successfully unpacked and MD5 sums checked
#> package 'dplyr' successfully unpacked and MD5 sums checked
#> 
#> The downloaded binary packages are in
#>  C:\Users\damia\AppData\Local\Temp\Rtmpuk7ZyA\downloaded_packages
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\damia\AppData\Local\Temp\Rtmpuk7ZyA\remotes355438304c4a\damian-t-p-tidyformula-daa87f7/DESCRIPTION' ...  ✔  checking for file 'C:\Users\damia\AppData\Local\Temp\Rtmpuk7ZyA\remotes355438304c4a\damian-t-p-tidyformula-daa87f7/DESCRIPTION'
#>       ─  preparing 'tidyformula':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#> ─  checking for empty or unneeded directories
#> ─  building 'tidyformula_0.0.0.9000.tar.gz'
#>      
#> 
```

## Example

We can build formulas from variables in the following data frams:

``` r
library(tidyformula)

df <- data.frame(
   x1 = rnorm(5),
   x2 = rnorm(5),
   x3 = rnorm(5),
   y  = rnorm(5)
 ) 
```

The simplest usage is adding a selection of variables. The tidy-selected
variables can be combined with other variables in the formula:

``` r
tidyformula(y ~ starts_with("x") + z, data = df)
#> y ~ x1 + x2 + x3 + z
#> <environment: 0x0000019c31441750>
```

The selection helper can have additional arguments, as with `num_range`

``` r
tidyformula(y ~ num_range("x", 1:2) + z, data = df)
#> y ~ x1 + x2 + z
#> <environment: 0x0000019c31441750>
```

When the selection helper appears as the first argument of a function,
that function is distributed across the sum of the selected variables.

This works with single-argument functions

``` r
tidyformula(y ~ log(contains("x")), data = df)
#> y ~ log(x1) + log(x2) + log(x3)
#> <environment: 0x0000019c31441750>
```

as well as multiple-argument ones

``` r
tidyformula(y ~ poly(contains("x"), 3), data = df)
#> y ~ poly(x1, 3) + poly(x2, 3) + poly(x3, 3)
#> <environment: 0x0000019c31441750>
```

This also applies to interaction terms

``` r
tidyformula( ~ everything()*z, data = df)
#> ~x1 * z + x2 * z + x3 * z + y * z
#> <environment: 0x0000019c31441750>
```
