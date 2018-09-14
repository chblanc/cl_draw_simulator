# Champions League Draw Simulator
For funsies - simulate the champions league draw with `R`

This is actually the second iteration of the project

# Rules
via [Uefa](https://www.uefa.com/uefachampionsleague/news/newsid=2568286.html)

## Who is involved in the draw?
  * ESP: Real Madrid, Atlético Madrid, Barcelona, Valencia
  * GER: Bayern München, Borussia Dortmund, Schalke, Hoffenheim
  * ENG: Manchester City, Manchester United, Tottenham Hotspur, Liverpool
  * ITA: Juventus, Napoli, Roma, Internazionale Milano 
  * FRA: Paris Saint-Germain, Lyon, Monaco
  * RUS: Lokomotiv Moskva, CSKA Moskva
  * POR: Porto, Benfica 
  * UKR: Shakhtar Donetsk
  * BEL: Club Brugge
  * TUR: Galatasaray
  * CZE: Viktoria Plzeň
  * SUI: Young Boys
  * NED: Ajax, PSV Eindhoven
  * GRE: AEK Athens
  * SRB: Crvena zvezda

## Who is in which pot?

* Pot 1
  * Real Madrid (holders)
  * Atlético Madrid (UEFA Europa League winners)
  * Barcelona
  * Bayern München
  * Manchester City
  * Juventus
  * Paris Saint-Germain
  * Lokomotiv Moskva
    
* Pot 2
  * Borussia Dortmund 89.000
  * Porto 86.000
  * Manchester United 82.000
  * Shakhtar Donetsk 81.000
  * Benfica 80.000
  * Napoli 78.000
  * Tottenham Hotspur 67.000
  * Roma 64.000

* Pot 3
  * Liverpool 62.000 
  * Schalke 62.000
  * Lyon 59.500
  * Monaco 57.000
  * Ajax 53.500
  * CSKA Moskva 45.000
  * PSV Eindhoven 36.000
  * Valencia 36.000

* Pot 4
  * Viktoria Plzeň 33.000 
  * Club Brugge 29.500
  * Galatasaray 29.500
  * Young Boys 20.500
  * Internazionale Milano 16.000
  * Hoffenheim 14.285
  * Crvena zvezda 10.750
  * AEK Athens 10.000

Clubs' coefficients are determined either by the sum of all points won in the
previous five years or by the association coefficient over the same period
– whichever is higher (under a new system introduced for 2018/19 onwards).

## How does the draw work?
New UEFA Champions League format explained:

The 26 teams given direct entry to the group stage under the new competition
system are joined by the six winners of the play-off ties. The teams are split
into four seeding pots. Pot 1 consists of the holders, the UEFA Europa League
winners and the champions of the six highest-ranked nations. Pots 2 to 4 are
determined by the club coefficient rankings.  

No team can play a club from their own association and, based on decisions
taken by the UEFA Executive Committee, clubs from Russia and Ukraine must not
be drawn in the same group.  

In the case of associations with two or more representatives, clubs have been
paired in order to split their matches between Tuesday and Wednesday, namely:

  * Real Madrid & Barcelona
  * Atlético Madrid & Valencia
  * Bayern & Dortmund
  * Man. City & Tottenham
  * Juventus & Internazionale Milano
  * Paris & Lyon
  * Lokomotiv Moskva & CSKA Moskva
  * Porto & Benfica
  * Man. United & Liverpool
  * Napoli & Roma
  * Schalke & Hoffenheim
  * Ajax & PSV Eindhoven

If a paired club is drawn, for example, in groups A, B, C or D, the other
paired club – once drawn – will automatically be assigned to one groups E, F,
G or H.