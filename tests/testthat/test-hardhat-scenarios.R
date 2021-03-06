test_that("we can continue training with a additional fit", {

  data("ames", package = "modeldata")
  ids <- sample(nrow(ames), 256)
  x <- ames[ids,-which(names(ames) == "Sale_Price")]
  y <- ames[ids,]$Sale_Price

  fit_1 <- tabnet_fit(x, y, epochs = 1)
  fit_2 <- tabnet_fit(x, y, tabnet_model=fit_1, epochs = 1)

  expect_equal(fit_2$fit$config$epoch, 1)
  expect_length(fit_2$fit$metrics, 2)
  expect_identical(fit_1$fit$metrics[[1]]$train$loss, fit_2$fit$metrics[[1]]$train$loss)

})

test_that("we can change the tabnet_options between training epoch", {

  data("ames", package = "modeldata")
  ids <- sample(nrow(ames), 256)
  x <- ames[ids,-which(names(ames) == "Sale_Price")]
  y <- ames[ids,]$Sale_Price

  fit_1 <- tabnet_fit(x, y, epochs = 1)
  fit_2 <- tabnet_fit(x, y, fit_1, epochs = 1, penalty = 0.003, learn_rate = 0.002)

  expect_equal(fit_2$fit$config$epoch, 1)
  expect_length(fit_2$fit$metrics, 2)
  expect_equal(fit_2$fit$config$learn_rate, 0.002)

})

test_that("epoch counter is valid for retraining from a checkpoint", {

  data("ames", package = "modeldata")
  ids <- sample(nrow(ames), 256)
  x <- ames[ids,-which(names(ames) == "Sale_Price")]
  y <- ames[ids,]$Sale_Price

  fit_1 <- tabnet_fit(x, y, epochs = 12, verbose=T)
  tmp <- tempfile("model", fileext = "rds")
  saveRDS(fit_1, tmp)

  fit1 <- readRDS(tmp)
  fit_2 <- tabnet_fit(x, y, fit1, epochs = 12, verbose=T)

  expect_equal(fit_2$fit$config$epoch, 12)
  expect_length(fit_2$fit$metrics, 22)
  expect_lte(mean(fit_2$fit$metrics[[22]]$train$loss), mean(fit_2$fit$metrics[[1]]$train$loss))

})
