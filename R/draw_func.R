
## SETTING UP DFS FOR TEAMS AND DRAW ----
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - # 

TEAMS<-data.frame(TEAMS=c("Real Madrid","Athletico","Barcelona","Bayern",
                          "Man. City","Juventus","Paris St. Germain","Lokotimov Moscow",
                          "Dortmund","Porto","Man. United","Shaktar Donetsk",
                          "Benfica","Napoli","Tottenham","Roma",
                          "Liverpool","Schalke","Lyon","Monaco",
                          "Ajax","CSKA Moskva","PSV","Valencia",
                          "Plzen","Club Brugge","Galatasaray","Young Boys",
                          "Internazionale","Hoffenheim","Crvena zvezda","AEK"),
                  POT=c(rep(1,8),rep(2,8),rep(3,8),rep(4,8)),
                  FED=c("ESP","ESP","ESP","GER",
                        "ENG","ITA","FRA","RUK",
                        "GER","POR","ENG","RUK",
                        "POR","ITA","ENG","ITA",
                        "ENG","GER","FRA","FRA",
                        "NED","RUK","NED","ESP",
                        "CZE","BEL","TUR","SUI",
                        "ITA","GER","SRB","GRE")
                  ,TV=c("_A","_B","_A","_C",
                        "_D","_E","_F","_H",
                        "_C","_I","_J",NA,
                        "_I","_K","_D","_K",
                        "_J","_L","_F",NA,
                        "_M","_H","_M","_B",
                        NA,NA,NA,NA,
                        "_E","_L",NA,NA)
                  ,stringsAsFactors = F)



## Setting up DRAW dataset where draw results will be stored
DRAW <- data.frame(DAY=c(rep("TUES",4),rep("WED",4)),
                   GROUPS=c(toupper(letters[1:8])),stringsAsFactors = F)
TEAMS_pot1 <- TEAMS[ which(TEAMS$POT==1), ]
TEAMS1 <-TEAMS_pot1[sample(nrow(TEAMS_pot1), 8, replace = FALSE), ]
DRAW <-cbind(TEAMS1,DRAW)


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #


DRAW_FUNCTION <- function(TEAMS=TEAMS, SEED){
  
### FOR LOOP TO CHECK FOR TEAMS THAT HAVE ONLY ONE POSSIBLE DESTINATION GROUP

  for (i in 1:nrow(draw_teams)){
    candidateTeam <- draw_teams[i, ] 
    
    # EXCLUDED GROUPS -- already had a team placed this round, matching federation, contradicting tv days   
      draw_g_c <- DRAW %>% group_by(GROUPS) %>% tally() %>% filter(n==SEED)
      draw_fed <- DRAW %>% filter(FED==candidateTeam$FED)
      if(candidateTeam$TV%in%DRAW$TV){
        x <- DRAW[which(DRAW$TV==candidateTeam$TV), ] 
        draw_tv<-DRAW[which(DRAW$DAY==x$DAY), ]
      } else {
        draw_tv$GROUPS <- NA
      }
      
      exclusions <- c(draw_g_c$GROUPS,draw_fed$GROUPS, draw_tv$GROUPS) %>% unique() 
      exclusions <- exclusions[!is.na(exclusions)]
      
    # POSSIBLE GROUPS  
      possible_groups <- DRAW[!DRAW$GROUPS%in%exclusions, ]
      possible_groupsNum <- nrow(possible_groups)
    
    # IF possible_groupsNum = 1 THEN candidate team is assigned to sole remaining group :   
      if (possible_groupsNum==1){
        # pulling DAY, GROUPS from possible group
        candidateTeam_sup<-possible_groups[,5:6]
        candidateTeam_final<-cbind(candidateTeam,candidateTeam_sup)
        DRAW <<- rbind(DRAW,candidateTeam_final)
        draw_teams <<- draw_teams[which(!draw_teams$TEAMS==candidateTeam$TEAMS), ]
      }
    
  }

### DRAWING RANDOM TEAM TO BE PLACED IN GROUP DEPENDENT UPON SAME 3 CONDITIONS AS ABOVE
  
  temp_team <- draw_teams[sample(nrow(draw_teams), 1, replace=FALSE), ]

  # EXCLUDED GROUPS -- same as above
  draw_g_c <- DRAW %>% group_by(GROUPS) %>% tally() %>% filter(n==SEED)
  draw_fed <- DRAW %>% filter(FED==temp_team$FED) 
  if(temp_team$TV%in%DRAW$TV){
    x<- DRAW[which(DRAW$TV==temp_team$TV), ] 
    draw_tv<-DRAW[which(DRAW$DAY==x$DAY), ]
  } else {
    draw_tv$GROUPS <- NA
  }
  
  exclusions <- c(draw_g_c$GROUPS,draw_fed$GROUPS, draw_tv$GROUPS) %>% unique()
  exclusions <- exclusions[!is.na(exclusions)]
  
  # POSSIBLE GROUPS  
    possible_groups <- DRAW %>% 
      filter(!GROUPS%in%exclusions) %>%
      select(DAY,GROUPS) %>% unique() %>%
      as.vector() 
    
  #print(exclusions)
  #print(possible_groups)
  
  # RANDOMLY SELECTING ONE OF THE POSSIBLE GROUPS, ATTACHING TO DRAW
    temp_team_sel <- possible_groups[sample(nrow(possible_groups),1,replace = FALSE), ]
    temp_team_f <<- cbind(temp_team,temp_team_sel)
    DRAW <<- rbind(DRAW,temp_team_f)
  
  # REMOVING THE RANDOMLY SELECTED TEAM FROM THE LIST OF DRAW TEAMS
  draw_teams <<- draw_teams[which(!draw_teams$TEAMS==temp_team$TEAMS), ]
  
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# DRAW TEAMS FROM POT 2 ----
draw_teams <- TEAMS[ which(TEAMS$POT==2), ]


repeat{
  DRAW_FUNCTION(TEAMS=TEAMS, SEED = 2)
    if(nrow(draw_teams)<1){
      break
    }
  }


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# DRAW TEAMS FROM POT 3 ----
draw_teams <- TEAMS[ which(TEAMS$POT==3), ]


repeat{
  DRAW_FUNCTION(TEAMS=TEAMS, SEED = 3)
  
  #print(DRAW)
  
  if(nrow(draw_teams)<1){
    break
  }
} 


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# DRAW TEAMS FROM POT 4 ----
draw_teams <- TEAMS[ which(TEAMS$POT==4), ]


repeat{
  DRAW_FUNCTION(TEAMS=TEAMS, SEED = 4)
  
  #print(DRAW)
  
  if(nrow(draw_teams)<1){
    break
  }
} 


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

## DIAGNOSTICS ----

dim(DRAW)
length(unique(DRAW$TEAMS))
DRAW %>% group_by(GROUPS) %>% tally()
table(DRAW$GROUPS,DRAW$FED)
table(DRAW$TV,DRAW$DAY)





