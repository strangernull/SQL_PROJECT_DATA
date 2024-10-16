-- create table
CREATE TABLE  job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

SELECT * FROM job_applied

-- insert data
INSERT INTO job_applied
            (
                job_id,
                application_sent_date,
                custom_resume,
                resume_file_name,
                cover_letter_sent,
                cover_letter_file_name,
                status
            )
VALUES      (
            1,
            '2024-02-01',
            true,
            'resume_01.pdf',
            true,
            'cover_letter_o1.pdf',
            'submitted'),
            (
            2,
            '2024-02-02',
            false,
            'resume_02.pdf',
            false,
            NULL,
            'interview scheduled'
            ),
            (
            3,
            '2024-02-03',
            true,
            'resume_03.pdf',
            true,
            'cover_letter_)3.pdf',
            'ghosted'
            ),
            (
            4,
            '2024-02-04',
            true,
            'resume_04.odf',
            false,
            NULL,
            'submitted'
            ),
            (
            5,
            '2024-02-05',
            false,
            'resume_05.pdf',
            true,
            'cover_letter05.pdf',
            'rejected'
            );

SELECT * FROM job_applied

-- ALter table: add

ALTER TABLE job_applied
ADD contact VARCHAR(50);

-- Update table:
/**
    UPDATE table_name            : used to modify the existing data in a table
    SET column_name = 'new_name' : specifies the  column to be updated and the new value for that column
    WHERE condition              :filters which rows to update based on a condition.
**/

UPDATE job_applied
SET contact = 'Erlich Bachman'
WHERE job_id = 1;

UPDATE job_applied
SET contact = 'Dinesh Chugtai'
WHERE job_id = 2;

UPDATE job_applied
SET contact = 'Bertram Gilfoyle'
WHERE job_id = 3;

UPDATE job_applied
SET contact  = 'Jian Yang'
WHERE job_id = 4;

UPDATE job_applied
SET contact  ='Big Head'
WHERE job_id = 5;

SELECT * FROM job_applied

-- Alter table: rename column
/**
    ALTER TABLE table_name
    RENAME COLUMN column_name TO new_name
**/

ALTER TABLE job_applied
RENAME COLUMN contact TO contact_name;

-- ALter column
/**
change data type:
    
    ALTER TABLE table_name
    ALTER COLUMN column_name TYPE new_data_type       !: limitation: Certain data types can not be changed.

set/change default value: Assign a default value to the column, which will be used for new rows if no value is specified.
    
    ALTER TABLE table_name
    ALTER COLUMN column_name SET DEFAULT default_value;

Drop default value: Remove the default value from the column if one exists.
    
    ALTER TABLE table_name
    ATLER COLUMN column_name DROP DEFAULT;
**/

ALTER TABLE job_applied
ALTER COLUMN contact_name TYPE text;

-- Drop column: delete a column
/**
    ALTER COLUMN table_name
    DROP COLUMN column_name;

**/

ALTER TABLE job_applied
DROP COLUMN contact_name;

-- Drop table
DROP TABLE job_applied;