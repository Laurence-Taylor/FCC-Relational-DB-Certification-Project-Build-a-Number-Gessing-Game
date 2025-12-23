#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSING_GAME(){
  # Generate number to guess
  NUMBER_GENERATED=$(( (RANDOM % 1000) + 1 ))
  # Start Counter to 0
  NUMBER_GUESSING=0
  # Request a number...
  echo "Guess the secret number between 1 and 1000:"
  # Loop to find number ...
  while true
  do
    read NUMBER_GUESS
    # Cheking that user answer is a number
    if [[ $NUMBER_GUESS =~ ^[0-9]+$ ]]
    then
      # Counting guesses
      ((NUMBER_GUESSING++))
      # If assert the guess
      if [[ $NUMBER_GUESS -eq $NUMBER_GENERATED  ]]
      then
        # Write Message number was guess
        echo "You guessed it in $NUMBER_GUESSING tries. The secret number was $NUMBER_GENERATED. Nice job!"
        # Get the saved best score
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$1;")
        # check if actual score is better than the saved score and update if necesary
        if [[ $NUMBER_GUESSING -le $BEST_GAME ]]
         then
          UPDATE_USER=$($PSQL "UPDATE users SET best_game=$NUMBER_GUESSING WHERE user_id=$1;")
        fi
        break
      fi
      # if the guess is higher 
      if [[ $NUMBER_GUESS -gt $NUMBER_GENERATED ]]
      then
        echo "It's lower than that, guess again:"    
      fi
      # if the guess is lower
      if [[ $NUMBER_GUESS -lt $NUMBER_GENERATED ]]
      then
        echo "It's higher than that, guess again:"    
      fi
    # if is not a number
    else
      echo "That is not an integer, guess again:"
    fi
  done
}

MAIN(){
  # Get user Name
  echo "Enter your username:"
  read USER_NAME
  # Check user name is not longer than 22 characters
  if [[ ${#USER_NAME} -le 22 ]]
  then
    # Getting user ID from the Data Base given the name
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME';")
    # if user not exist in the Data Base
    if [[ -z $USER_ID ]]
    then
      # Write welcome message
      echo "Welcome, $USER_NAME! It looks like this is your first time here."
      # Create new User
      INSET_NEW_USER=$($PSQL "INSERT INTO users(username, best_game) VALUES('$USER_NAME', 1000);")
      # Getting user ID from the Data Base given the name
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME';")
      # Executing the game
      GUESSING_GAME $USER_ID
    else 
      # Get user information
      USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE user_id=$USER_ID;")
      # Writing the welcome message output
      echo "$USER_INFO" | while IFS='|' read GAMES_PLAYED BEST_GAME
      do 
        echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
        ((GAMES_PLAYED++))
        # Updating number of played games
        UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
      done
      # Executing the game
      GUESSING_GAME $USER_ID
    fi
  else
    # Message name no more than 22 characters
    echo "The name should have not more than 22 characters. Please try egain."
    exit
  fi
}

MAIN
