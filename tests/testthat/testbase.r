test_that("Trivial tests", {
  expect_error(gen.list(), "argument \"expr\" is missing")
  expect_error(gen.vector(), "argument \"expr\" is missing")
  expect_error(gen.data.frame(), "argument \"expr\" is missing")
  expect_error(gen.list(1), "no named variables are given")
  expect_error(gen.vector("a"), "no named variables are given")
  expect_error(gen.data.frame(1), "no named variables are given")
  x <- 1
  expect_equal(gen.list(c(x, y), y = 2), list(c(1, 2)))
  expect_equal(gen.list(x, x = 2), list(2))
})


test_that("Empty result tests", {
  expect_warning(gen.vector(x + y, x = 1, y = 2:3, x > y), "no variable ranges detected, returning empty result")
  expect_warning(gen.data.frame(c(a = 1, b = x), x = 2:3, x > 3), "no variable ranges detected, returning empty result")
})

test_that("Basic list and vector tests", {
  expect_equal(gen.list(x, x = 1:3), lapply(1:3, identity))
  expect_error(gen.list(x + y, y = x:2, x = 1:2), "could not evaluate variable range of 'y'")
  
  y <- 1
  expect_equal(gen.vector(x + y, x = 1:3), 2:4)
  expect_equal(gen.data.frame(x + y, x = 1:2, y = 1:2), data.frame(V1 = c(2, 3, 3, 4)))
  expect_equal(gen.list(c(x, y), x = 1:2, y = x:2), list(c(1, 1), c(1, 2), c(2, 2)))
  expect_equal(gen.vector(sum(c(x_1, ..., x_4) * c(1, -1)), x_ = 1:2), c(0, 1, -1, 0, 1, 2, 0, 1, -1, 0, -2, -1, 0, 1, -1, 0))
  
  expect_equal(gen.list(list(x_1, ..., x_2), x_ = 1:2), list(list(1, 1), list(2, 1), list(1, 2), list(2,2)))
  
  expect_equal(gen.list(c(x_1, x_2), x_ = 1:2, x_1 == x_3, x_2 == x_3), list(c(1, 1), c(2,2)))
  expect_equal(gen.list(c(x_1, x_2), x_ = 1:2, x_1 == x_3 && x_2 == x_3), list(c(1, 1), c(2,2)))
  expect_equal(gen.vector(x_1 + x_2, x_ = (1:3)*10, x_1 = 1:2), c(11, 12, 21, 22, 31, 32))
})

test_that("Logical tests", {
  expect_equal(gen.logical.or(x_i == x_(i+1), i = 1:2, j = i:2), quote(x_1 == x_2 | (x_1 == x_2 | x_2 == x_3)))
  expect_equal(gen.logical.and(x_i == x_j, i = 1:3, j = (i+1):3), quote(x_1 == x_2 & (x_1 == x_3 & x_2 == x_3)))
  expect_equal(gen.logical.and(x_i == x_j, i = 1:3, j = i:3, i != j), quote(x_1 == x_2 & (x_1 == x_3 & x_2 == x_3)))
  expect_equal(gen.logical.and(x_(i_1) == x_(i_2), i_ = 1:3, i_1 < i_2), quote(x_1 == x_2 & (x_1 == x_3 & x_2 == x_3)))
})

test_that("Logical list tests", {
  permutations <- gen.list(c(x_1, ..., x_4), x_ = 1:4, gen.logical.and(x_i != x_j, i = 1:4, j = (i+1):4))
  expect_equal(length(permutations), factorial(4))
  expect_equal(length(unique(permutations)), factorial(4))
  expect_equal(vapply(permutations, function(x) length(unique(x)), 0), rep(4, factorial(4)))
  
  expect_equal(gen.data.frame(c(a = x_1, b = x_2, c = x_3), x_ = 1:2, gen.logical.or(x_i != x_j, i=1:3, j=1:3)),
               data.frame(a = c(2,1,2,1,2,1), b = c(1,2,2,1,1,2), c = c(1,1,1,2,2,2)))
  
  
  expect_equal(gen.list(c(x_1, ..., x_4), x_ = 1:2, gen.logical.and(x_i == x_j, i = 1:4, j=(i+1):4)), list(c(1,1,1,1),c(2,2,2,2)))
  
  expect_equal(gen.list(c(x_1, ..., x_4), x_ = 0:-1, gen.logical.and(x_(i_1) == x_(i_2), i_ = 4:1, i_1 > i_2)), list(c(0,0,0,0),c(-1,-1,-1,-1)))
})


test_that("Basic data frame tests", {
  expect_equal(gen.data.frame(c(a = x, b = y), x = 1:3, y = 1:3, x < y), data.frame(a = c(1, 1, 2), b = c(2, 3, 3)))
  expect_equal(gen.data.frame(c(a = a_1 + 10, b = a_2), a_ = 1:3, a_2 != 2),
               data.frame(a = c(11, 12, 13, 11, 12, 13), b = c(1, 1, 1, 3, 3, 3)))
  
  expect_equal(gen.data.frame(c(a = x_1, b = x_2), x_ = 1:2, x_1 == x_3, x_2 == x_3), data.frame(a = c(1, 2), b = c(1, 2)))
  
  expect_equal(gen.data.frame(c(a = a, sumdiv = sum(gen.vector(x, x = 1:(a-1), a %% x == 0))), a = 2:10), 
               data.frame(a = c(2, 3, 4, 5, 6, 7, 8, 9, 10), sumdiv = c(1, 1, 3, 1, 6, 1, 7, 4, 8)))
})

test_that("Named lists/vectors/dataframes tests", {
  
  expect_equal(gen.named.list("a_{i}", i, i = 1:4), list(a_1 = 1, a_2 = 2, a_3 = 3, a_4 = 4))
  
  expect_equal(gen.data.frame(c(a_1 = x_1,..., a_3 = x_3), x_ = 1:2),
               data.frame(a_1 = c(1L, 2L, 1L, 2L, 1L, 2L, 1L, 2L), a_2 = c(1L, 1L, 2L, 2L, 1L, 1L, 2L, 2L), a_3 = c(1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L)))

  expect_equal(gen.named.vector("a{10+a}", 2*a, a=1:2), c(a11 = 2, a12 = 4))
  
  expect_equal(gen.named.list("sum({c(a_1, ..., a_4)})", sum(a_1, ..., a_4), a_ = 1:2, a_1 + ... + a_4 <= 5),
               list("sum(c(1, 1, 1, 1))" = 4, "sum(c(2, 1, 1, 1))" = 5, "sum(c(1, 2, 1, 1))" = 5, "sum(c(1, 1, 2, 1))" = 5, "sum(c(1, 1, 1, 2))" = 5))
  
  expect_equal(gen.named.list.expr("a_{i}", a_i, i = 1:5), quote(list(a_1 = a_1, a_2 = a_2, a_3 = a_3, a_4 = a_4, a_5 = a_5)))
  
  expect_equal(gen.named.vector.expr("v{v_1}", v_1, v_ = 1:2), quote(c(v1 = 1L, v2 = 2L)))

  expect_equal(gen.data.frame(gen.named.vector.expr("a_{i}", a_i, i = 1:3), a_ = 1:2),
               data.frame(a_1 = c(1L, 2L, 1L, 2L, 1L, 2L, 1L, 2L), a_2 = c(1L, 1L, 2L, 2L, 1L, 1L, 2L, 2L), a_3 = c(1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L)))
  
  expect_equal(gen.named.data.frame("col_{i}", 10 * i + c(a = 1, b = 2), i = 1:2),
               data.frame(a = c(11, 21), b = c(12, 22), row.names = c("col_1",  "col_2")))
})

test_that("three dots tests", {
  df_res <- expand.grid(list(1:2,1:2,1:2), KEEP.OUT.ATTRS = FALSE)
  names(df_res) <- c("V1", "V2", "V3")
  expect_equal(gen.data.frame(c(i_1, ..., i_3), i_ = 1:2), df_res)
  expect_equal(gen.vector(sum(c(i_1, ..., i_4)), i_ = 0:1), c(0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4))
  expect_equal(gen.vector(sum(i_1, ..., i_4),    i_ = 0:1), c(0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4))
  
  expect_equal(gen.list(c(0, val_1, ..., val_4, 100), val_ = 1:5, val_1 < val_2, val_2 < val_3, val_3 < val_4),
               list(c(0, 1, 2, 3, 4, 100), c(0, 1, 2, 3, 5, 100),  c(0, 1, 2, 4, 5, 100), c(0, 1, 3, 4, 5, 100), c(0, 2, 3, 4, 5, 100)))
  
  expect_equal(gen.list(c(a_3, ..., a_1, a_3 + ... + a_1, a_3 - ... - a_1), a_ = 1:5, 1 + (a_1 + ... + a_3) + 1 == 7),
               list(c(1, 1, 3, 5, -3), c(1, 2, 2, 5, -3), c(1, 3, 1, 5, -3), c(2, 1, 2, 5, -1), c(2, 2, 1, 5, -1), c(3, 1, 1, 5, 1)))
  
  expect_equal(gen.data.frame(c(a1 = a_1, a2 = a_2, a3 = a_3, a4 = a_4), a_ = 1:3, a_1 + ... + a_4 == 5),
               data.frame(a1 = c(2, 1, 1, 1), a2 = c(1, 2, 1, 1), a3 = c(1, 1, 2, 1), a4 = c(1, 1, 1, 2)))
  
  expect_equal(gen.data.frame(c(a_1 = a_1, ..., a_4 = a_4), a_ = 1), data.frame(a_1 = 1, a_2 = 1, a_3 = 1, a_4 = 1))
  
  expect_error(gen.data.frame(c(a_1 = a_2, ..., a_4 = a_4), a_ = 1:2),
               "the name range 'a_1, ..., a_4' has a different length than the expression range 'a_2, ..., a_4'")
})

test_that("nesting tests", {
  expect_equal(gen.vector(a, a = 2:100, a == sum(gen.vector(x, x = 1:(a-1), a %% x == 0))), c(6, 28))
})
  
test_that("helper function tests", {
  f <- function(x) { x %% 3 == 0 }
  expect_equal(gen.vector(x, x = 1:10, f(x)), c(3, 6, 9))
  g <- function(a, b) { 10 * a + b }
  expect_equal(gen.vector(g(a_1, a_2), a_ = 1:10, f(a_1), a_2 %% 4 == 0), c(34, 64, 94, 38, 68, 98))
  x <- 1
  y <- 1
  expect_equal(gen.data.frame(c(a = g(x, y)), x = 2:(2+f(3))), data.frame(a = c(21, 31)))
})

test_that("lambda function test", {
  expect_equal(gen.data.frame(c(num = a, sumdiv = {sum(gen.vector(x, x = 1:(a-1), a %% x == 0))}), a = 3:6),
               data.frame(num = c(3, 4, 5, 6), sumdiv = c(1, 3, 1, 6)))
})

test_that("chained start/stop tests", {
  expect_equal(gen.list(c(a, b, c), a = 1:3, b = a:3, c = a:b), 
               list(c(1, 1, 1), c(1, 2, 1), c(1, 3, 1), c(1, 2, 2), c(2, 2, 2), c(1, 3, 2), c(2, 3, 2), c(1, 3, 3), c(2, 3, 3), c(3, 3, 3)))
  expect_equal(gen.vector(100 * x + 10 * y + z, x = 1:2, y = x:2, z = y:2), c(111, 112, 122, 222))
  expect_equal(gen.data.frame(c(a = x, b = y), x = 1:2, y = x:3), data.frame(a = c(1, 1, 2, 1, 2), b = c(1, 2, 2, 3, 3)))
  x <- 1
  y <- 1 # may not influence the list comprehension
  expect_equal(gen.data.frame(c(a = x, b = y), x = 1:2, y = x:3), data.frame(a = c(1, 1, 2, 1, 2), b = c(1, 2, 2, 3, 3)))
})

test_that("seq tests", {
  expect_equal(gen.vector(x + y, x = seq(10, 30, 10), y = seq(1, 2, 0.5)), c(11.0, 21.0, 31.0, 11.5, 21.5, 31.5, 12.0, 22.0, 32.0))
  expect_equal(gen.list(c(x,y), x = seq(1,3), y = x:2), list(c(1,1),c(1,2),c(2,2)))
  # do not substitute within seq!
  expect_error(gen.list(c(x,y), x = seq(1,3), y = seq(x,3)), "could not evaluate variable range of 'y'")
})

test_that("expression tests", {
  expect_equal(gen.list.expr(x, x = 1:3), quote(list(1L,2L,3L)))
  expect_equal(gen.vector.expr(a_i, i = 1:5), quote(c(a_1, a_2, a_3, a_4, a_5)))
  expect_equal(gen.list(gen.vector.expr(a_i, i = 1:3), a_ = 1:2), list(c(1, 1, 1), c(2, 1, 1), c(1, 2, 1), c(2, 2, 1), c(1, 1, 2), c(2, 1, 2), c(1, 2, 2), c(2, 2, 2)))
  expect_equal(gen.list.expr(a_(i+1), i = 1:3), quote(list(a_2, a_3, a_4)))
  expect_equal(gen.vector.expr(a_(if (i<=2) i else 10), i = 1:3), quote(c(a_1, a_2, a_10)))
  expect_equal(gen.vector.expr(a_((i)), i = 1:2), quote(c(a_(1L), a_(2L))))
  expect_equal(gen.list.expr(c(x_1, ..., x_5, a), a = 1), quote(list(c(x_1, x_2, x_3, x_4, x_5, 1))))
})


test_that("character tests", {
  expect_equal(gen.list.char('a{i}_{2*i}', i = 1:3), list("a1_2", "a2_4", "a3_6"))
  expect_equal(gen.vector.char("{if (i==1) { 'a' } else 'b'}{i}", i = 1:3), c("a1", "b2", "b3"))
  
  x <- 1
  expect_equal(gen.vector.char("{i}{j}, {x}", i = 1:2, j = i:2), c("11, 1", "12, 1", "22, 1"))
  expect_equal(gen.vector.char("{x+y}", x = 10:11, y = x:11), c("20", "21", "22"))
  
  expect_equal(gen.vector.char("{i+1}_{i}", i = 1:2), c("2_1", "3_2"))
  expect_equal(gen.vector.char("{{a}}", i = 1:2), c("{{a}}", "{{a}}"))
})
