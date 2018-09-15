# helper-func -----------------------------------------------------------------

#' sample from a data.frame
#'
#' @param group_df a \code{data.frame}
#' @param size \code{integer}, how many teams should be sampled from the input
#'   \code{data.frame}? Default is set to 1.
#' @param update \code{bool}, should the input data.frame be updated to remove
#'   the sampled team? Default is \code{TRUE}
#'
#' @return a \code{list} containing the original input \code{data.frame} (which
#'   will not include the sampled team if \code{update=TRUE}), a second
#'   \code{data.frame} containing the rows of \code{group_df} of the sampled
#'   team, and lastly, a character string of the selected team(s)
#' @examples
sampler <- function(group_df, size=1, update=TRUE) {
  
  sampled <- sample(group_df$TEAMS, replace = FALSE, size = size)
  sampled_df <- group_df[group_df$TEAMS %in% sampled, ]
  
  
  if (update) group_df <- group_df[!group_df$TEAMS %in% sampled, ]
  return(list(df=group_df, sampled_df=sampled_df, sampled_team=sampled))
  
}

# mvp -------------------------------------------------------------------------

library(tidyverse)
source("R/make_data.R") # makes input data.frame `TEAMS`

# creates a list where each element is a data.frame for each POT
pots <- split(TEAMS, TEAMS$POT)
ngroups <- 8

# minimal working code; this does not factor in ANY of the contstraints
for (i in seq_len(ngroups)) {
  
  if (i == 1) {
    pots_tmp <- pots
    draw <- vector(mode = "list", length = ngroups)
  }
  
  # sample from each group
  draw_info <- map(pots_tmp, sampler)
  draw[[i]] <- map_dfr(draw_info, "sampled_df")
  
  # update tmp pots
  if (i > 0) pots_tmp <- map(draw_info, "df")
  
  if (i == ngroups) {
    draw <-draw %>%
      set_names(LETTERS[1:ngroups]) %>%
      bind_rows(.id="group")
  }
  
}

# dealing w/nonsense ---------------------------------------------------------
