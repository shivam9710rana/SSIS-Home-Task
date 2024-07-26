# Execution Report

## Overview
This report provides the details of the execution of the SSIS ETL process, including the number of records processed, the records rejected during the data cleaning phase, and the challenges encountered.

## Results of the Execution

### Total Records Processed
- **Total Records:** 33

### Initial Staging Table Load
- **Records Loaded:** 33

### Data Cleaning and Validation

#### Rejected Records
- **Rejected Count:** 12
  
During the data cleaning phase, a total of 12 records were rejected. Below is a breakdown of the rejection reasons:
| Rejection Reason                | Count |
|---------------------------------|-------|
| NULL User                       | 1     |
| Duplicate Record                | 3     |
| Age Negative                    | 1     |
| Invalid Email                   | 2     |
| Invalid/Empty Date              | 2     |
| Future Date                     | 1     |
| Too Old Date                    | 1     |
| PurchaseTotal Value Too Large   | 1     |

#### Clean Records
- **Records Cleaned and Ready for Production Load:** 21

## Challenges and Resolutions

1. **Data Type Mismatches:**
   - **Challenge:** Ensured proper conversion of data types during the transformation process.
   - **Resolution:** Handled this issue using the data conversion component, converting the strings coming from the source file to the correct database types.

2. **Invalid Dates:**
   - **Challenge:** Corrected by handling date format issues and using default values for invalid dates.
   - **Resolution:** To handle this, I used the script component transformation using the `TryParse` method to handle the invalid, empty date values and validated non-numeric values for the Age column.

3. **Duplicate Records:**
   - **Challenge:** Identified and removed duplicates.
   - **Resolution:** Based on a combination of UserID and FullName, I deleted the duplicate records and retained the latest one based on the LastLogin column.

4. **Data Integrity and Consistency:**
   - **Challenge:** Ensuring data consistency and accuracy in the staging table before moving to production.
   - **Resolution:** Applied comprehensive data cleaning rules and validation checks to ensure data integrity.
     
## Conclusion
The ETL process successfully handled the loading and cleaning of data, with 21 records passing the validation checks and being ready for the production load. The challenges encountered were addressed through various validation and cleaning techniques, ensuring robust data processing.

