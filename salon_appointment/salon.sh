#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

LIST_SERVICE(){
  if [[ -z $1 ]]; then
    : # do nothing
  else
    echo -e "\n$1"
  fi

  echo "$($PSQL "select service_id, name from services")" | sed 's/^ *//g; s/|/)/g; s/ )/)/g'
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED
  OFFER_SERVICE
}

OFFER_SERVICE(){
  SERVICE_EXIST="$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")"
  
  if [[ -z $SERVICE_EXIST ]]; then
    LIST_SERVICE "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_EXIST="$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")"
    
    if [[ -z $CUSTOMER_EXIST ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # Insert new customer into the database
      INSERT_CUSTOMER_RESULT="$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
    else
      CUSTOMER_NAME=$(echo $CUSTOMER_EXIST | sed 's/^ *//g')
    fi
    
    echo -e "\nWhat time would you like your service, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # Insert appointment into the appointments table
    INSERT_APPOINTMENT_RESULT="$($PSQL "insert into appointments(customer_id, service_id, time) values((select customer_id from customers where phone='$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
    
    SERVICE_NAME="$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED" | sed 's/^ *//g')"
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Start the service selection process
LIST_SERVICE

