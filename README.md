🏋️‍♂️ Gym Management System Database

A relational SQL database system created in Microsoft SQL Server to centralize gym operations, track member subscriptions, manage trainer assignments, and organize class schedules.

❓ Why This System Was Built

Managing a gym manually or through disjointed spreadsheets creates several operational problems:

Untracked Expirations: Subscriptions lapse without real-time visibility into who is active versus expired.

Data Inconsistencies: Members, payments, and assigned trainers become disconnected, leading to orphan records or missing contact info.

Scheduling Conflicts: Classes, dates, and member enrollments are difficult to cross-reference and filter efficiently.

💡 Core Solution

This database solves those issues by centralizing all gym data into a unified, relational structure:

Automated Expiry Calculations: Dynamic functions compute remaining subscription days in real-time without manual updates.

Data Integrity: Foreign key rules, junction tables, and a dedicated cascade-deletion procedure keep all dependent records clean.

Standardized Operations: Parameterized stored procedures handle all inserts and updates to avoid manual data-entry errors.

🗄️ Database Architecture & Schema

The database consists of 14 interconnected tables:

Membershiptype: Stores plan types (membershiptype) and prices (price).

ClassDifficulty: Stores difficulty levels (classdifficulty) and durations (classduration).

trainer: Stores trainer profiles including name, sex, and work hours.

membership: Links membership descriptions to membership types.

Class: Stores class details linked to trainers and difficulty levels.

Memberr: Stores member demographic details, assigned trainer, and training plan ID.

trainingplan: Stores diet and workout plans assigned to members and trainers.

Subscription: Tracks start dates, end dates, status, member IDs, and membership IDs.

Payment: Records payment type, amount, date, member ID, and linked subscription ID.

Classdate: Tracks specific dates for scheduled classes.

Memberphoneno: Stores phone numbers for members (supports multi-valued numbers).

trainerphoneno: Stores phone numbers for trainers.

trainercertificate: Stores certificates earned by trainers.

enrollsin: Junction table tracking member enrollments in classes.

⚙️ Functions and Stored Procedures

User-Defined Functions (UDFs)

DaysUntilExpiry(): Returns a table containing active subscription details along with calculated remaining days (DATEDIFF) until the subscription end date.

fn_FilterClasses(): Inline table-valued function filtering classes dynamically by class type, date, or difficulty level.

Stored Procedures

Insertion Procedures: Dedicated procedures for inserting data into all 14 tables (e.g., sp_Insert_Member, sp_Insert_Trainer, sp_Insert_Subscription).

Update Procedures: Parameterized procedures using ISNULL() logic to update existing entries across tables (e.g., sp_Update_Member, sp_Update_Trainer, sp_Update_Payment).

DeleteFromTable: Centralized multi-table cascading deletion procedure. Safely removes a record and its foreign key dependencies for entities like Memberr, trainer, Class, membership, Subscription, and junction tables.

📊 Included Analytical Queries

The script executes 5 specific analytical queries at the end:

Lists members along with their subscription status and days remaining until expiration.

Displays all available classes along with their scheduled dates ordered chronologically.

Groups members by assigned trainer to show individual trainer workloads.

Identifies members who are not enrolled in any gym classes.

Lists classes ordered by difficulty in descending order.

🚀 How to Run

Open SQL Server Management Studio (SSMS).

Execute gym_script.sql against your SQL Server instance.

The script will automatically drop existing tables if present, construct the entire schema, populate seed data, compile all functions/procedures, and output query results.
