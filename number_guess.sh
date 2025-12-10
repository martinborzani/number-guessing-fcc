#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Buscar usuario: games_played | best_game
USER_ROW=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_ROW ]]
then
  # Usuario nuevo
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');" > /dev/null
  GAMES_PLAYED=0
  BEST_GAME=
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Usuario existente -> separar columnas
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_ROW"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Número secreto 1–1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
#hola #hola #hola #hola
while true
do
  read GUESS

  # Validar entero (no cuenta como intento)
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  # A partir de acá sí cuenta el intento
  (( NUMBER_OF_GUESSES++ ))

  if (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    # Adivinó
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Actualizar estadísticas
    NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      # Primera partida o nuevo récord
      $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';" > /dev/null
    else
      # Solo suma games_played
      $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME';" > /dev/null
    fi

    break
  fi
done
