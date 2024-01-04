--------- SCHEMA for S'eat restaurant reservations database

-- create a customers table that will hold information about individual reservation makers (customers)
CREATE TABLE "customers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "phone" TEXT NOT NULL,
    PRIMARY KEY("id") AUTOINCREMENT
);

-- create a restaurant table that will hold information about each restaurant including its name, contact info, and cuisine type
CREATE TABLE "restaurants" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "cuisine" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    PRIMARY KEY("id") AUTOINCREMENT
);

-- create a table for each restaurant's operating hours that will be referenced with a foreign key to restaurant id to
-- identify the restaurant. a future enhancement would be to provide a mechanism for indicating that the restaurant is
-- closed for a holiday or special event
CREATE TABLE "operating_hours" (
    "id" INTEGER,
    "restaurant_id" INTEGER,
    "open_time" TEXT NOT NULL DEFAULT '00:00',
    "close_time" TEXT NOT NULL DEFAULT '00:00',
    "days" TEXT NOT NULL CHECK ("days" IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("restaurant_id") REFERENCES "restaurants"("id")
);

-- create a tables table that will link to the restaurant and the reservation. it will have information at the table level about
-- when and whether it is available or not (which will be indicated with a trigger)
CREATE TABLE "tables" (
    "id" INTEGER,
    "restaurant_id" INTEGER,
    "reservation_id" INTEGER,
    "date" DATE NOT NULL,
    "start_time" TEXT NOT NULL DEFAULT '00:00',
    "available" INTEGER NOT NULL CHECK ("available" IN (0,1)), -- 1 for available, 0 for not available
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("restaurant_id") REFERENCES "restaurants"("id"),
    FOREIGN KEY("reservation_id") REFERENCES "reservations"("id")
);

-- create a reservations table that will link the restaurant and the customer to the reservation with information supplied by
-- the customer like how many guests, any special requestions, the occasion as well as the date and time of the reservation.
-- it will also be linked to the table level
CREATE TABLE "reservations" (
    "id" INTEGER,
    "restaurant_id" INTEGER,
    "customer_id" INTEGER,
    "table_id" INTEGER,
    "guests" INTEGER NOT NULL,
    "special_req" TEXT,
    "occasion" TEXT,
    "date" DATE NOT NULL,
    "start_time" TEXT NOT NULL DEFAULT '00:00',
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("restaurant_id") REFERENCES "restaurants"("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id"),
    FOREIGN KEY("table_id") REFERENCES "tables"("id")
);

-- create a points table that will connect to customer id as a foreign key that will contain the current point balance
CREATE TABLE "points" (
    "id" INTEGER,
    "customer_id" INTEGER,
    "points_balance" NOT NULL INTEGER DEFAULT 0,
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("customer_id") REFERENCES "customer"("id")
);

-- create a points transactions table that will contain the amount of the points transaction, whether it was a deposit or
-- a withdrawal, the reason or description, and the date/time of the transaction. this would link to the customer by foreign key.
CREATE TABLE "points_transactions" (
    "id" INTEGER,
    "customer_id" INTEGER,
    "points" NOT NULL INTEGER,
    "transaction_type" TEXT NOT NULL CHECK ("transaction_type" IN ('deposit', 'withdrawal')),
    "date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "description" NOT NULL TEXT,
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("customer_id") REFERENCES "customer"("id")
);

-- create a reservation history table that links to restaurant id, customer id, and reservation id. this would aid in
-- analytics or historical exploratory data analysis
CREATE TABLE "reservation_hist" (
    "id" INTEGER,
    "restaurant_id" INTEGER,
    "customer_id" INTEGER,
    "reservation_id" INTEGER,
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("restaurant_id") REFERENCES "restaurants"("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id"),
    FOREIGN KEY("reservation_id") REFERENCES "reservations"("id")
);

-- create a user account table that would contain customer or restaurant username and password information as well as a
-- member since field for possible loyalty purposes. it would link to restaurant and customer tables with a foreign key.
CREATE TABLE "accounts" (
    "id" INTEGER,
    "customer_id" INTEGER,
    "restaurant_id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN 'restaurant' OR 'customer'),
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    "member_since" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id") AUTOINCREMENT,
    FOREIGN KEY("restaurant_id") REFERENCES "restaurants"("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id")
);
