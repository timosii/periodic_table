#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
else
  GIVEN_INFO=$1
  if [[ $GIVEN_INFO =~ ^[0-9]+$ ]]
  then
    NUMBER_ATOM=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $GIVEN_INFO")
    if [[ -z $NUMBER_ATOM ]]
    then 
      echo "I could not find that element in the database."
      exit 0
    fi
  else
    NUMBER_ATOM=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$GIVEN_INFO'")
    if [[ -z $NUMBER_ATOM ]]
    then
      NUMBER_ATOM=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$GIVEN_INFO'")
      if [[ -z $NUMBER_ATOM ]]
      then 
        echo "I could not find that element in the database."
        exit 0
      fi
    fi
  fi

  CUMULATIVE_REQUEST=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass,   melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties ON elements.atomic_number   = properties.atomic_number LEFT JOIN types USING(type_id) WHERE elements.atomic_number = $NUMBER_ATOM")

  # Сохранить IFS
  OLDIFS=$IFS
  # Установить IFS на вертикальную черту
  IFS='|'

  # Преобразовать строку в массив
  read -a VALUES <<< "$CUMULATIVE_REQUEST"

  # Вернуть IFS к исходному значению
  IFS=$OLDIFS

  # Извлечь значения из массива
  NUMBER=${VALUES[0]}
  NAME=${VALUES[1]}
  SYMBOL=${VALUES[2]}
  TYPE=${VALUES[3]}
  MASS=${VALUES[4]}
  MELT=${VALUES[5]}
  BOIL=${VALUES[6]}

  echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

fi