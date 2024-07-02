#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~ Welcome to my Salon ~~~\n"
echo -e "What can I do for you?"

MAIN_MENU() {
  echo -e "$1"
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read -r SERVICE_ID SERVICE_NAME; do
    echo -e "${SERVICE_ID}) ${SERVICE_NAME}"
  done
  echo -e "\nPlease select a service... "
  read SERVICE_ID_SELECTED

  service_exists=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ $service_exists -eq 0 ]]; then
    echo -e "\nNot an option...try again"
    MAIN_MENU "Please select a valid option:"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nNo record for that number...what is your name?"
      read CUSTOMER_NAME

      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
    fi

    echo -e "\nWhat time would you like your appointment, $CUSTOMER_NAME?"
    read SERVICE_TIME

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    $PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', (SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED)"
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
