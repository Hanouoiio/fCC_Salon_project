#!/bin/bash
# Script for getting customers appointments and their info
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~ Hello thy, who dareth come forth before Me ~~\n"

# Loop until a valid service ID is selected
SERVICE_NAME=""
INVALID_SELECTION=0

while [[ -z $SERVICE_NAME ]]
do
  if [[ $INVALID_SELECTION -eq 1 ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
  else
    echo -e "Which of these services would win thy favor?"
  fi

  # Display available services
  ALL_SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")"
  echo "$ALL_SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME_READ
  do
    echo "$SERVICE_ID) $SERVICE_NAME_READ"
  done

  # Read selected service ID
  read SERVICE_ID_SELECTED

  # Validate that selection is a number before running SQL
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
  fi

  # If service_name is still empty, flag invalid selection to re-prompt
  if [[ -z $SERVICE_NAME ]]
  then
    INVALID_SELECTION=1
  fi
done

# Read phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Look up customer name
CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"

# If customer no exist, read name and insert into database
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
fi

# Fetch customer_id
CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"

# Read appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"

# Final output
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."