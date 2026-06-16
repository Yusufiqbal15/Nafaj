-- Add missing fields to jobs table for job portal feature
-- Check and add company column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'company';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jobs ADD COLUMN company VARCHAR(255) AFTER budget', 'SELECT "company column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add phone column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'phone';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jobs ADD COLUMN phone VARCHAR(50) AFTER company', 'SELECT "phone column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add job_type column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'job_type';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jobs ADD COLUMN job_type VARCHAR(50) DEFAULT "Full-time" AFTER phone', 'SELECT "job_type column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add salary_text column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'salary_text';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jobs ADD COLUMN salary_text VARCHAR(255) DEFAULT "Negotiable" AFTER job_type', 'SELECT "salary_text column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add sector column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'sector';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jobs ADD COLUMN sector VARCHAR(255) AFTER salary_text', 'SELECT "sector column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Make user_id nullable since some jobs may be posted without login
ALTER TABLE jobs MODIFY COLUMN user_id INT NULL;

-- Make budget nullable since some jobs use salary_text instead
ALTER TABLE jobs MODIFY COLUMN budget DECIMAL(10,2) NULL DEFAULT 0;
