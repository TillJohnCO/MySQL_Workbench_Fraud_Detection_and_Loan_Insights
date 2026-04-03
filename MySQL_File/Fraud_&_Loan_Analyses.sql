# Create creditcard_capstone database
CREATE database creditcard_capstone;

# Successfully loaded the Customer & Transaction tables into this db via the Table Data Import Wizard;
# Tables were previously cleaned as part of the Excel portion of this capstone project;
# However, as a part of troubleshooting import, I had to change the format of the time column to text in the .csv file;
# Converting time to time format; first, adding a new column

ALTER TABLE cdw_sapp_transaction ADD COLUMN TRANS_TIME TIME;
# column successfully added

# Using UPDATE & STR_TO_DATE() commands to convert time data into time format
UPDATE cdw_sapp_transaction
SET TRANS_TIME = STR_TO_DATE(Time, '%H:%i:%s');
-- STR_TO_DATE function converts text values to time; %H = hours; %i = minutes; %s = seconds

-- I received error code 1175 which indicates I'm running in safe mode
-- Since I'm running this only on my local PC, I'm disabling the safe mode
-- Disable Safe Update Mode
SET SQL_SAFE_UPDATES = 0;

-- Run update query
UPDATE cdw_sapp_transaction
SET TRANS_TIME = STR_TO_DATE(Time, '%H:%i:%s');

-- Re-enable Safe Update Mode
SET SQL_SAFE_UPDATES = 1;

# Update appears successful; looking at column values to ensure format change worked
select TRANS_TIME from cdw_sapp_transaction;
# reformatting appears successful; all time is in military time; all time values prior to 10:00:00 have a leading zero

# dropping prior Time column
alter table cdw_sapp_transaction drop column Time;
# old Time column has been successfully dropped

# Renaming TRANS_TIME column to Time
alter table cdw_sapp_transaction CHANGE COLUMN TRANS_TIME Time TIME;
# TRANS_TIME column successfully renamed at Time

-- Functional Requirement 3.6 - Calculating the 3 months with the highest transaction volume
SELECT MONTH_NAME, Count(TRANSACTION_ID) as TRANS_COUNT
FROM cdw_sapp_transaction
group by MONTH_NAME
order by TRANS_COUNT desc
limit 3;

-- Formatting Transaction_Amount column in cdw_sapp_transition table to 2 decimals for better display of results.
ALTER TABLE cdw_sapp_transaction MODIFY COLUMN Transaction_Amount DECIMAL(10, 2);

-- Functional Requirement 3.7 - top 10 customers with the highest transaction amounts (in dollar value). 
SELECT c.CUST_NAME as Customer, SUM(t.Transaction_Amount) as Total_Purchases
FROM cdw_sapp_customer as c
LEFT JOIN cdw_sapp_transaction as t on c.CUST_SSN=t.CUST_SSN
GROUP BY Customer
ORDER BY Total_Purchases DESC
LIMIT 10;

-- Viewing Fraudulent data to see how it's displayed
Select *
From cdw_sapp_transaction
Limit 10;

-- I imported the Is_Online & Fraudulent columns as binary which caused all the
-- values in these fields to display as "BLOB". I'm reformatting these fields as Text.
ALTER TABLE cdw_sapp_transaction MODIFY COLUMN Is_Online TEXT;
ALTER TABLE cdw_sapp_transaction MODIFY COLUMN Fraudulent TEXT;

-- Functional Requirement 3.8 - How many transactions are fraudulent?
select count(fraudulent) as Num_of_Frauds
from cdw_sapp_transaction
where Fraudulent = 1;

-- Functional Requirement 3.10 - How many fraudulent transactions were made online?
Select count(transaction_ID) as Online_Fraud_Count
from cdw_sapp_transaction
where Is_Online = 1 AND Fraudulent = 1;

-- Functional Requirement 3.11 - ID customers with more than 7 fraudulent transactions
select c.CUST_NAME AS Customer, count(t.TRANSACTION_ID) AS FRAUD_COUNT
FROM cdw_sapp_customer as c
left join cdw_sapp_transaction as t on c.CUST_SSN = t.CUST_SSN
Where Fraudulent = 1
GROUP BY Customer
having FRAUD_COUNT > 7
order by FRAUD_COUNT DESC;
