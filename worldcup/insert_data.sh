#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "truncate teams,games")"
CSV_FILE="games.csv"

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ $year == "year" ]]; then
    continue
  fi

  echo "Processing Winner: $winner, Opponent: $opponent"
  #check if winner is in the teams db
  winner_exist="$($PSQL "select name from teams where name='$winner'")"
  if [[ -z $winner_exist ]]
  then
    #add winner
    insert_winner_result=$($PSQL "insert into teams (name) values ('$winner')")
    if [[ $insert_winner_result == 'INSERT 0 1' ]];    
    then
      echo Winner $winner is added;
    fi
  fi
  #check if opponent is in the teams db
  opponent_exist="$($PSQL "select name from teams where name='$opponent'")"
  if [[ -z $opponent_exist ]]
  then
    insert_opponent_result=$($PSQL "insert into teams (name) values ('$opponent')")
    if [[ $insert_opponent_result == 'INSERT 0 1' ]];    
    then
      echo Opponent $opponent is added;
    fi
  fi
  #get winner id
  winner_id=$($PSQL "select team_id from teams where name='$winner'")
  echo Winner id: $winner_id
  #get opponnet id
  opponent_id=$($PSQL "select team_id from teams where name='$opponent'")
  echo Opponent id: $opponent_id
  #add record
  insert_games_record=$($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")

done