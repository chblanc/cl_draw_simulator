# create team/draw data.frame -------------------------------------------------

TEAMS <- c(
  "Real Madrid","Athletico","Barcelona","Bayern",
  "Man. City","Juventus","Paris St. Germain","Lokotimov Moscow",
  "Dortmund","Porto","Man. United","Shaktar Donetsk",
  "Benfica","Napoli","Tottenham","Roma",
  "Liverpool","Schalke","Lyon","Monaco",
  "Ajax","CSKA Moskva","PSV","Valencia",
  "Plzen","Club Brugge","Galatasaray","Young Boys",
  "Internazionale","Hoffenheim","Crvena zvezda","AEK"
)

POT <- c(rep(1,8), rep(2,8), rep(3,8), rep(4,8))

FED <- c(
  "ESP","ESP","ESP","GER",
  "ENG","ITA","FRA","RUK",
  "GER","POR","ENG","RUK",
  "POR","ITA","ENG","ITA",
  "ENG","GER","FRA","FRA",
  "NED","RUK","NED","ESP",
  "CZE","BEL","TUR","SUI",
  "ITA","GER","SRB","GRE"
)

TV <- c(
  "_A","_B","_A","_C",
  "_D","_E","_F","_H",
  "_C","_I","_J",NA,
  "_I","_K","_D","_K",
  "_J","_L","_F",NA,
  "_M","_H","_M","_B",
  NA,NA,NA,NA,
  "_E","_L",NA,NA
)

COEF <- c(rep(NA, 8), 90, 86, 82, 81, 80, 78, 67, 64, 62, 62, 59.5, 57,
          53.5, 45, 36, 36, 33, 29.5, 29.5, 20.5, 16, 14.285, 10.75, 10)

TEAMS <- data.frame(
  TEAMS=TEAMS, POT=POT, FED=FED, TV=TV,
  #COEF=COEF, 
  stringsAsFactors=F
)
