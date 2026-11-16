CREATE DATABASE nexora_ai_roi;

USE nexora_ai_roi;

SHOW TABLES;

SELECT 'ai_usage' AS table_name, COUNT(*) AS total_rows
FROM ai_usage

UNION ALL

SELECT 'cost_categories', COUNT(*)
FROM cost_categories

UNION ALL

SELECT 'departments', COUNT(*)
FROM departments

UNION ALL

SELECT 'models', COUNT(*)
FROM models

UNION ALL

SELECT 'operating_costs', COUNT(*)
FROM operating_costs

UNION ALL

SELECT 'work_outcomes', COUNT(*)
FROM work_outcomes;

SELECT COUNT(*) AS total_use_cases
FROM use_cases;

USE nexora_ai_roi;

DESCRIBE ai_usage;

DESCRIBE work_outcomes;

DESCRIBE departments;

DESCRIBE models;

DESCRIBE use_cases;

DESCRIBE cost_categories;

USE nexora_ai_roi;

SELECT
    'departments' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT DepartmentKey) AS unique_keys
FROM departments

UNION ALL

SELECT
    'models',
    COUNT(*),
    COUNT(DISTINCT ModelKey)
FROM models

UNION ALL

SELECT
    'use_cases',
    COUNT(*),
    COUNT(DISTINCT UseCaseKey)
FROM use_cases

UNION ALL

SELECT
    'cost_categories',
    COUNT(*),
    COUNT(DISTINCT CostCategoryKey)
FROM cost_categories

UNION ALL

SELECT
    'ai_usage',
    COUNT(*),
    COUNT(DISTINCT RequestID)
FROM ai_usage

UNION ALL

SELECT
    'work_outcomes',
    COUNT(*),
    COUNT(DISTINCT WorkItemID)
FROM work_outcomes

UNION ALL

SELECT
    'operating_costs',
    COUNT(*),
    COUNT(DISTINCT CostRecordID)
FROM operating_costs;

-- Department references in AI usage
SELECT COUNT(*) AS invalid_department_refs
FROM ai_usage a
LEFT JOIN departments d
    ON a.DepartmentKey = d.DepartmentKey
WHERE d.DepartmentKey IS NULL;

-- Model references in AI usage
SELECT COUNT(*) AS invalid_model_refs
FROM ai_usage a
LEFT JOIN models m
    ON a.ModelKey = m.ModelKey
WHERE m.ModelKey IS NULL;

-- Use case references in AI usage
SELECT COUNT(*) AS invalid_usecase_refs
FROM ai_usage a
LEFT JOIN use_cases u
    ON a.UseCaseKey = u.UseCaseKey
WHERE u.UseCaseKey IS NULL;

-- Department references in work outcomes
SELECT COUNT(*) AS invalid_department_refs
FROM work_outcomes w
LEFT JOIN departments d
    ON w.DepartmentKey = d.DepartmentKey
WHERE d.DepartmentKey IS NULL;

-- Use case references in work outcomes
SELECT COUNT(*) AS invalid_usecase_refs
FROM work_outcomes w
LEFT JOIN use_cases u
    ON w.UseCaseKey = u.UseCaseKey
WHERE u.UseCaseKey IS NULL;

-- Cost category references
SELECT COUNT(*) AS invalid_costcategory_refs
FROM operating_costs o
LEFT JOIN cost_categories c
    ON o.CostCategoryKey = c.CostCategoryKey
WHERE c.CostCategoryKey IS NULL;


SELECT 'departments' AS table_name,
       SUM(DepartmentKey IS NULL) AS missing_keys
FROM departments

UNION ALL

SELECT 'models',
       SUM(ModelKey IS NULL)
FROM models

UNION ALL

SELECT 'use_cases',
       SUM(UseCaseKey IS NULL)
FROM use_cases

UNION ALL

SELECT 'cost_categories',
       SUM(CostCategoryKey IS NULL)
FROM cost_categories

UNION ALL

SELECT 'ai_usage',
       SUM(RequestID IS NULL)
FROM ai_usage

UNION ALL

SELECT 'work_outcomes',
       SUM(WorkItemID IS NULL)
FROM work_outcomes

UNION ALL

SELECT 'operating_costs',
       SUM(CostRecordID IS NULL)
FROM operating_costs;

ALTER TABLE departments
ADD PRIMARY KEY (DepartmentKey);

ALTER TABLE models
ADD PRIMARY KEY (ModelKey);

ALTER TABLE use_cases
ADD PRIMARY KEY (UseCaseKey);

ALTER TABLE cost_categories
ADD PRIMARY KEY (CostCategoryKey);

ALTER TABLE ai_usage
ADD PRIMARY KEY (RequestID);

ALTER TABLE work_outcomes
ADD PRIMARY KEY (WorkItemID);

ALTER TABLE operating_costs
ADD PRIMARY KEY (CostRecordID);

SELECT
    'ai_usage' AS table_name,
    MAX(CHAR_LENGTH(RequestID)) AS max_id_length
FROM ai_usage

UNION ALL

SELECT
    'work_outcomes',
    MAX(CHAR_LENGTH(WorkItemID))
FROM work_outcomes

UNION ALL

SELECT
    'operating_costs',
    MAX(CHAR_LENGTH(CostRecordID))
FROM operating_costs;

SHOW KEYS FROM departments WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM models WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM use_cases WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM cost_categories WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM ai_usage WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM work_outcomes WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM operating_costs WHERE Key_name = 'PRIMARY';

ALTER TABLE ai_usage
ADD PRIMARY KEY (RequestID);

ALTER TABLE work_outcomes
ADD PRIMARY KEY (WorkItemID);

ALTER TABLE operating_costs
ADD PRIMARY KEY (CostRecordID);

SHOW KEYS FROM ai_usage WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM work_outcomes WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM operating_costs WHERE Key_name = 'PRIMARY';

SELECT
    DepartmentKey,
    COUNT(*) AS cost_records
FROM operating_costs
GROUP BY DepartmentKey
ORDER BY DepartmentKey;

USE nexora_ai_roi;

-- AI usage relationships
ALTER TABLE ai_usage
ADD CONSTRAINT fk_ai_usage_department
FOREIGN KEY (DepartmentKey)
REFERENCES departments(DepartmentKey);

ALTER TABLE ai_usage
ADD CONSTRAINT fk_ai_usage_model
FOREIGN KEY (ModelKey)
REFERENCES models(ModelKey);

ALTER TABLE ai_usage
ADD CONSTRAINT fk_ai_usage_usecase
FOREIGN KEY (UseCaseKey)
REFERENCES use_cases(UseCaseKey);

-- Work outcomes relationships
ALTER TABLE work_outcomes
ADD CONSTRAINT fk_work_outcomes_department
FOREIGN KEY (DepartmentKey)
REFERENCES departments(DepartmentKey);

ALTER TABLE work_outcomes
ADD CONSTRAINT fk_work_outcomes_usecase
FOREIGN KEY (UseCaseKey)
REFERENCES use_cases(UseCaseKey);

-- Use cases relationship
ALTER TABLE use_cases
ADD CONSTRAINT fk_use_cases_department
FOREIGN KEY (DepartmentKey)
REFERENCES departments(DepartmentKey);

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'nexora_ai_roi'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

INSERT INTO departments
    (DepartmentKey, DepartmentName, HourlyLabourCostGBP)
VALUES
    (0, 'Company-wide / Shared Costs', NULL);
    
    ALTER TABLE operating_costs
ADD CONSTRAINT fk_operating_costs_department
FOREIGN KEY (DepartmentKey)
REFERENCES departments(DepartmentKey);

ALTER TABLE operating_costs
ADD CONSTRAINT fk_operating_costs_category
FOREIGN KEY (CostCategoryKey)
REFERENCES cost_categories(CostCategoryKey);

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'nexora_ai_roi'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

SELECT
    COUNT(*) AS total_ai_requests,
    COUNT(DISTINCT a.WorkItemID) AS unique_work_items,
    COUNT(DISTINCT w.WorkItemID) AS matched_work_items
FROM ai_usage a
LEFT JOIN work_outcomes w
    ON a.WorkItemID = w.WorkItemID;
    
SELECT
    COUNT(*) AS unmatched_ai_requests
FROM ai_usage a
LEFT JOIN work_outcomes w
    ON a.WorkItemID = w.WorkItemID
WHERE w.WorkItemID IS NULL;

ALTER TABLE ai_usage
ADD CONSTRAINT fk_ai_usage_workitem
FOREIGN KEY (WorkItemID)
REFERENCES work_outcomes(WorkItemID);

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'nexora_ai_roi'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;