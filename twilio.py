from twilio.rest import Client

account_sid = 'ACf06fa1c0fbe207e26d94f5d61c0b3cd2'
auth_token = '[AuthToken]'
client = Client(account_sid, auth_token)


# TODO: periodically retrieve the phone numbers and weeks postpartum from gSheets

# TODO: send SMS to patient's phone number
message = client.messages.create(
    to='+6591819132'
)

print(message.sid)
