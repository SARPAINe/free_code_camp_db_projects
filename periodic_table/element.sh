#!/bin/bash

# Define PSQL command setup
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Function to fetch data from the database
fetch_data() {
  local query=$1
  local result=$(echo $($PSQL "$query") | sed 's/ //g')
  echo "$result"
}

# Main entry point for script
main() {
  local element=$1
  if [[ -z $element ]]; then
    echo "Please provide an element as an argument."
  else
    get_element_details "$element"
  fi
}

# Function to find element and print its details
get_element_details() {
  local input=$1
  local search_column="atomic_number"

  # Check if the input is a number or text for atomic_number or symbol/name
  if [[ ! $input =~ ^[0-9]+$ ]]; then
    search_column="symbol='$input' OR name='$input'"
  else
    search_column="atomic_number='$input'"
  fi

  local atomic_number=$(fetch_data "SELECT atomic_number FROM elements WHERE $search_column;")

  if [[ -z $atomic_number ]]; then
    echo "I could not find that element in the database."
  else
    # Collect all necessary properties
    local name=$(fetch_data "SELECT name FROM elements WHERE atomic_number=$atomic_number;")
    local symbol=$(fetch_data "SELECT symbol FROM elements WHERE atomic_number=$atomic_number;")
    local atomic_mass=$(fetch_data "SELECT atomic_mass FROM properties WHERE atomic_number=$atomic_number;")
    local melting_point_celsius=$(fetch_data "SELECT melting_point_celsius FROM properties WHERE atomic_number=$atomic_number;")
    local boiling_point_celsius=$(fetch_data "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$atomic_number;")
    local type=$(fetch_data "SELECT type FROM types JOIN properties ON types.type_id=properties.type_id WHERE atomic_number=$atomic_number;")

    # Output element information
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
  fi
}

# Run the main program passing all arguments
main $1
