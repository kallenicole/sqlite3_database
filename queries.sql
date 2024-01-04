------- QUERIES for S'eat restaurant reservation database

-- Find how many dining reward points Kalle has
SELECT "points_balance"
FROM "points"
WHERE "customer_id" IN (
    SELECT "id"
    FROM "customers"
    WHERE "first_name" = 'Kalle'
    AND "last_name" = 'Georgiev'
);


-- Find out when 'The Green Pickle' is open for business
SELECT "o"."open_time",
       "o"."close_time",
       "o"."days"
FROM "operating_hours" as "o"
LEFT JOIN "restaurants" as "rest"
ON "rest"."id" = "o"."restaurant_id"
WHERE "rest"."name" = 'The Green Pickle';


-- Find a table at 'Cafe Boulud' between January 20-26, 2024
SELECT *
FROM "tables" as "t"
LEFT JOIN "restaurants" as "rest"
ON "t"."restaurant_id" = "rest"."restaurant_id"
WHERE "t"."date" BETWEEN '2024-01-20' AND '2024-01-26';


-- Find the 100 most popular restaurants YTD (busiest in terms of reservations)
SELECT "rest"."id",
       "rest"."name",
       COUNT("r"."id") as "reservation_count"
FROM "reservations" as "r"
JOIN "restaurants" as "rest"
ON "r"."restaurant_id" = "rest"."id"
WHERE "r"."date" >= '2023-01-01'
GROUP BY "rest"."name"
ORDER BY "reservation_count" DESC
LIMIT 100;


-- Find the 10 customers with the most reservations in the last full month
SELECT "c"."first_name",
       "c"."last_name",
       COUNT("r"."id") AS "reservation_count"
FROM "customers" AS "c"
JOIN "reservations" as "r"
ON "c"."id" = "r"."customer_id"
WHERE "r"."date" >= DATE('now', 'start of month', '-1 month')
AND "r"."date" < DATE('now', 'start of month') -- a good resource: https://www.sqlite.org/lang_datefunc.html
ORDER BY "reservation_count" DESC
LIMIT 10;


-- Find all of the customers names and phone numbers that have made reservations at 'Le Cirque' for tomorrow
-- that have listed birthday as their occasion ordered by last name alphabetically
SELECT "c"."first_name",
       "c"."last_name",
       "c"."phone"
FROM "customers" as "c"
JOIN "reservations" as "r"
ON "c"."id" = "r"."customer_id"
JOIN "restaurants" as "rest"
ON "r"."restaurant_id" = "rest"."id"
WHERE "r"."date" = '2023-12-10'
AND "r"."occasion" = 'birthday'
AND "rest"."name" = 'Le Cirque'
ORDER BY "c"."last_name";


------- UPDATES
-- Add a new reservation
INSERT INTO "reservations" ("guests", "special_req", "occasion", "date", "start_time")
VALUES (2, 'vegan', 'anniversary', '2023-12-20', '18:00');

-- Add a new customer
INSERT INTO "customers" ("first_name", "last_name", "email", "phone")
VALUES ("Albert", "Einstein", "emc2@gmail.com", "555-555-5555")

-- Add a new account
INSERT INTO "accounts" ("type", "username", "password", "member_since")
VALUES ('restaurant', 'lamaisonfromage', 'Tg09!#fgcx092245fwZ', "2023-12-08 11:24:47");

-- Add a new table
INSERT INTO "tables" ("restaurant_id", "reservation_id", "date", "start_time", "available")
VALUES (115, 120, '2023-12-22', '17:00', 1);

-- Add some points
INSERT INTO "points_transactions" ("customer_id", "restaurant_id", "points", "transaction_type", "date", "description")
VALUES (190, 155, 100, 'deposit', '2023-11-18', 'redeemed')


------- TRIGGERS
-- Update the points balance for a customer (this would be triggered by some kind of activity in the points_transactions table)
CREATE TRIGGER update_points_balance
AFTER INSERT ON "points_transactions"
BEGIN
  UPDATE "points"
  SET "points_balance" = "points_balance" +
    CASE
      WHEN NEW."transaction_type" = 'deposit' THEN NEW."points"
      ELSE -NEW."points"
    END
  WHERE "customer_id" = NEW."customer_id";
END;

-- Make a table unavailable in "tables" after a reservation is made according to the restaurant, time, and date
CREATE TRIGGER table_unavailable
AFTER INSERT ON "reservations"
BEGIN
  UPDATE "tables"
    SET "available" = 0
    WHERE "id" = NEW."table_id"
    AND "restaurant_id" = NEW."restaurant_id"
    AND "start_time" = NEW."start_time"
    AND "date" = NEW."date";
END;

------- TRANSACTIONS
-- A sample transaction that will add or subtract points for a customer based on activity
BEGIN TRANSACTION;
UPDATE "points"
SET "points_balance" = "points_balance" + 100 - 500   -- customer_id 157 earned 100 points, and used 500
WHERE "customer_id" = 157;

INSERT INTO "points_transactions" ("customer_id", "points", "transaction_type", "description")
VALUES(157, 100, 'deposit', 'points earned');

INSERT INTO "points_transactions" ("customer_id", "points", "transaction_type", "description")
VALUES(157, 500, 'withdrawal', 'points redeemed');

COMMIT;


------- INDEXES
-- Create an index to get reservations by a certain date
-- (it's a really active, nationwide database, I don't want to bog it down with too many indexes)
CREATE INDEX "by_date"
ON "reservations"("date");


------- VIEWS
-- Create a view that would group and return the restaurants by cuisine
CREATE VIEW "cuisine" AS
SELECT "name", "cuisine", "location"
FROM "restaurants"
GROUP BY "cuisine"
ORDER BY "name";


-- Create a view that would pull all current reservations happening today including restaurant and customer information
CREATE VIEW "current_reservations" AS
SELECT "c"."first_name",
       "c"."last_name",
       "rest"."name" AS "restaurant_name",
       "r"."guests"L,
       "r"."special_req",
       "r"."occasion",
       "r"."date",
       "r"."start_time"
FROM "customers" as "c"
JOIN "reservations" as "r"
ON "r"."customer_id" = "c"."id"
JOIN "restaurants" as "rest"
ON "rest"."id" = "r"."restaurant_id"
WHERE "r"."date" = DATE('now');
