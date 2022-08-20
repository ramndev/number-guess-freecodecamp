#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

#generate random number
num=$(($RANDOM % 1000 + 1))

#Ask for username
echo -e "\nEnter your username:"
read username

#check if username played before
USER_CHECK=$($PSQL "SELECT username FROM game_data WHERE username = '$username'")

#if username not in the database
if [[ -z $USER_CHECK ]]
then
  #insert user
  INSERT_USER=$($PSQL "INSERT INTO game_data (username) VALUES ('$username')")

  #greetings new user name
  echo -e "\nWelcome, $username! It looks like this is your first time here."
else
  #Get user games info
  GAMES_INFO=$($PSQL "SELECT games_played,best_game FROM game_data WHERE username = '$username'")
  #Read info and print
  echo $GAMES_INFO | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

#Ask to guess a number
echo -e "\nGuess the secret number between 1 and 1000:"
read numtry

#Count 1st try
CONT=1

#while input is not equal to the randomly generated number
while [ $numtry != $num ]
do
    if [[ $numtry -lt $num ]] && [[ $numtry =~ ^[0-9]+$ ]]
    then
        echo -e "\nIt's higher than that, guess again:"
    elif [[ $numtry -gt $num ]] && [[ $numtry =~ ^[0-9]+$ ]]
    then
        echo -e "\nIt's lower than that, guess again:"
    elif ! [[ $numtry =~ ^[0-9]+$ ]]
    then
        echo -e "\nThat is not an integer, guess again:"
    fi
    read numtry
    ((CONT++))
done

#if number is equal to the randomly generated number
if  [[ $numtry == $num ]]
then
  echo "You guessed it in $CONT tries. The secret number was $num. Nice job!"
fi

#check number of games and best socre of user
GAMES_INFO=$($PSQL "SELECT games_played,best_game FROM game_data WHERE username = '$username'")
echo $GAMES_INFO | while read GAMES_PLAYED BAR BEST_GAME
do
  #If its the 1st game
  if [[ BEST_GAME -eq 0 ]] && [[ GAMES_PLAYED -eq 0 ]]
  then
    #update game played and best game
    DATA_UPDATE=$($PSQL "UPDATE game_data SET games_played = 1, best_game = $CONT WHERE username = '$username'")
  #If player has more than 1 game
  elif [[ $GAMES_PLAYED -ne 0 ]]
  then
  #Update games played + 1
    GAME_SUM=$(($GAMES_PLAYED + 1))
    GAME_UDP=$($PSQL "UPDATE game_data SET games_played = $GAME_SUM WHERE username = '$username'")
  #If player made a best score (lower tries)
  elif [[ $CONT -lt $BEST_GAME ]]
  then
    #Update score (tries)
    BEST_UDP=$($PSQL "UPDATE game_data SET best_game = $CONT WHERE username = '$username'")
  fi
done
