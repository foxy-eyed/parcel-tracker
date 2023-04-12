# App for tracking Package delivery

## Setup
0. Clone the repo:
    ```
    $ git clone git@github.com:foxy-eyed/parcel-tracker.git
    ```
1. In project root:
    ```
    $ docker compose build
    ```
2. Create database, run migrations and seed data:
    ```
    $ docker compose run app rails db:prepare
    $ docker compose run app rails db:seed
    ```
    With seeds you will be able to use CURL examples below without any modifications.

3. Finally
    ```
    $ docker compose up
    ```
    Now you have app running at http://localhost:9292 and ready to process your requests.

## API

### Start track the package (create)
```
curl -X POST 'http://localhost:9292/packages' \
    -H 'X-User-ID: defb5761-02b8-45ed-b660-8092a4c8d884' \
    -H "Content-type: application/json" \
    -d '{"package": {"track": "HP0000034"}}'
```

### Subscribe to package notifications
```
curl -X POST 'http://localhost:9292/packages/5ee90d5a-d313-410d-a1b4-36d383b02ab6/notifications' \
    -H 'X-User-ID: defb5761-02b8-45ed-b660-8092a4c8d884' \
    -H "Content-type: application/json" \
    -d '{"email":"anna@test.com", "phone":"+1 172-345-5678", "enabled":["phone", "email"]}'
```

### Show current user subscription status
```
curl -X GET 'http://localhost:9292/packages/5ee90d5a-d313-410d-a1b4-36d383b02ab6/notifications' \
-H 'X-User-ID: defb5761-02b8-45ed-b660-8092a4c8d884' \
-H "Content-type: application/json"
```

### Get Package Info
```
curl -X GET 'http://localhost:9292/packages/5ee90d5a-d313-410d-a1b4-36d383b02ab6' \
-H "Content-type: application/json"
```

### List All Packages
```
curl -X GET 'http://localhost:9292/packages' \
-H "Content-type: application/json"
```

### FastDelivery Webhook API

#### Arrived
```
curl -X POST 'http://localhost:9292/webhook/fast_delivery/arrived/FD0001' \
-H "Content-type: application/json" \
-d '{"location":{"name": "Moscow"}, "time":"2023-04-11", "weight": {"value":100.0, "unit": "g"}}'
```

#### Dispatched
```
curl -X POST 'http://localhost:9292/webhook/fast_delivery/departed/FD0001' \
-H "Content-type: application/json" \
-d '{"location":{"name": "Samara"}, "time":"2023-04-12", "weight": {"value":100.0, "unit": "g"}}'
```

#### Unsuccessful Delivery Attempt
```
curl -X POST 'http://localhost:9292/webhook/fast_delivery/deliver-attempt/FD0001' \
-H "Content-type: application/json" \
-d '{"state":"failed"}'
```

#### Successful Delivery
```
curl -X POST 'http://localhost:9292/webhook/fast_delivery/deliver-attempt/FD0001' \
-H "Content-type: application/json" \
-d '{"state":"successful"}'
```

### HappyPackage Webhook API

#### Arrived
```
curl -X POST 'http://localhost:9292/webhook/happy_package/arrived/HP0001' \
-H "Content-type: application/json" \
-d '{"location":"Moscow", "time":"2023-04-11", "weight": "100.0g"}'
```

#### Dispatched
```
curl -X POST 'http://localhost:9292/webhook/happy_package/departed/HP0001' \
-H "Content-type: application/json" \
-d '{"location":"Samara", "time":"2023-04-12", "weight": "100g"}'
```

#### Unsuccessful Delivery Attempt
```
curl -X POST 'http://localhost:9292/webhook/happy_package/deliver-attempt/HP0001' \
-H "Content-type: application/json" \
-d '{"success":false}'
```

#### Successful Delivery
```
curl -X POST 'http://localhost:9292/webhook/happy_package/deliver-attempt/HP0001' \
-H "Content-type: application/json" \
-d '{"success":true}'
```
