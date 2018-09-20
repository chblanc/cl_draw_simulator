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
#' 
#' # load data, will make use of `TEAMS` data.frame
#' source("R/make_data.R")
#' 
#' # pull out one group
#' grp1 <- TEAMS[TEAMS$POT==1, ]
#' 
#' # sample from grp1
#' sampler(grp1, size=1)
sampler <- function(group_df, size=1, update=TRUE) {
  
  sampled <- sample(group_df$TEAMS, replace = FALSE, size = size)
  sampled_df <- group_df[group_df$TEAMS %in% sampled, ]
  sampled_fed <- group_df[group_df$TEAMS %in% sampled, ]$FED
  
  
  if (update) group_df <- group_df[!group_df$TEAMS %in% sampled, ]
  
  out <- list(
    df=group_df,
    sampled_df=sampled_df,
    sampled_team=sampled,
    sampled_fed=sampled_fed
  )
  
  out
  
}

#' update data.frame to exclude a team
#'
#' @param group_df 
#' @param team 
#'
#' @return
#' @export
#'
#' @examples
update_pots <- function(group_df, team=NULL) {
  
  if (is.null(team)) stop("input valid team name")
  if (!any("TEAMS" %in% names(group_df))) {
    stop("`TEAMS` must be  valid column in `group_df`")
  }
  
  group_df[!group_df$TEAMS %in% team,]
}

# mvp -------------------------------------------------------------------------

library(tidyverse)
source("R/make_data.R") # makes input data.frame `TEAMS`

# creates a list where each element is a data.frame for each POT
pots <- split(TEAMS, TEAMS$POT)
ngroups <- 8
groups <- LETTERS[1:ngroups]

# minimal working code; this factors in the constraint that teams in a 
# group CANNOT be from the same federation

set.seed(1)
for (group in groups) {
  
  # iterator: used to assign elements to `draw`
  i <- which(groups == group)
  
  # first iteration; create containers to store results from each draw
  if (group == "A") {
    pots_tmp <- pots
    draw <- vector(mode = "list", length = ngroups)
  }
  
  # sample from each group: check to make sure that federations are not the
  # same. If they are, re-sample from the pot containing the second occurence
  draw_info <- map(pots_tmp, sampler, update=TRUE)
  feds <- map_chr(draw_info, "sampled_fed")
  
  # check for dupe federations; if found, re-sample from `pot_tmp`
  if (anyDuplicated(feds) > 0) {
    
    # if final group has dupes, then, we're out of luck. The draw is basically
    # done because there are no other groups to re-sample from. Error-out to
    # avoid an infinite loop
    if (group == groups[length(groups)]) {
      stop("Draw cannot be completed: duplicate federations in final group")
    }
    
    any_dupes <- TRUE
    
    # while there are any dupes (one or more), continually re-sample and check
    # that there are no federation dupes. Note: `draw_info` is updated in place
    # whenever our conditions are met
    while (any_dupes) {
      dupes <- duplicated(feds)
      for (j in seq_along(dupes)) {
        if (dupes[[j]]) {
          message("Duplicate federations drawn. Resampling group: ", group, "\n")
          draw_info[[j]] <- sampler(pots_tmp[[j]], update=FALSE)
        }
        feds <- map_chr(draw_info, "sampled_fed")
        if (anyDuplicated(feds)==0) any_dupes <<-FALSE
          #draw_info <- update_pots()
      }
    }
  }
  
  # assign sampled teams to group
  draw[[i]] <- map_dfr(draw_info, "sampled_df")
  
  # update tmp pots to exclude sampled teams by overwriting the list that
  # contains the teams left in the pots
  pots_tmp <- map(draw_info, "df")
  
  # for last group, coerce list to data.frame
  if (group == "H") {
    draw <- draw %>%
      set_names(groups) %>%
      bind_rows(.id="GROUP")
  }
  
}

# check
draw %>% count(GROUP, POT) %>% count(n)

# dealing w/nonsense ---------------------------------------------------------
