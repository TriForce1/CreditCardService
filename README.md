# Credit Card Service

This service validates credit numbers using the luhn algorithm. Api can be accessed at http://credit_card_api_service.herokuapp.com


## Usage
http://credit_card_api_service.herokuapp.com/api/v1/credit_card/validate?card_number=4024097178888052

card_number value can be changed to whatever number you would like to validate. The service will return a json string containing the number you entered and the card's validation status.e.g
 ```
 {"card":"4024097178888052","validated":false}
 ```
If the number you enter is valid then validated will be equal to true.
