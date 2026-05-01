#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Determine if the input is a number (atomic_number) or a string (symbol/name)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    CONDITION="e.atomic_number = $1"
  else
    CONDITION="e.symbol = '$1' OR e.name = '$1'"
  fi

  # Query the database
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p ON e.atomic_number = p.atomic_number INNER JOIN types t ON p.type_id = t.type_id WHERE $CONDITION;")

  # Check if the element was found
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    # Parse the result and output the formatted string
    echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi