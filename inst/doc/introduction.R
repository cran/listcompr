## ---- echo = FALSE, message = FALSE-------------------------------------------
library(listcompr)

## -----------------------------------------------------------------------------
gen.vector(i, i = 1:10, i %% 3 == 0 || i %% 4 == 0)

## -----------------------------------------------------------------------------
gen.vector(i, i = 1:10, i %% 3 == 0 || i %% 4 == 0, i != 8)

## -----------------------------------------------------------------------------
gen.list(c(i, j), i = 1:3, j = 1:3, i <= j)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(i, j), i = 1:3, j = i:3)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(x, y), x = 1:20, y = 1:20, (x-2)*(y-2) == x*y/2)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(width = x, height = y, inner_tiles), x = 1:20, y = 1:20, 
                     inner_tiles = (x-2)*(y-2), inner_tiles == x*y/2)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a_1, a_2, a_3), a_ = 1:4, a_1 < a_2, a_2 < a_3)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a_1, ..., a_5), a_ = 1:5, a_1 + ... + a_5 == 6)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a_1, ..., a_5), a_ = 1:5, sum(a_1, ..., a_5) == 10, 
                     gen.logical.and(a_i <= a_(i+1), i = 1:4))
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a_1, ..., a_4), a_ = 1:4, 
                     gen.logical.and(a_i != a_j, i = 1:4, j = (i+1):4))
knitr::kable(df[1:8,])

## ---- results="asis"----------------------------------------------------------
dices <- gen.data.frame(c(a_1, ..., a_3), a_ = 1:6)
res <- dplyr::filter(dices, !!gen.logical.or(a_i == 6 & a_j == 6, i = 1:3, j = (i+1):3))
knitr::kable(res[1:8,])

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a, sumdiv = sum(gen.vector(x, x = 1:(a-1), a %% x == 0))), a = 2:10)
knitr::kable(df)

## ---- results="asis"----------------------------------------------------------
df <- gen.data.frame(c(a, sumdiv, perfect = (sumdiv == a)), a = 2:10, 
                     sumdiv = sum(gen.vector(x, x = 1:(a-1), a %% x == 0)))
knitr::kable(df)

## -----------------------------------------------------------------------------
gen.vector("size: {x}x{y} tiles, where {x*y/2} tiles are at the border/inner",
           x = 1:20, y = 1:20, (x-2)*(y-2) == x*y/2)

## -----------------------------------------------------------------------------
gen.named.list("divisors_of_{a}", gen.vector(x, x = 1:(a-1), a %% x == 0), a = 5:10)

## ---- results="asis"----------------------------------------------------------
m <- gen.named.matrix("divisors_{a}", gen.named.vector("{x}", a %% x == 0, x = 2:10), 
                      a = 90:95, byrow = TRUE)
knitr::kable(m)

## ---- results="asis"----------------------------------------------------------
m <- gen.named.matrix("divisors_{a}",
        gen.named.vector("{x}", if (a %% x == 0) "factor = {a/x}" else "no", x = 2:10), 
        a = 90:95, byrow = TRUE)
knitr::kable(m)

