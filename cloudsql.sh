#!/bin/bash
#ASSIGNMENT 4 :Part b) Kubernetes and Cloud SQL

echo "Creating CLOUD SQL Instance......."
gcloud sql instances create cdm-sql-ins --tier=db-f1-micro --region=us-central1
echo "Creating CLOUD SQL Database......."
gcloud sql databases create emp_mgmt --instance=cdm-sql-ins
echo "Creating CLOUD SQL User..........."
gcloud sql users create application_user --instance=cdm-sql-ins
echo "Getting IP of SQL Instance........"
gcloud sql instances describe cdm-sql-ins --format=json > opt.json
ip=$(python jsonparse.py)
cat << EOF | gcloud sql connect cdm-sql-ins --user=root

#following are SQL query commands to use database and create tables and entry values
USE emp_mgmt;

#DDL commands
CREATE TABLE test (name VARCHAR(10), lastname VARCHAR(10));

#DML commands
INSERT INTO test VALUES ('raj', 'kapoor');
INSERT INTO test VALUES ('kishore', 'kumar');
INSERT INTO test VALUES ('rajesh', 'khanna');
SELECT * FROM test;
UPDATE test SET name='updated' WHERE name=='rajesh';
SELECT * FROM test;
DELETE FROM test WHERE name==rajesh;
SELECT * FROM test;

#DCL commands
GRANT SELECT, INSERT on employee_mgmt.test to application_user;
SHOW GRANTS application_user;
REVOKE SELECT, INSERT on employee_mgmt.test from application_user;
SHOW GRANTS application_user;

EOF
