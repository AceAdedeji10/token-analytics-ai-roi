SELECT
    COUNT(*) AS TotalAIRequests,
    COUNT(DISTINCT WorkItemID) AS AIassistedWorkItems,
    SUM(InputTokens) AS TotalInputTokens,
    SUM(OutputTokens) AS TotalOutputTokens,
    SUM(CachedInputTokens) AS TotalCachedInputTokens,
    ROUND(SUM(TokenCostGBP), 2) AS TotalTokenCostGBP,
    ROUND(AVG(TokenCostGBP), 6) AS AverageCostPerRequestGBP,
    ROUND(AVG(LatencySeconds), 2) AS AverageLatencySeconds
FROM ai_usage;

SELECT
    d.DepartmentName,
    COUNT(a.RequestID) AS TotalRequests,
    SUM(a.InputTokens) AS InputTokens,
    SUM(a.OutputTokens) AS OutputTokens,
    ROUND(SUM(a.TokenCostGBP), 2) AS TotalTokenCostGBP,
    ROUND(AVG(a.LatencySeconds), 2) AS AverageLatencySeconds
FROM ai_usage a
JOIN departments d
    ON a.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentKey,
    d.DepartmentName
ORDER BY TotalTokenCostGBP DESC;

SELECT
    c.CostCategoryName,
    COUNT(o.CostRecordID) AS NumberOfCostRecords,
    ROUND(SUM(o.CostAmountGBP), 2) AS TotalOperatingCostGBP,
    ROUND(AVG(o.CostAmountGBP), 2) AS AverageCostGBP
FROM operating_costs o
JOIN cost_categories c
    ON o.CostCategoryKey = c.CostCategoryKey
GROUP BY
    c.CostCategoryKey,
    c.CostCategoryName
ORDER BY TotalOperatingCostGBP DESC;

SELECT
    d.DepartmentName,
    COUNT(*) AS TotalWorkItems,
    SUM(CASE WHEN w.AIAssisted = 'Yes' THEN 1 ELSE 0 END) AS AIAssistedTasks,
    SUM(CASE WHEN w.TaskSuccessful = 'Yes' THEN 1 ELSE 0 END) AS SuccessfulTasks,
    SUM(CASE WHEN w.OutputAccepted = 'Yes' THEN 1 ELSE 0 END) AS AcceptedOutputs,
    ROUND(SUM(w.NetMinutesSaved), 2) AS TotalMinutesSaved,
    ROUND(SUM(w.LabourCapacityValueGBP), 2) AS LabourCapacityValueGBP
FROM work_outcomes w
JOIN departments d
    ON w.DepartmentKey = d.DepartmentKey
GROUP BY
    d.DepartmentKey,
    d.DepartmentName
ORDER BY LabourCapacityValueGBP DESC;

SELECT
    'AIAssisted' AS FieldName,
    AIAssisted AS FieldValue,
    COUNT(*) AS RecordCount
FROM work_outcomes
GROUP BY AIAssisted

UNION ALL

SELECT
    'TaskSuccessful',
    TaskSuccessful,
    COUNT(*)
FROM work_outcomes
GROUP BY TaskSuccessful

UNION ALL

SELECT
    'OutputAccepted',
    OutputAccepted,
    COUNT(*)
FROM work_outcomes
GROUP BY OutputAccepted;

SELECT
    d.DepartmentName,
    COUNT(*) AS TotalWorkItems,

    SUM(CASE
        WHEN w.AIAssisted = 'True' THEN 1 ELSE 0
    END) AS AIAssistedTasks,

    SUM(CASE
        WHEN w.TaskSuccessful = 'True' THEN 1 ELSE 0
    END) AS SuccessfulTasks,

    SUM(CASE
        WHEN w.OutputAccepted = 'True' THEN 1 ELSE 0
    END) AS AcceptedOutputs,

    ROUND(SUM(w.NetMinutesSaved), 2) AS TotalMinutesSaved,

    ROUND(SUM(w.LabourCapacityValueGBP), 2) AS LabourCapacityValueGBP

FROM work_outcomes w

JOIN departments d
    ON w.DepartmentKey = d.DepartmentKey

GROUP BY
    d.DepartmentKey,
    d.DepartmentName

ORDER BY LabourCapacityValueGBP DESC;

SELECT
    OutputAccepted,
    COUNT(*) AS RecordCount
FROM work_outcomes
GROUP BY OutputAccepted;

SELECT
    AIAssisted,
    COUNT(*) AS TotalTasks,

    SUM(CASE
        WHEN TaskSuccessful = 'True' THEN 1 ELSE 0
    END) AS SuccessfulTasks,

    ROUND(
        100.0 * SUM(CASE
            WHEN TaskSuccessful = 'True' THEN 1 ELSE 0
        END) / COUNT(*), 2
    ) AS SuccessRatePct,

    SUM(CASE
        WHEN OutputAccepted = 'True' THEN 1 ELSE 0
    END) AS AcceptedOutputs,

    ROUND(
        100.0 * SUM(CASE
            WHEN OutputAccepted = 'True' THEN 1 ELSE 0
        END) / COUNT(*), 2
    ) AS AcceptanceRatePct,

    ROUND(AVG(QualityScore), 2) AS AverageQualityScore,
    ROUND(SUM(NetMinutesSaved), 2) AS TotalMinutesSaved

FROM work_outcomes

GROUP BY AIAssisted
ORDER BY AIAssisted DESC;

SELECT
    AttributionConfidence,
    COUNT(*) AS TotalTasks,
    ROUND(SUM(OutcomeValueGBP), 2) AS TotalOutcomeValueGBP,
    ROUND(AVG(OutcomeValueGBP), 2) AS AverageOutcomeValueGBP,
    ROUND(SUM(LabourCapacityValueGBP), 2) AS LabourCapacityValueGBP,
    SUM(CASE
        WHEN OutputAccepted = 'True' THEN 1
        ELSE 0
    END) AS AcceptedOutputs
FROM work_outcomes
WHERE AIAssisted = 'True'
GROUP BY AttributionConfidence
ORDER BY TotalOutcomeValueGBP DESC;

SELECT
    COUNT(*) AS TotalAIAssistedTasks,

    ROUND(SUM(LabourCapacityValueGBP), 2)
        AS TotalLabourCapacityValueGBP,

    ROUND(SUM(OutcomeValueGBP), 2)
        AS TotalOutcomeValueGBP,

    SUM(CASE
        WHEN ABS(LabourCapacityValueGBP - OutcomeValueGBP) < 0.01
        THEN 1 ELSE 0
    END) AS MatchingValueRecords,

    SUM(CASE
        WHEN ABS(LabourCapacityValueGBP - OutcomeValueGBP) >= 0.01
        THEN 1 ELSE 0
    END) AS DifferentValueRecords

FROM work_outcomes
WHERE AIAssisted = 'True';

SELECT
    ROUND(SUM(w.LabourCapacityValueGBP), 2)
        AS LabourCapacityValueGBP,

    ROUND(
        (SELECT SUM(TokenCostGBP)
         FROM ai_usage), 2
    ) AS TokenCostGBP,

    ROUND(
        (SELECT SUM(CostAmountGBP)
         FROM operating_costs), 2
    ) AS OperatingCostGBP,

    ROUND(
        (SELECT SUM(TokenCostGBP)
         FROM ai_usage)
        +
        (SELECT SUM(CostAmountGBP)
         FROM operating_costs), 2
    ) AS TotalAICostGBP,

    ROUND(
        (
            SUM(w.LabourCapacityValueGBP)
            -
            (
                (SELECT SUM(TokenCostGBP)
                 FROM ai_usage)
                +
                (SELECT SUM(CostAmountGBP)
                 FROM operating_costs)
            )
        )
        /
        (
            (SELECT SUM(TokenCostGBP)
             FROM ai_usage)
            +
            (SELECT SUM(CostAmountGBP)
             FROM operating_costs)
        ) * 100, 2
    ) AS PreliminaryROI_Percent

FROM work_outcomes w
WHERE w.AIAssisted = 'True';

SELECT
    DATE_FORMAT(STR_TO_DATE(CostDate, '%Y-%m-%d'), '%Y-%m')
        AS CostMonth,

    ROUND(SUM(CostAmountGBP), 2)
        AS OperatingCostGBP,

    COUNT(*) AS CostRecords

FROM operating_costs

GROUP BY CostMonth

ORDER BY CostMonth;

SELECT
    CostDate,
    COUNT(*) AS RecordCount,
    ROUND(SUM(CostAmountGBP), 2) AS TotalCostGBP
FROM operating_costs
GROUP BY CostDate
ORDER BY CostDate;

WITH monthly_ai_usage AS (
    SELECT
        LEFT(RequestDate, 7) AS ReportMonth,
        COUNT(*) AS TotalAIRequests,
        ROUND(SUM(TokenCostGBP), 2) AS TokenCostGBP
    FROM ai_usage
    GROUP BY LEFT(RequestDate, 7)
),

monthly_outcomes AS (
    SELECT
        LEFT(TaskDate, 7) AS ReportMonth,
        COUNT(*) AS TotalWorkItems,
        SUM(CASE
            WHEN AIAssisted = 'True' THEN 1 ELSE 0
        END) AS AIAssistedTasks,
        ROUND(SUM(LabourCapacityValueGBP), 2)
            AS LabourCapacityValueGBP
    FROM work_outcomes
    GROUP BY LEFT(TaskDate, 7)
),

monthly_operating_costs AS (
    SELECT
        LEFT(CostDate, 7) AS ReportMonth,
        ROUND(SUM(CostAmountGBP), 2) AS OperatingCostGBP
    FROM operating_costs
    GROUP BY LEFT(CostDate, 7)
),

reporting_months AS (
    SELECT ReportMonth FROM monthly_ai_usage
    UNION
    SELECT ReportMonth FROM monthly_outcomes
    UNION
    SELECT ReportMonth FROM monthly_operating_costs
)

SELECT
    m.ReportMonth,
    COALESCE(a.TotalAIRequests, 0) AS TotalAIRequests,
    COALESCE(a.TokenCostGBP, 0) AS TokenCostGBP,
    COALESCE(o.AIAssistedTasks, 0) AS AIAssistedTasks,
    COALESCE(o.LabourCapacityValueGBP, 0)
        AS LabourCapacityValueGBP,
    COALESCE(c.OperatingCostGBP, 0) AS OperatingCostGBP,

    ROUND(
        COALESCE(a.TokenCostGBP, 0)
        + COALESCE(c.OperatingCostGBP, 0), 2
    ) AS TotalAICostGBP

FROM reporting_months m

LEFT JOIN monthly_ai_usage a
    ON m.ReportMonth = a.ReportMonth

LEFT JOIN monthly_outcomes o
    ON m.ReportMonth = o.ReportMonth

LEFT JOIN monthly_operating_costs c
    ON m.ReportMonth = c.ReportMonth

ORDER BY m.ReportMonth;

WITH monthly_ai_usage AS (
    SELECT
        LEFT(RequestDate, 7) AS ReportMonth,
        SUM(TokenCostGBP) AS TokenCostGBP
    FROM ai_usage
    GROUP BY LEFT(RequestDate, 7)
),

monthly_outcomes AS (
    SELECT
        LEFT(TaskDate, 7) AS ReportMonth,
        SUM(CASE
            WHEN AIAssisted = 'True'
            THEN LabourCapacityValueGBP
            ELSE 0
        END) AS LabourCapacityValueGBP
    FROM work_outcomes
    GROUP BY LEFT(TaskDate, 7)
),

monthly_operating_costs AS (
    SELECT
        LEFT(CostDate, 7) AS ReportMonth,
        SUM(CostAmountGBP) AS OperatingCostGBP
    FROM operating_costs
    GROUP BY LEFT(CostDate, 7)
)

SELECT
    a.ReportMonth,

    ROUND(a.TokenCostGBP, 2) AS TokenCostGBP,

    ROUND(c.OperatingCostGBP, 2) AS OperatingCostGBP,

    ROUND(
        a.TokenCostGBP + c.OperatingCostGBP, 2
    ) AS TotalAICostGBP,

    ROUND(o.LabourCapacityValueGBP, 2)
        AS LabourCapacityValueGBP,


SELECT
    a.ReportMonth,
    ROUND(a.TokenCostGBP, 2) AS TokenCostGBP,
    ROUND(c.OperatingCostGBP, 2) AS OperatingCostGBP,

    ROUND(
        a.TokenCostGBP + c.OperatingCostGBP, 2
    ) AS TotalAICostGBP,

    ROUND(o.LabourCapacityValueGBP, 2)
        AS LabourCapacityValueGBP,

    ROUND(
        (
            o.LabourCapacityValueGBP -
            (a.TokenCostGBP + c.OperatingCostGBP)
        ) /
        NULLIF((a.TokenCostGBP + c.OperatingCostGBP), 0) * 100,
        2
    ) AS MonthlyROI_Percent

FROM
(
    SELECT
        LEFT(RequestDate, 7) AS ReportMonth,
        SUM(TokenCostGBP) AS TokenCostGBP
    FROM ai_usage
    GROUP BY LEFT(RequestDate, 7)
) a

JOIN
(
    SELECT
        LEFT(TaskDate, 7) AS ReportMonth,
        SUM(LabourCapacityValueGBP) AS LabourCapacityValueGBP
    FROM work_outcomes
    WHERE AIAssisted = 'True'
    GROUP BY LEFT(TaskDate, 7)
) o
    ON a.ReportMonth = o.ReportMonth

JOIN
(
    SELECT
        LEFT(CostDate, 7) AS ReportMonth,
        SUM(CostAmountGBP) AS OperatingCostGBP
    FROM operating_costs
    GROUP BY LEFT(CostDate, 7)
) c
    ON a.ReportMonth = c.ReportMonth

ORDER BY a.ReportMonth;

SELECT
    d.DepartmentName,

    COALESCE(a.TotalAIRequests, 0) AS TotalAIRequests,

    ROUND(COALESCE(a.TokenCostGBP, 0), 2)
        AS TokenCostGBP,

    ROUND(COALESCE(o.LabourCapacityValueGBP, 0), 2)
        AS LabourCapacityValueGBP,

    ROUND(COALESCE(c.OperatingCostGBP, 0), 2)
        AS OperatingCostGBP

FROM departments d

LEFT JOIN (
    SELECT
        DepartmentKey,
        COUNT(*) AS TotalAIRequests,
        SUM(TokenCostGBP) AS TokenCostGBP
    FROM ai_usage
    GROUP BY DepartmentKey
) a
    ON d.DepartmentKey = a.DepartmentKey

LEFT JOIN (
    SELECT
        DepartmentKey,
        SUM(LabourCapacityValueGBP) AS LabourCapacityValueGBP
    FROM work_outcomes
    WHERE AIAssisted = 'True'
    GROUP BY DepartmentKey
) o
    ON d.DepartmentKey = o.DepartmentKey

LEFT JOIN (
    SELECT
        DepartmentKey,
        SUM(CostAmountGBP) AS OperatingCostGBP
    FROM operating_costs
    GROUP BY DepartmentKey
) c
    ON d.DepartmentKey = c.DepartmentKey

ORDER BY d.DepartmentKey;

SELECT
    cc.CostCategoryName,
    o.AllocationMethod,
    COUNT(*) AS NumberOfRecords,
    ROUND(SUM(o.CostAmountGBP), 2) AS TotalCostGBP,
    ROUND(AVG(o.CostAmountGBP), 2) AS AverageCostGBP
FROM operating_costs o
JOIN cost_categories cc
    ON o.CostCategoryKey = cc.CostCategoryKey
WHERE o.DepartmentKey = 0
GROUP BY
    cc.CostCategoryName,
    o.AllocationMethod
ORDER BY TotalCostGBP DESC;

SELECT
    d.DepartmentName,

    a.TotalAIRequests,

    ROUND(
        100.0 * a.TotalAIRequests /
        (SELECT COUNT(*) FROM ai_usage), 2
    ) AS UsageSharePct,

    ROUND(a.TokenCostGBP, 2) AS TokenCostGBP,

    ROUND(c.DirectOperatingCostGBP, 2)
        AS DirectOperatingCostGBP,

    ROUND(
        9000.00 * a.TotalAIRequests /
        (SELECT COUNT(*) FROM ai_usage), 2
    ) AS AllocatedSharedCostGBP,

    ROUND(
        a.TokenCostGBP
        + c.DirectOperatingCostGBP
        + (9000.00 * a.TotalAIRequests /
           (SELECT COUNT(*) FROM ai_usage)), 2
    ) AS TotalAllocatedCostGBP,

    ROUND(o.LabourCapacityValueGBP, 2)
        AS LabourCapacityValueGBP,

    ROUND(
        (
            o.LabourCapacityValueGBP
            - a.TokenCostGBP
            - c.DirectOperatingCostGBP
            - (9000.00 * a.TotalAIRequests /
               (SELECT COUNT(*) FROM ai_usage))
        )
        /
        NULLIF(
            a.TokenCostGBP
            + c.DirectOperatingCostGBP
            + (9000.00 * a.TotalAIRequests /
               (SELECT COUNT(*) FROM ai_usage)),
            0
        ) * 100, 2
    ) AS DepartmentalROI_Percent

FROM departments d

JOIN (
    SELECT
        DepartmentKey,
        COUNT(*) AS TotalAIRequests,
        SUM(TokenCostGBP) AS TokenCostGBP
    FROM ai_usage
    GROUP BY DepartmentKey
) a
    ON d.DepartmentKey = a.DepartmentKey

JOIN (
    SELECT
        DepartmentKey,
        SUM(CostAmountGBP) AS DirectOperatingCostGBP
    FROM operating_costs
    WHERE DepartmentKey <> 0
    GROUP BY DepartmentKey
) c
    ON d.DepartmentKey = c.DepartmentKey

JOIN (
    SELECT
        DepartmentKey,
        SUM(LabourCapacityValueGBP) AS LabourCapacityValueGBP
    FROM work_outcomes
    WHERE AIAssisted = 'True'
    GROUP BY DepartmentKey
) o
    ON d.DepartmentKey = o.DepartmentKey

ORDER BY DepartmentalROI_Percent DESC;

SELECT
    d.DepartmentName,
    w.AttributionConfidence,
    COUNT(*) AS NumberOfTasks,
    SUM(CASE
        WHEN w.OutputAccepted = 'True' THEN 1
        ELSE 0
    END) AS AcceptedOutputs,
    ROUND(SUM(w.LabourCapacityValueGBP), 2)
        AS LabourCapacityValueGBP,
    ROUND(AVG(w.QualityScore), 2)
        AS AverageQualityScore
FROM work_outcomes w
JOIN departments d
    ON w.DepartmentKey = d.DepartmentKey
WHERE w.AIAssisted = 'True'
GROUP BY
    d.DepartmentName,
    w.AttributionConfidence
ORDER BY
    d.DepartmentName,
    w.AttributionConfidence;

SELECT
    AttributionConfidence,
    COUNT(*) AS TotalTasks,

    SUM(LabourCapacityValueGBP)
        AS LabourCapacityValueGBP,

    ROUND(
        AVG(QualityScore), 2
    ) AS AverageQuality,

    SUM(
        CASE
            WHEN OutputAccepted = 'True' THEN 1
            ELSE 0
        END
    ) AS AcceptedOutputs,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN OutputAccepted = 'True' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS AcceptanceRatePct

FROM work_outcomes

WHERE AIAssisted = 'True'

GROUP BY AttributionConfidence
ORDER BY AttributionConfidence;

SELECT
    ROUND(costs.TokenCostGBP, 2) AS TokenCostGBP,
    ROUND(costs.OperatingCostGBP, 2) AS OperatingCostGBP,
    ROUND(
        costs.TokenCostGBP + costs.OperatingCostGBP, 2
    ) AS TotalAIExpenditureGBP,

    ROUND(benefits.AllBenefitsGBP, 2)
        AS AllBenefitsGBP,

    ROUND(benefits.MediumConfidenceBenefitsGBP, 2)
        AS MediumConfidenceBenefitsGBP,

    ROUND(
        (
            benefits.AllBenefitsGBP
            - costs.TokenCostGBP
            - costs.OperatingCostGBP
        )
        / (costs.TokenCostGBP + costs.OperatingCostGBP)
        * 100, 2
    ) AS OverallROI_Percent,

    ROUND(
        (
            benefits.MediumConfidenceBenefitsGBP
            - costs.TokenCostGBP
            - costs.OperatingCostGBP
        )
        / (costs.TokenCostGBP + costs.OperatingCostGBP)
        * 100, 2
    ) AS MediumConfidenceROI_Percent

FROM
(
    SELECT
        (SELECT SUM(TokenCostGBP)
         FROM ai_usage) AS TokenCostGBP,

        (SELECT SUM(CostAmountGBP)
         FROM operating_costs) AS OperatingCostGBP
) costs

CROSS JOIN
(
    SELECT
        SUM(
            CASE
                WHEN AIAssisted = 'True'
                THEN LabourCapacityValueGBP
                ELSE 0
            END
        ) AS AllBenefitsGBP,

        SUM(
            CASE
                WHEN AIAssisted = 'True'
                 AND AttributionConfidence = 'Medium'
                THEN LabourCapacityValueGBP
                ELSE 0
            END
        ) AS MediumConfidenceBenefitsGBP

    FROM work_outcomes
) benefits;

SELECT
    COUNT(*) AS TotalAIWorkItems,

    ROUND(
        SUM(w.TaskTokenCostGBP), 2
    ) AS TotalTaskTokenCostGBP,

    ROUND(
        (
            SELECT SUM(TokenCostGBP)
            FROM ai_usage
        ), 2
    ) AS TotalRequestTokenCostGBP,

    ROUND(
        SUM(w.TaskTokenCostGBP)
        -
        (
            SELECT SUM(TokenCostGBP)
            FROM ai_usage
        ), 2
    ) AS CostDifferenceGBP,

    ROUND(
        AVG(w.TaskTokenCostGBP), 5
    ) AS AverageTaskTokenCostGBP,

    ROUND(
        AVG(a.RequestCostGBP), 5
    ) AS AverageRequestCostPerWorkItemGBP

FROM work_outcomes w

JOIN (
    SELECT
        WorkItemID,
        SUM(TokenCostGBP) AS RequestCostGBP
    FROM ai_usage
    GROUP BY WorkItemID
) a
    ON w.WorkItemID = a.WorkItemID

WHERE w.AIAssisted = 'True';

SELECT
    'AI Usage' AS Dataset,
    MIN(RequestDate) AS EarliestDate,
    MAX(RequestDate) AS LatestDate,
    COUNT(*) AS TotalRecords
FROM ai_usage

UNION ALL

SELECT
    'Work Outcomes',
    MIN(TaskDate),
    MAX(TaskDate),
    COUNT(*)
FROM work_outcomes

UNION ALL

SELECT
    'Operating Costs',
    MIN(CostDate),
    MAX(CostDate),
    COUNT(*)
FROM operating_costs;

SELECT
    LEFT(CostDate, 7) AS ReportMonth,
    COUNT(*) AS NumberOfRecords,
    ROUND(SUM(CostAmountGBP), 2) AS TotalOperatingCostGBP,
    MIN(CostDate) AS FirstCostDate,
    MAX(CostDate) AS LastCostDate
FROM operating_costs
GROUP BY LEFT(CostDate, 7)
ORDER BY ReportMonth;

SELECT
    'AI Usage' AS Dataset,
    COUNT(*) AS TotalRecords,
    SUM(
        CASE
            WHEN RequestDate IS NULL
              OR RequestDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
              OR STR_TO_DATE(RequestDate, '%Y-%m-%d') IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidDates
FROM ai_usage

UNION ALL

SELECT
    'Work Outcomes',
    COUNT(*),
    SUM(
        CASE
            WHEN TaskDate IS NULL
              OR TaskDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
              OR STR_TO_DATE(TaskDate, '%Y-%m-%d') IS NULL
            THEN 1 ELSE 0
        END
    )
FROM work_outcomes

UNION ALL

SELECT
    'Operating Costs',
    COUNT(*),
    SUM(
        CASE
            WHEN CostDate IS NULL
              OR CostDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
              OR STR_TO_DATE(CostDate, '%Y-%m-%d') IS NULL
            THEN 1 ELSE 0
        END
    )
FROM operating_costs;

ALTER TABLE ai_usage
MODIFY RequestDate DATE;

ALTER TABLE work_outcomes
MODIFY TaskDate DATE;

ALTER TABLE operating_costs
MODIFY CostDate DATE;

DESCRIBE ai_usage;
DESCRIBE work_outcomes;
DESCRIBE operating_costs;

SELECT
    'AIAssisted' AS ColumnName,
    AIAssisted AS StoredValue,
    COUNT(*) AS Records
FROM work_outcomes
GROUP BY AIAssisted

UNION ALL

SELECT
    'TaskSuccessful',
    TaskSuccessful,
    COUNT(*)
FROM work_outcomes
GROUP BY TaskSuccessful

UNION ALL

SELECT
    'OutputAccepted',
    OutputAccepted,
    COUNT(*)
FROM work_outcomes
GROUP BY OutputAccepted;

CREATE OR REPLACE VIEW vw_work_outcomes AS

SELECT
    w.WorkItemID,
    w.TaskDate,
    w.TaskDateKey,

    w.DepartmentKey,
    d.DepartmentName,

    w.UseCaseKey,
    u.UseCaseName,

    CASE
        WHEN w.AIAssisted = 'True' THEN 1
        ELSE 0
    END AS AIAssistedFlag,

    CASE
        WHEN w.TaskSuccessful = 'True' THEN 1
        ELSE 0
    END AS TaskSuccessfulFlag,

    CASE
        WHEN w.OutputAccepted = 'True' THEN 1
        ELSE 0
    END AS OutputAcceptedFlag,

    w.BaselineMinutes,
    w.ActualWorkMinutes,
    w.ReviewMinutes,
    w.ReworkMinutes,
    w.TotalActualMinutes,
    w.NetMinutesSaved,

    w.QualityScore,
    w.TaskTokenCostGBP,
    w.AIRequestCount,

    w.HourlyLabourCostGBP,
    w.LabourCapacityValueGBP,
    w.OutcomeValueGBP,

    w.AttributionConfidence,
    w.TaskStatus

FROM work_outcomes w

LEFT JOIN departments d
    ON w.DepartmentKey = d.DepartmentKey

LEFT JOIN use_cases u
    ON w.UseCaseKey = u.UseCaseKey;
    
SELECT *
FROM vw_work_outcomes
LIMIT 10;

CREATE OR REPLACE VIEW vw_ai_usage AS

SELECT
    a.RequestID,
    a.WorkItemID,
    a.RequestDate,

    a.DepartmentKey,
    d.DepartmentName,

    a.ModelKey,
    m.ProviderName,
    m.ModelName,

    a.UseCaseKey,
    u.UseCaseName,

    a.InputTokens,
    a.OutputTokens,
    a.CachedInputTokens,

    (a.InputTokens + a.OutputTokens) AS TotalTokens,

    a.TokenCostGBP,
    a.RequestStatus,
    a.LatencySeconds

FROM ai_usage a

LEFT JOIN departments d
    ON a.DepartmentKey = d.DepartmentKey

LEFT JOIN models m
    ON a.ModelKey = m.ModelKey

LEFT JOIN use_cases u
    ON a.UseCaseKey = u.UseCaseKey;
    
SELECT *
FROM vw_ai_usage
LIMIT 10;

CREATE OR REPLACE VIEW vw_operating_costs AS

SELECT
    o.CostRecordID,
    o.CostDate,
    o.CostDateKey,

    o.DepartmentKey,
    d.DepartmentName,

    o.CostCategoryKey,
    c.CostCategoryName,

    o.CostAmountGBP,
    o.AllocationMethod,

    CASE
        WHEN o.DepartmentKey = 0 THEN 'Shared'
        ELSE 'Direct'
    END AS CostType

FROM operating_costs o

LEFT JOIN departments d
    ON o.DepartmentKey = d.DepartmentKey

LEFT JOIN cost_categories c
    ON o.CostCategoryKey = c.CostCategoryKey;
    
SELECT *
FROM vw_operating_costs
ORDER BY CostDate, DepartmentKey
LIMIT 10;

CREATE TABLE IF NOT EXISTS dim_date AS

WITH RECURSIVE calendar AS (
    SELECT DATE('2027-01-01') AS CalendarDate

    UNION ALL

    SELECT DATE_ADD(CalendarDate, INTERVAL 1 DAY)
    FROM calendar
    WHERE CalendarDate < '2027-06-30'
)

SELECT
    CAST(DATE_FORMAT(CalendarDate, '%Y%m%d') AS UNSIGNED)
        AS DateKey,

    CalendarDate,

    YEAR(CalendarDate) AS Year,

    MONTH(CalendarDate) AS MonthNumber,

    MONTHNAME(CalendarDate) AS MonthName,

    CONCAT(
        YEAR(CalendarDate),
        '-',
        LPAD(MONTH(CalendarDate), 2, '0')
    ) AS YearMonth,

    QUARTER(CalendarDate) AS QuarterNumber,

    CONCAT('Q', QUARTER(CalendarDate)) AS QuarterName,

    DAY(CalendarDate) AS DayOfMonth,

    DAYNAME(CalendarDate) AS DayName,

    WEEKDAY(CalendarDate) + 1 AS DayOfWeekNumber,

    CASE
        WHEN WEEKDAY(CalendarDate) IN (5, 6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayType

FROM calendar;

SELECT
    COUNT(*) AS TotalDates,
    MIN(CalendarDate) AS FirstDate,
    MAX(CalendarDate) AS LastDate
FROM dim_date;

SELECT
    'AI Usage' AS Dataset,
    COUNT(*) AS TotalRecords,
    SUM(
        CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END
    ) AS UnmatchedDates
FROM vw_ai_usage a
LEFT JOIN dim_date d
    ON a.RequestDate = d.CalendarDate

UNION ALL

SELECT
    'Work Outcomes',
    COUNT(*),
    SUM(
        CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END
    )
FROM vw_work_outcomes w
LEFT JOIN dim_date d
    ON w.TaskDate = d.CalendarDate

UNION ALL

SELECT
    'Operating Costs',
    COUNT(*),
    SUM(
        CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END
    )
FROM vw_operating_costs o
LEFT JOIN dim_date d
    ON o.CostDate = d.CalendarDate;
    
ALTER TABLE dim_date
ADD PRIMARY KEY (DateKey),
ADD UNIQUE KEY uq_dim_date_calendar_date (CalendarDate);

SHOW INDEX FROM dim_date;

SELECT
    'vw_ai_usage' AS ViewName,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT RequestID) AS UniqueRecords
FROM vw_ai_usage

UNION ALL

SELECT
    'vw_work_outcomes',
    COUNT(*),
    COUNT(DISTINCT WorkItemID)
FROM vw_work_outcomes

UNION ALL

SELECT
    'vw_operating_costs',
    COUNT(*),
    COUNT(DISTINCT CostRecordID)
FROM vw_operating_costs;

CREATE OR REPLACE VIEW vw_ai_usage AS
SELECT
    RequestID,
    WorkItemID,
    RequestDate,
    DepartmentKey,
    ModelKey,
    UseCaseKey,
    InputTokens,
    OutputTokens,
    CachedInputTokens,
    (InputTokens + OutputTokens) AS TotalTokens,
    TokenCostGBP,
    RequestStatus,
    LatencySeconds
FROM ai_usage;


CREATE OR REPLACE VIEW vw_work_outcomes AS
SELECT
    WorkItemID,
    TaskDate,
    TaskDateKey,
    DepartmentKey,
    UseCaseKey,
    CASE WHEN AIAssisted = 'True' THEN 1 ELSE 0 END AS AIAssistedFlag,
    CASE WHEN TaskSuccessful = 'True' THEN 1 ELSE 0 END AS TaskSuccessfulFlag,
    CASE WHEN OutputAccepted = 'True' THEN 1 ELSE 0 END AS OutputAcceptedFlag,
    BaselineMinutes,
    ActualWorkMinutes,
    ReviewMinutes,
    ReworkMinutes,
    TotalActualMinutes,
    NetMinutesSaved,
    QualityScore,
    TaskTokenCostGBP,
    AIRequestCount,
    HourlyLabourCostGBP,
    LabourCapacityValueGBP,
    OutcomeValueGBP,
    AttributionConfidence,
    TaskStatus
FROM work_outcomes;


CREATE OR REPLACE VIEW vw_operating_costs AS
SELECT
    CostRecordID,
    CostDate,
    CostDateKey,
    DepartmentKey,
    CostCategoryKey,
    CostAmountGBP,
    AllocationMethod,
    CASE WHEN DepartmentKey = 0 THEN 'Shared' ELSE 'Direct' END AS CostType
FROM operating_costs;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'nexora_ai_roi'
AND TABLE_NAME IN (
    'vw_ai_usage',
    'vw_work_outcomes',
    'vw_operating_costs'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT
    'dim_date' AS TableName,
    COUNT(*) AS TotalRecords
FROM dim_date

UNION ALL

SELECT 'departments', COUNT(*)
FROM departments

UNION ALL

SELECT 'models', COUNT(*)
FROM models

UNION ALL

SELECT 'use_cases', COUNT(*)
FROM use_cases

UNION ALL

SELECT 'cost_categories', COUNT(*)
FROM cost_categories;