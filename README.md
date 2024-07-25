# SSIS Home Task

## Overview
This project demonstrates an ETL process using SQL Server Integration Services (SSIS) to load, transform, and incrementally update data from a staging table to a production table. The project includes **data cleaning**, **error handling**, and **logging**.

## Setup Instructions

### Prerequisites
- SQL Server
- SQL Server Management Studio (SSMS)
- Visual Studio with SSIS installed

### Steps to Set Up and Run the Solution

1. **Repository:**
    1.a. **Cloning the Git Repository:**
    ```bash
    git clone https://github.com/your-username/SSIS-Home-Task.git
    cd SSIS-Home-Task
    ```
    - Open Visual Studio and load the SSIS project from the `SSIS_Package` folder.

    1.b. **Downloading the Repository as a ZIP File:**
    - Click on the "Code" button and select "Download ZIP."
    - Unzip the downloaded file to a location on your machine.
    - Launch Visual Studio.
    - Go to File > Open > Project/Solution.
    - Navigate to the `SSIS_Package` folder from the unzipped content.
    - Select the .sln file to open the solution.

2. **Restore the Database Backup:**
    - Open SSMS and restore the provided zipped database backup file located in the `DatabaseBackup` folder.

3. **Configure Connection Managers:**
    - Ensure the connection strings in the SSIS package are correctly set to point to your SQL Server instance.
    - Update the connection strings to point to your SQL Server instance and the restored database.

4. **Run the SSIS Package:**
    - After all the configurations, you can execute the package.

## ETL Process and Methodologies

1. **Package Configurations:**
    - The package configurations are stored in a `package_config` table. It stores the details about the package, server, and database used.

2. **Logging:**
    - An `audit_log` table is used to keep track of the ETL process at various stages.
    - The log records include:
        - Starting status of the package execution.
        - Staging load completion.
        - Number of records inserted into the staging table after data cleaning.
        - Data cleaning results are stored in another log table `RejectedRecords` with their rejection reason.
        - Production load completion.
        - Number of new records inserted into the production table.
        - Number of existing records updated in the production table.
        - Final completion status of the package.

3. **Data Loading:**
    - The data from the CSV file is loaded into a staging table. During this stage, initial data validation is performed to ensure that the data conforms to the expected database schema and SQL data types.

4. **Data Cleaning:**
    - Data cleaning operations are performed on the data in the staging table and the rejected records are isolated in a separate log table for review. The following data cleaning steps are executed:
        - Removal of duplicate records based on key columns.
        - Validation and correction of data formats.
        - Handling of null values and erroneous data.
    - This step ensures that the data is clean and consistent before it is moved to the production table.

5. **Incremental Load into Production Table:**
    - The cleaned data is incrementally loaded into the production table. This involves:
        - Inserting new records that do not exist in the production table.
        - Updating existing records in the production table with the latest data from the staging table.
    - The number of new records inserted and existing records updated are logged in the `audit_log` table for tracking purposes.

6. **Error Handling:**
    - An `OnError` Event Handler is implemented to record any errors that occur during the SSIS package execution. Errors are logged into the `audit_log` table with detailed error messages and timestamps.
    - Stored procedures include TRY-CATCH blocks to handle exceptions. In case of an error, the transaction is rolled back to maintain data integrity, and the error details are logged.
    - These error handling mechanisms ensure that any issues are promptly identified and recorded, facilitating quick resolution and maintaining the robustness of the ETL process.

## Conclusion
This project demonstrates a comprehensive ETL process using SSIS, showcasing data integration, transformation, and incremental loading techniques.
