#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]; then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO players(username) VALUES ('$USERNAME')")

else

    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")

    echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

until [[ $USER_GUESS == $SECRET_NUMBER ]]; do

    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
        # request valid guess
        echo -e "\nThat is not an integer, guess again:"
        read USER_GUESS
        # update guess count
        ((GUESS_COUNT++))

    # if its a valid guess
    else
        # check inequalities and give hint
        if [[ $USER_GUESS < $SECRET_NUMBER ]]; then
            echo "It's higher than that, guess again:"
            read USER_GUESS
            # update guess count
            ((GUESS_COUNT++))
        else
            echo "It's lower than that, guess again:"
            read USER_GUESS
            #update guess count
            ((GUESS_COUNT++))
        fi
    fi

done

# loop ends when guess is correct so, update guess
((GUESS_COUNT++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")
# add result to game history/database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

# winning message
echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job\!
