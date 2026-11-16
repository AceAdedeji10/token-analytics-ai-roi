from pathlib import Path
import re
import pandas as pd
import numpy as np

# ============================================================
# NEXORA GROUP - TOKEN ANALYTICS & AI ROI
# Automated Data Validation
# ============================================================

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

# The cached input discount is a synthetic project assumption.
CACHED_INPUT_DISCOUNT = 0.50
TOLERANCE = 0.0001

errors = []
warnings = []
passed = 0


# ============================================================
# 1. GENERAL HELPER FUNCTIONS
# ============================================================

def normalise_column_name(name):
    """Standardise inconsistent column names."""

    name = str(name)

    # Remove quotation marks and common formatting characters.
    name = (
        name.replace('"', "")
        .replace("'", "")
        .replace("`", "")
        .replace("\ufeff", "")
        .strip()
    )

    # Remove all remaining spaces and punctuation.
    name = re.sub(r"[^A-Za-z0-9]", "", name)

    # Standardise common spelling/capitalisation variations.
    aliases = {
        "WorkItem": "WorkItemID",
        "WorkItemID": "WorkItemID",
        "Department": "DepartmentKey",
        "DepartmentKey": "DepartmentKey",
        "UseCase": "UseCaseKey",
        "UseCaseKey": "UseCaseKey",
        "Qualityscore": "QualityScore",
        "ActualworkMinutes": "ActualWorkMinutes",
        "CachedInputTokens": "CachedInputTokens",
        "TaskTokenCostGBP": "TaskTokenCostGBP",
        "TokenCostGBP": "TokenCostGBP",
        "TaskDatekey": "TaskDateKey",
        "RequestDatekey": "RequestDateKey",
        "LabourCapacityvalueGBP": "LabourCapacityValueGBP",
        "NetHinutesSaved": "NetMinutesSaved",
    }

    return aliases.get(name, name)


def load_csv(filename):
    """Load a CSV and normalise its column names."""

    path = RAW_DIR / filename

    if not path.exists():
        raise FileNotFoundError(
            f"Required file not found: {path}"
        )

    df = pd.read_csv(path)

    original_columns = list(df.columns)
    df.columns = [
        normalise_column_name(column)
        for column in df.columns
    ]

    # Do not silently continue if normalisation creates
    # duplicate column names.
    duplicated_columns = df.columns[df.columns.duplicated()].tolist()

    if duplicated_columns:
        raise ValueError(
            f"{filename} has duplicate columns after normalisation: "
            f"{duplicated_columns}. Original columns: "
            f"{original_columns}"
        )

    return df


def check(condition, message):
    """Record and display a validation result."""

    global passed

    if bool(condition):
        print(f"PASS: {message}")
        passed += 1
    else:
        print(f"FAIL: {message}")
        errors.append(message)


def check_close(actual, expected, message, tolerance=TOLERANCE):
    """Compare numerical results within a small tolerance."""

    actual = np.asarray(actual, dtype=float)
    expected = np.asarray(expected, dtype=float)

    result = (
        actual.shape == expected.shape
        and np.isfinite(actual).all()
        and np.isfinite(expected).all()
        and np.allclose(
            actual,
            expected,
            rtol=0,
            atol=tolerance
        )
    )

    check(result, message)


def require_columns(df, required, filename):
    """Stop with a useful error if required columns are missing."""

    missing = [
        column for column in required
        if column not in df.columns
    ]

    if missing:
        raise ValueError(
            f"{filename} is missing required columns: {missing}\n"
            f"Columns found: {df.columns.tolist()}"
        )


# ============================================================
# 2. LOAD DATA
# ============================================================

print("\n" + "=" * 70)
print("NEXORA GROUP - DATA VALIDATION")
print("=" * 70)

try:
    outcomes = load_csv("work_outcomes.csv")
    usage = load_csv("ai_usage.csv")
    models = load_csv("models.csv")
    departments = load_csv("departments.csv")
    use_cases = load_csv("use_cases.csv")
    operating_costs = load_csv("operating_costs.csv")
    cost_categories = load_csv("cost_categories.csv")

except (FileNotFoundError, ValueError, pd.errors.ParserError) as exc:
    print(f"\nDATA LOADING ERROR: {exc}")
    raise SystemExit(1)


# ============================================================
# 3. STANDARDISE IDENTIFIER COLUMNS
# ============================================================

# Work outcomes and AI usage must share the same work-item key.
# normalise_column_name() maps both WorkItem and WorkItemID
# to WorkItemID.

print("\nLoaded dataset sizes:")
print(f"Work outcomes: {len(outcomes):,}")
print(f"AI usage: {len(usage):,}")
print(f"Models: {len(models):,}")
print(f"Departments: {len(departments):,}")
print(f"Use cases: {len(use_cases):,}")
print(f"Operating costs: {len(operating_costs):,}")
print(f"Cost categories: {len(cost_categories):,}")


# ============================================================
# 4. REQUIRED COLUMN CHECKS
# ============================================================

require_columns(outcomes, [
    "WorkItemID",
    "DepartmentKey",
    "UseCaseKey",
    "AIAssisted",
    "BaselineMinutes",
    "ActualWorkMinutes",
    "ReviewMinutes",
    "ReworkMinutes",
    "TotalActualMinutes",
    "NetMinutesSaved",
    "TaskSuccessful",
    "OutputAccepted",
    "QualityScore",
    "TaskTokenCostGBP",
    "AIRequestCount",
    "HourlyLabourCostGBP",
    "LabourCapacityValueGBP",
    "OutcomeValueGBP",
], "work_outcomes.csv")

require_columns(usage, [
    "RequestID",
    "WorkItemID",
    "DepartmentKey",
    "ModelKey",
    "UseCaseKey",
    "InputTokens",
    "OutputTokens",
    "CachedInputTokens",
    "TokenCostGBP",
], "ai_usage.csv")

require_columns(models, [
    "ModelKey",
    "InputRateGBPPerMillion",
    "OutputRateGBPPerMillion",
], "models.csv")

require_columns(departments, [
    "DepartmentKey",
], "departments.csv")

require_columns(use_cases, [
    "UseCaseKey",
    "DepartmentKey",
], "use_cases.csv")

require_columns(operating_costs, [
    "CostAmountGBP",
], "operating_costs.csv")

require_columns(cost_categories, [
    "CostCategoryKey",
], "cost_categories.csv")


# ============================================================
# 5. UNIQUE IDENTIFIERS
# ============================================================

print("\n--- Unique identifier checks ---")

check(
    outcomes["WorkItemID"].notna().all()
    and outcomes["WorkItemID"].is_unique,
    "Work-item identifiers are present and unique"
)

check(
    usage["RequestID"].notna().all()
    and usage["RequestID"].is_unique,
    "AI request identifiers are present and unique"
)

check(
    models["ModelKey"].notna().all()
    and models["ModelKey"].is_unique,
    "Model keys are present and unique"
)

check(
    departments["DepartmentKey"].notna().all()
    and departments["DepartmentKey"].is_unique,
    "Department keys are present and unique"
)

check(
    use_cases["UseCaseKey"].notna().all()
    and use_cases["UseCaseKey"].is_unique,
    "Use-case keys are present and unique"
)


# ============================================================
# 6. REFERENTIAL INTEGRITY
# ============================================================

print("\n--- Referential integrity checks ---")

valid_work_items = set(outcomes["WorkItemID"].dropna())
valid_models = set(models["ModelKey"].dropna())
valid_departments = set(departments["DepartmentKey"].dropna())
valid_use_cases = set(use_cases["UseCaseKey"].dropna())

check(
    usage["WorkItemID"].isin(valid_work_items).all(),
    "Every AI request references an existing work item"
)

check(
    usage["ModelKey"].isin(valid_models).all(),
    "Every AI request references an existing model"
)

check(
    outcomes["DepartmentKey"].isin(valid_departments).all(),
    "Every work outcome references an existing department"
)

check(
    usage["DepartmentKey"].isin(valid_departments).all(),
    "Every AI request references an existing department"
)

check(
    outcomes["UseCaseKey"].isin(valid_use_cases).all(),
    "Every work outcome references an existing use case"
)

check(
    usage["UseCaseKey"].isin(valid_use_cases).all(),
    "Every AI request references an existing use case"
)

# Validate department ownership of each use case.
use_case_department = (
    use_cases.set_index("UseCaseKey")["DepartmentKey"].to_dict()
)

outcome_expected_department = outcomes["UseCaseKey"].map(
    use_case_department
)

usage_expected_department = usage["UseCaseKey"].map(
    use_case_department
)

check(
    (
        outcome_expected_department.notna()
        & (
            outcome_expected_department.to_numpy()
            == outcomes["DepartmentKey"].to_numpy()
        )
    ).all(),
    "Work-outcome department agrees with its use case"
)

check(
    (
        usage_expected_department.notna()
        & (
            usage_expected_department.to_numpy()
            == usage["DepartmentKey"].to_numpy()
        )
    ).all(),
    "AI-usage department agrees with its use case"
)


# ============================================================
# 7. TOKEN COUNTS AND TOKEN PRICING
# ============================================================

print("\n--- Token validation checks ---")

check(
    (
        (usage["InputTokens"] >= 0)
        & (usage["OutputTokens"] >= 0)
        & (usage["CachedInputTokens"] >= 0)
        & (usage["CachedInputTokens"] <= usage["InputTokens"])
    ).all(),
    "Token counts are non-negative and cached tokens do not exceed input tokens"
)

usage_priced = usage.merge(
    models[[
        "ModelKey",
        "InputRateGBPPerMillion",
        "OutputRateGBPPerMillion",
    ]],
    on="ModelKey",
    how="left",
    validate="many_to_one",
    indicator=True
)

check(
    (usage_priced["_merge"] == "both").all(),
    "Every AI request has model pricing available"
)

# Cached input tokens receive a 50% discount in this synthetic project.
expected_token_cost = (
    (
        (
            usage_priced["InputTokens"]
            - usage_priced["CachedInputTokens"]
        )
        * usage_priced["InputRateGBPPerMillion"]
        +
        usage_priced["CachedInputTokens"]
        * usage_priced["InputRateGBPPerMillion"]
        * (1 - CACHED_INPUT_DISCOUNT)
        +
        usage_priced["OutputTokens"]
        * usage_priced["OutputRateGBPPerMillion"]
    ) / 1_000_000
)

check_close(
    usage_priced["TokenCostGBP"].to_numpy(),
    expected_token_cost.to_numpy(),
    "Recorded AI token costs match the pricing calculation"
)

check(
    (usage["TokenCostGBP"] >= 0).all(),
    "AI request costs are non-negative"
)

check(
    (
        (models["InputRateGBPPerMillion"] >= 0)
        & (models["OutputRateGBPPerMillion"] >= 0)
    ).all(),
    "Model pricing rates are non-negative"
)


# ============================================================
# 8. WORK-ITEM AND REQUEST RECONCILIATION
# ============================================================

print("\n--- Work-item reconciliation checks ---")

# A left join retains tasks that did not use AI.
request_counts = usage.groupby("WorkItemID").size()

calculated_request_counts = (
    outcomes["WorkItemID"]
    .map(request_counts)
    .fillna(0)
    .astype(int)
)

check(
    (
        calculated_request_counts.to_numpy()
        == outcomes["AIRequestCount"].to_numpy()
    ).all(),
    "AI request counts reconcile with work outcomes"
)

request_costs = usage.groupby("WorkItemID")["TokenCostGBP"].sum()

calculated_task_costs = (
    outcomes["WorkItemID"]
    .map(request_costs)
    .fillna(0.0)
)

check_close(
    calculated_task_costs.to_numpy(),
    outcomes["TaskTokenCostGBP"].to_numpy(),
    "Task token costs reconcile with AI request costs"
)

expected_ai_assisted = calculated_request_counts > 0

check(
    (
        expected_ai_assisted.to_numpy()
        == outcomes["AIAssisted"].astype(bool).to_numpy()
    ).all(),
    "AI-assisted flags agree with AI request records"
)

# A task's department and use case must agree with every linked request.
task_details = outcomes[[
    "WorkItemID",
    "DepartmentKey",
    "UseCaseKey",
]].rename(columns={
    "DepartmentKey": "OutcomeDepartmentKey",
    "UseCaseKey": "OutcomeUseCaseKey",
})

linked_usage = usage.merge(
    task_details,
    on="WorkItemID",
    how="left",
    validate="many_to_one"
)

check(
    (
        linked_usage["DepartmentKey"].to_numpy()
        == linked_usage["OutcomeDepartmentKey"].to_numpy()
    ).all(),
    "AI requests and their work items have matching departments"
)

check(
    (
        linked_usage["UseCaseKey"].to_numpy()
        == linked_usage["OutcomeUseCaseKey"].to_numpy()
    ).all(),
    "AI requests and their work items have matching use cases"
)


# ============================================================
# 9. BUSINESS CALCULATION CHECKS
# ============================================================

print("\n--- Business calculation checks ---")

expected_total_minutes = (
    outcomes["ActualWorkMinutes"]
    + outcomes["ReviewMinutes"]
    + outcomes["ReworkMinutes"]
)

check_close(
    outcomes["TotalActualMinutes"].to_numpy(),
    expected_total_minutes.to_numpy(),
    "Total actual minutes include work, review and rework"
)

expected_net_minutes_saved = np.where(
    outcomes["AIAssisted"].astype(bool),
    outcomes["BaselineMinutes"] - expected_total_minutes,
    0.0
)

check_close(
    outcomes["NetMinutesSaved"].to_numpy(),
    expected_net_minutes_saved,
    "Net minutes saved follow the project calculation"
)

expected_capacity_value = (
    expected_net_minutes_saved
    / 60
    * outcomes["HourlyLabourCostGBP"]
)

check_close(
    outcomes["LabourCapacityValueGBP"].to_numpy(),
    expected_capacity_value.to_numpy(),
    "Labour capacity value matches net minutes saved and hourly labour cost"
)

check_close(
    outcomes["OutcomeValueGBP"].to_numpy(),
    outcomes["LabourCapacityValueGBP"].to_numpy(),
    "Outcome value reconciles with labour capacity value"
)


# ============================================================
# 10. VALID VALUE RANGES
# ============================================================

print("\n--- Value range checks ---")

check(
    (outcomes["BaselineMinutes"] > 0).all(),
    "Baseline task durations are positive"
)

check(
    (
        (outcomes["ActualWorkMinutes"] >= 0)
        & (outcomes["ReviewMinutes"] >= 0)
        & (outcomes["ReworkMinutes"] >= 0)
        & (outcomes["TotalActualMinutes"] >= 0)
    ).all(),
    "Actual, review, rework and total durations are non-negative"
)

check(
    outcomes["QualityScore"].between(0, 1).all(),
    "Quality scores are between 0 and 1"
)

check(
    (outcomes["HourlyLabourCostGBP"] >= 0).all(),
    "Hourly labour costs are non-negative"
)

check(
    outcomes["TaskSuccessful"].isin([True, False]).all(),
    "Task-success flags contain valid Boolean values"
)

check(
    outcomes["OutputAccepted"].isin([True, False]).all(),
    "Output-acceptance flags contain valid Boolean values"
)

check(
    (usage["LatencySeconds"] >= 0).all(),
    "AI request latency values are non-negative"
)


# ============================================================
# 11. OPERATING COST CHECKS
# ============================================================

print("\n--- Operating cost checks ---")

check(
    (operating_costs["CostAmountGBP"] >= 0).all(),
    "Operating costs are non-negative"
)

if "DepartmentKey" in operating_costs.columns:
    # Department key 0 represents shared/company-level costs.
    # Other keys should exist in the department dimension.
    valid_cost_departments = valid_departments | {0}

    check(
        operating_costs["DepartmentKey"]
        .isin(valid_cost_departments).all(),
        "Operating costs reference valid departments or shared key 0"
    )

if "CostCategoryKey" in operating_costs.columns:
    valid_cost_categories = set(
        cost_categories["CostCategoryKey"].dropna()
    )

    check(
        operating_costs["CostCategoryKey"]
        .isin(valid_cost_categories).all(),
        "Operating costs reference valid cost categories"
    )


# ============================================================
# 12. SUMMARY AND DIAGNOSTICS
# ============================================================

print("\n" + "=" * 70)
print("VALIDATION SUMMARY")
print("=" * 70)

print(f"Work outcomes: {len(outcomes):,}")
print(f"AI requests: {len(usage):,}")
print(f"Models: {len(models):,}")
print(f"Departments: {len(departments):,}")
print(f"Use cases: {len(use_cases):,}")

print(
    f"Total token expenditure: "
    f"£{usage['TokenCostGBP'].sum():,.4f}"
)

print(
    f"Total operating costs: "
    f"£{operating_costs['CostAmountGBP'].sum():,.2f}"
)

print(
    f"Total labour capacity value: "
    f"£{outcomes['LabourCapacityValueGBP'].sum():,.2f}"
)

print(f"\nChecks passed: {passed}")
print(f"Checks failed: {len(errors)}")

if errors:
    print("\nFAILED CHECKS:")
    for error in errors:
        print(f"- {error}")

    print(
        "\nValidation did not pass. Investigate the failed checks "
        "before using the data in the dashboard."
    )
else:
    print("\nALL VALIDATION CHECKS PASSED.")

print("=" * 70)
