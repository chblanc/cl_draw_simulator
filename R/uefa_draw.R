# helper-func -----------------------------------------------------------------

#' sample from a data.frame
#'
#' @param group_df a \code{data.frame}
#' @param size \code{integer}, how many teams should be sampled from the input
#'   \code{data.frame}? Default is set to 1.
#' @param update_pot \code{bool}, should the input data.frame be updated to remove
#'   the sampled team? Default is \code{TRUE}
#'
#' @return a \code{list} containing the original input \code{data.frame} (which
#'   will not include the sampled team if \code{update_pot=TRUE}), a second
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
sampler <- function(group_df, size=1, update_pot=TRUE) {
  
  sampled <- sample(group_df$TEAMS, replace = FALSE, size = size)
  sampled_df <- group_df[group_df$TEAMS %in% sampled, ]
  sampled_fed <- sampled_df$FED
  sampled_tv <- sampled_df$TV
  
  
  if (update_pot) group_df <- group_df[!group_df$TEAMS %in% sampled, ]
  
  out <- list(
    df=group_df,
    sampled_df=sampled_df,
    sampled_team=sampled,
    sampled_fed=sampled_fed,
    sampled_tv=sampled_tv
  )
  
  out
  
}

#' update data.frame to exclude a team
#'
#' @param group_df a \code{data.frame}
#' @param team a \code{character} string, indicating which team to remove from
#'   \code{group_df}
#' @details this is a convenience function that subsets the input
#'   \code{data.frame} by removing \code{team}. This function will be used
#'   to update the pot of available teams after reach group is drawn.
#'
#' @return a \code{data.frame}
update_pots <- function(group_df, team=NULL) {
  
  if (is.null(team)) stop("input valid team name")
  if (!any("TEAMS" %in% names(group_df))) {
    stop("`TEAMS` must be  valid column in `group_df`")
  }
  
  group_df[!group_df$TEAMS %in% team, ]
}

# mvp -------------------------------------------------------------------------

library(tidyverse)
source("R/make_data.R") # makes input data.frame `TEAMS`

# creates a list where each element is a data.frame for each POT
pots <- split(TEAMS, TEAMS$POT)
ngroups <- 8
groups <- LETTERS[1:ngroups]

# pots: a list of data.frames, containing teams from each pot
# groups: a vector of groups (LETTERS[1:8])
# seed: set a seed

uefa_draw <- function(pots, groups, seed=1, tol=1000, v=FALSE) { 
  
  set.seed(seed) 
  ngroups <- length(groups)
  counter <- 1
  if (v) message("Begin draw --------------------")
  
  for (group in groups) {
    
    # iterator: used to assign elements to `draw`
    i <- which(groups == group)
    if (v) message("Draw for group: ", group)
    
    # first iteration; create containers to store results from each draw
    if (group == groups[[1]]) {
      pots_tmp <- pots
      draw <- vector(mode="list", length=ngroups)
      tv_list <- vector(mode="list", length=ngroups)
    }
    
    # sample one team from each pot
    draw_info <- map(pots_tmp, sampler, update_pot=FALSE)
    feds <- map_chr(draw_info, "sampled_fed")
    tv_list[[i]] <- map_chr(draw_info, "sampled_tv")
    
    # conditional-draw-logic ------------------------------------------
    
    # the following checks need to be done:
    #   1. no duplicate TV groups for groups A:D. This must be tracked ACROSS
    #      draws. If a duplicate TV group is drawn we will re-sample.
    #   2. Secondly, federations cannot not the same within a group. If they are,
    #      re-sample from the pot containing the second occurence
    #
    # this will be achieved by checking (for each draw) whether any duplicates
    # exist for both federation and tv (note that TV is tracked across
    # iterations, and only iterations 2, 3, 4)
    
    # duplicate federations will need to be checked in every draw iteration
    check_feds <- anyDuplicated(feds, incomparables=NA) > 0
    
    # `check_tv`: tracks TV status across draws, only for iterations 2,3,4
    if (i <= ngroups/2) {
      if (i == 1) check_tv <- FALSE
      if (i > 1) check_tv <- TRUE
      tv_combined <- combine(tv_list[1:i])
    }
    if (i > ngroups/2) {
      check_tv <- FALSE
      tv_combined <- 0L
    }
  
    # check for dupe tv groups first, dupe federations second:
    while ((check_tv | check_feds)) {
      
      # bool: t/f
      is_tv_dupe <- tail(duplicated(tv_combined, incomparables=NA), 4)
      is_fed_dupe <- duplicated(feds, incomparables=NA)
      
      counter <- sum(counter, 1)
      if (counter >=  tol) return("Draw aborted: while condition not satisfied")
      
      # single iterator checking both constraints
      resamp_index <- as.logical(pmax(is_tv_dupe, is_fed_dupe))
      
      # check for dupe federations; if found, re-sample from `pot_tmp`
      # if final group has dupes, then, we're out of luck. The draw is basically
      # done because there are no other groups to re-sample from. Error-out to
      # avoid an infinite loop
      if (group == groups[length(groups)]) {
        return("Draw cannot be completed: duplicate federations in final group")
      }
      
      for (j in seq_along(resamp_index)) {
        if (resamp_index[[j]]) {
          if (v) message("Dupe tv or fed groups drawn. Resample group: ", group)
          draw_info[[j]] <- sampler(pots_tmp[[j]], update_pot=FALSE)
        }
      }
      
      # reset values for feds, and tv
      feds <- map_chr(draw_info, "sampled_fed")
      tv_list[[i]] <- map_chr(draw_info, "sampled_tv")
      tv_combined <- combine(tv_list[1:i])
      
      if (anyDuplicated(feds) == 0) check_feds <- FALSE
      if (anyDuplicated(tv_combined, incomparables=NA) == 0) check_tv <- FALSE
    }  
    
    # assign sampled teams to group
    draw[[i]] <- map_dfr(draw_info, "sampled_df")
    tv_list[[i]] <- map_chr(draw_info, "sampled_tv")
    
    # update tmp pots to exclude sampled teams by overwriting the list that
    # contains the teams left in the pots
    #pots_tmp <- map(draw_info, "df")
    for (l in seq_along(draw_info)) {
      pots_tmp[[l]] <- update_pots(
        group_df=pots_tmp[[l]],
        team=draw_info[[l]]$sampled_team
      )
    }
    
    # for last group, coerce list to data.frame
    if (group == "H") {
      draw <- draw %>%
        set_names(groups) %>%
        bind_rows(.id="GROUP")
    }
  }
  draw
}
# dry-run ---------------------------------------------------------------------

test_draw <- uefa_draw(pots=pots, groups=LETTERS[1:8], seed=1)
test_draw  %>% count(GROUP, POT) %>% count(n)

# multiple-runs ---------------------------------------------------------------
iters <- 1000
draws <- map(seq_len(iters), ~ uefa_draw(pots, LETTERS[1:8], seed=.x))
