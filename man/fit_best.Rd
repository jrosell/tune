% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_best.R
\name{fit_best}
\alias{fit_best}
\alias{fit_best.default}
\alias{fit_best.tune_results}
\title{Fit a model to the numerically optimal configuration}
\usage{
fit_best(x, ...)

\method{fit_best}{default}(x, ...)

\method{fit_best}{tune_results}(
  x,
  metric = NULL,
  parameters = NULL,
  verbose = FALSE,
  add_validation_set = NULL,
  ...
)
}
\arguments{
\item{x}{The results of class \code{tune_results} (coming from functions such as
\code{\link[=tune_grid]{tune_grid()}}, \code{\link[=tune_bayes]{tune_bayes()}}, etc). The control option
\code{\link[=control_grid]{save_workflow = TRUE}} should have been used.}

\item{...}{Not currently used.}

\item{metric}{A character string (or \code{NULL}) for which metric to optimize. If
\code{NULL}, the first metric is used.}

\item{parameters}{An optional 1-row tibble of tuning parameter settings, with
a column for each tuning parameter. This tibble should have columns for each
tuning parameter identifier (e.g. \code{"my_param"} if \code{tune("my_param")} was used).
If \code{NULL}, this argument will be set to
\code{\link[=select_best.tune_results]{select_best(metric)}}.}

\item{verbose}{A logical for printing logging.}

\item{add_validation_set}{When the resamples embedded in \code{x} are a split into
training set and validation set, should the validation set be included in the
data set used to train the model? If not, only the training set is used. If
\code{NULL}, the validation set is not used for resamples originating from
\code{\link[rsample:validation_set]{rsample::validation_set()}} while it is used for resamples originating
from \code{\link[rsample:validation_split]{rsample::validation_split()}}.}
}
\value{
A fitted workflow.
}
\description{
\code{fit_best()} takes the results from model tuning and fits it to the training
set using tuning parameters associated with the best performance.
}
\details{
This function is a shortcut for the manual steps of:

\preformatted{
  best_param <- select_best(tune_results, metric) # or other `select_*()`
  wflow <- finalize_workflow(wflow, best_param)  # or just `finalize_model()`
  wflow_fit <- fit(wflow, data_set)
}
}
\section{See also}{


\code{\link[=last_fit]{last_fit()}} is closely related to \code{\link[=fit_best]{fit_best()}}. They both
give you access to a workflow fitted on the training data but are situated
somewhat differently in the modeling workflow. \code{\link[=fit_best]{fit_best()}} picks up
after a tuning function like \code{\link[=tune_grid]{tune_grid()}} to take you from tuning results
to fitted workflow, ready for you to predict and assess further. \code{\link[=last_fit]{last_fit()}}
assumes you have made your choice of hyperparameters and finalized your
workflow to then take you from finalized workflow to fitted workflow and
further to performance assessment on the test data. While \code{\link[=fit_best]{fit_best()}} gives
a fitted workflow, \code{\link[=last_fit]{last_fit()}} gives you the performance results. If you
want the fitted workflow, you can extract it from the result of \code{\link[=last_fit]{last_fit()}}
via \link[=extract_workflow.tune_results]{extract_workflow()}.
}

\examples{
\dontshow{if (tune:::should_run_examples()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(recipes)
library(rsample)
library(parsnip)
library(dplyr)

data(meats, package = "modeldata")
meats <- meats \%>\% select(-water, -fat)

set.seed(1)
meat_split <- initial_split(meats)
meat_train <- training(meat_split)
meat_test  <- testing(meat_split)

set.seed(2)
meat_rs <- vfold_cv(meat_train, v = 10)

pca_rec <-
  recipe(protein ~ ., data = meat_train) \%>\%
  step_normalize(all_numeric_predictors()) \%>\%
  step_pca(all_numeric_predictors(), num_comp = tune())

knn_mod <- nearest_neighbor(neighbors = tune()) \%>\% set_mode("regression")

ctrl <- control_grid(save_workflow = TRUE)

set.seed(128)
knn_pca_res <-
  tune_grid(knn_mod, pca_rec, resamples = meat_rs, grid = 10, control = ctrl)

knn_fit <- fit_best(knn_pca_res, verbose = TRUE)
predict(knn_fit, meat_test)
\dontshow{\}) # examplesIf}
}
