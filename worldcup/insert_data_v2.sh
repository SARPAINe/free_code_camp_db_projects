#!/bin/bash

# Set PSQL command based on the argument
if [[ $1 == "test" ]]; then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "truncate teams, games")"

CSV_FILE="games.csv"

# Process each line of the CSV file
while IFS="," read -r year round winner opponent winner_goals opponent_goals; do
    # Skip the header line
    if [[ $year == "year" ]]; then
        continue
    fi

    echo "Processing Winner: $winner, Opponent: $opponent"

    # Function to check and insert team
    check_and_insert_team() {
        local team_name=$1
        local team_id_var=$2
        local team_exist

        team_exist="$($PSQL "select name from teams where name='$team_name'")"
        if [[ -z $team_exist ]]; then
            insert_result="$($PSQL "insert into teams (name) values ('$team_name')")"
            if [[ $insert_result == 'INSERT 0 1' ]]; then
                echo "$team_name is added"
            fi
        fi
        eval "$team_id_var=\"$($PSQL "select team_id from teams where name='$team_name'")\""
    }

    # Check and insert winner
    check_and_insert_team "$winner" winner_id

    # Check and insert opponent
    check_and_insert_team "$opponent" opponent_id

    echo "Winner id: $winner_id"
    echo "Opponent id: $opponent_id"

    # Insert game record
    $PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)"

done <"$CSV_FILE"
