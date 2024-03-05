#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
    then
    #get team_id from winner
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #if not found
      if [[ -z $TEAM_ID_WINNER ]]
        then
        #insert team_id
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        if [[ INSERT_TEAM_RESULT=="INSERT 0 1" ]]
          then
          echo "Team inserted, $WINNER"
        fi
      fi
      #get new TEAM_ID
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      #get team_id from opponent
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      #if not found
      if [[ -z $TEAM_ID_OPPONENT ]]
        then
          #insert team_id
          INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
          if [[ INSERT_TEAM_RESULT=="INSERT 0 1" ]]
            then
            echo "Team inserted, $OPPONENT"
          fi
      fi
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    #get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games INNER JOIN teams ON teams.team_id = games.winner_id WHERE winner_id=$TEAM_ID_WINNER AND opponent_id=$TEAM_ID_OPPONENT")
    #if not found
    if [[ -z $GAME_ID ]]
      then
      #insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$TEAM_ID_WINNER,$TEAM_ID_OPPONENT,$WINNER_GOALS,$OPPONENT_GOALS)")
      if [[ INSERT_GAMES_RESULT=="INSERT 0 1" ]]
        then
        GAME_ID=$($PSQL "SELECT game_id FROM games INNER JOIN teams ON teams.team_id = games.winner_id WHERE winner_id=$TEAM_ID_WINNER AND opponent_id=$TEAM_ID_OPPONENT")
        echo "Game inserted, $GAME_ID"
      fi
    fi
  fi
done