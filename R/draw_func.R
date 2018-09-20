
# NEEDS FUNCTION TO ASSURE BARCA/MADRDID ARE NOT IN THE SAME GROUP
# Also DRAWS 3, and 4 are not functioning correctly 
  # adding duplicate teams 


library(tidyverse)

####
# Function to count possible groups for a randomly selected team
NUMpossibleGroups <- function(temp_team=temp_team, 
                           DRAW=DRAW,
                           SEED=SEED){
  
  # identify exclusions groups in DRAW
  draw_g_c <- aggregate(cbind(count = TEAMS) ~ GROUPS, 
                        data = DRAW, 
                        FUN = function(x){NROW(x)})
  draw_g_c <- draw_g_c[ which(draw_g_c$count==SEED), ]
  
  draw_fed <- DRAW[DRAW$FED==temp_team$FED, ]
  
  draw_same_team <- DRAW[DRAW$TEAMS==temp_team$TEAMS, ]
  
  if(temp_team$TV%in%DRAW$TV){
    x <- DRAW[which(DRAW$TV==temp_team$TV), ] 
    draw_tv<-DRAW[which(DRAW$DAY==x$DAY), ]
    draw_tv<-as.vector(draw_tv$GROUPS)
  } else {
    draw_tv <- NULL
  }
  exclusions <- c(draw_g_c$GROUPS,draw_fed$GROUPS, draw_tv) %>% unique()
  exclusions <<- exclusions[!is.na(exclusions)]
  
  numExclusions <<- length(exclusions)
  numExclusions
}





####
# Function to assess possible groups for a randomly selected team
possibleGroups <- function(temp_team=temp_team, 
                           DRAW=DRAW,
                           SEED=SEED){
  
  # identify exclusions groups in DRAW
  draw_g_c <- aggregate(cbind(count = TEAMS) ~ GROUPS, 
                        data = DRAW, 
                        FUN = function(x){NROW(x)})
  draw_g_c <- draw_g_c[ which(draw_g_c$count==SEED), ]
  
  draw_fed <- DRAW[DRAW$FED==temp_team$FED, ]
  
  draw_same_team <- DRAW[DRAW$TEAMS==temp_team$TEAMS, ]
  
  if(temp_team$TV%in%DRAW$TV){
    x <- DRAW[which(DRAW$TV==temp_team$TV), ] 
    draw_tv<-DRAW[which(DRAW$DAY==x$DAY), ]
    draw_tv<-as.vector(draw_tv$GROUPS)
  } else {
    draw_tv <- NULL
  }
  exclusions <- c(draw_g_c$GROUPS,draw_fed$GROUPS, draw_tv) %>% unique()
  exclusions <- exclusions[!is.na(exclusions)]
  
  # POSSIBLE GROUPS  
  temp_poss <- DRAW[which(!DRAW$GROUPS%in%exclusions), ]
  temp_poss <- subset(temp_poss,select = c(DAY,GROUPS))
  possible_groups <<- as.vector(unique(temp_poss))
  return(possible_groups)
}




## test draw_func 2
draw_func2 <- function(TEAMS=TEAMS, SEED=SEED, DRAW=DRAW){
  
  ## assessing possible destinations
  print(DRAW)
  # selecting relevant SEED teams from TEAMS
  temp_draw_teams <<- TEAMS[ which(TEAMS$POT==SEED), ]
  # removing any teams that have already been placed in DRAW
  temp_draw_teams <<- temp_draw_teams[ which(!temp_draw_teams$TEAMS%in%DRAW$TEAMS), ]
  
  # looping through these teams to see if any have only one possible placement
    # (where numExclusions==7)
  for(i in nrow(temp_draw_teams)){
    NUMpossibleGroups(temp_team = temp_draw_teams[i, ],DRAW=DRAW,SEED=SEED)
    print("Number of Exclusions")
    print(numExclusions)
    
    if(numExclusions==7){
      a <- temp_draw_teams[i, ]
      b <- DRAW[which(!DRAW$GROUPS%in%exclusions), ]
      temp_f<-cbind(a,b$DAY,b$GROUPS)
      names(temp_f)<-names(DRAW)
      DRAW <<- rbind(DRAW,temp_f)
    } else {
      
    # if there are less than 7 excluded groups for ALL remaining teams to be drawn, the draw continues
      # randomly sample one from temp_draw_teams
        temp_team <<- temp_draw_teams[i, ]
        #temp_team <<- temp_draw_teams[sample(nrow(temp_draw_teams), 1, replace = F), ]
        print(temp_team)
        possibleGroups(temp_team=temp_team,DRAW=DRAW,SEED=SEED)
        print(possible_groups)
      
      # sampling one possible group and attaching temp_team to DRAW
      
        temp_team_sel <- possible_groups[sample(nrow(possible_groups),1,replace = FALSE), ]
        temp_team_f <<- cbind(temp_team,temp_team_sel)
        DRAW <<- rbind(DRAW,temp_team_f)
      #return(DRAW)
      #print(DRAW)  
    }
  }
  
}



# Set up ----


source("R/make_data.R")
DRAW <- data.frame(
  DAY=c(rep("TUES",4),rep("WED",4)),
  GROUPS=c(toupper(letters[1:8])),
  stringsAsFactors=FALSE
)


## Need to build in a condition so Madrid, Barca aren't on same day
TEAMS_pot1 <- TEAMS[ which(TEAMS$POT==1), ]
TEAMS1 <-TEAMS_pot1[sample(nrow(TEAMS_pot1), 8, replace = FALSE), ]
DRAW <-cbind(TEAMS1,DRAW)


#test
#draw_func(TEAMS=TEAMS, SEED=2, DRAW = DRAW)
#DRAW

# Draw 2 ----

repeat{
  draw_func2(TEAMS=TEAMS, SEED=2, DRAW = DRAW)
  if (nrow(DRAW)==16) break   
}

## DIAGNOSTICS 
dim(DRAW)
length(unique(DRAW$TEAMS))
DRAW %>% group_by(GROUPS) %>% tally()
table(DRAW$GROUPS,DRAW$FED)
table(DRAW$TV,DRAW$DAY)


# Draw 3 ----


# works up to this point, it is drawing +24 teams! Often Liverpool twice...
repeat{
  draw_func2(TEAMS=TEAMS, SEED=3, DRAW = DRAW)
  if (nrow(DRAW)>23) break   
}

## DIAGNOSTICS 
dim(DRAW)
length(unique(DRAW$TEAMS))
DRAW %>% group_by(GROUPS) %>% tally()
table(DRAW$GROUPS,DRAW$FED)
table(DRAW$TV,DRAW$DAY)



# Draw 4 ----

repeat{
  draw_func2(TEAMS=TEAMS, SEED=4, DRAW = DRAW)
  if (nrow(DRAW)>31) break   
}

DRAW <- DRAW %>% unique()


## DIAGNOSTICS 
dim(DRAW)
length(unique(DRAW$TEAMS))
DRAW %>% group_by(GROUPS) %>% tally()
table(DRAW$GROUPS,DRAW$FED)
table(DRAW$TV,DRAW$DAY)


# Cleaning up ----
rm(possible_groups,TEAMS,TEAMS_pot1,TEAMS1,temp_draw_teams,temp_team,temp_team_f,COEF,exclusions,FED,numExclusions,POT,TV)

