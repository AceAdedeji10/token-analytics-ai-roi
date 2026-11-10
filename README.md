**Token Analytics & AI ROI Analysis**

Project Overview

This project explores how organisations can evaluate the financial and operational value of AI adoption.

Using a fictional organisation, Nexora Group, I developed an end-to-end analytics solution to examine AI usage, token expenditure, operating costs, workforce productivity and estimated business value.

The objective is to move beyond measuring AI activity and investigate whether the estimated productivity benefits justify the investment.

**Reporting period:** January – June 2027  
**Organisation:** Fictional – Nexora Group  
**Dataset:** Synthetically generated for portfolio demonstration.


Project Objectives

The analysis was designed to answer five key business questions:

1. **AI Investment:** How much is the organisation spending on AI usage and supporting operating costs?
2. **Return on Investment:** Does the estimated labour capacity value generated justify the total AI investment?
3. **Departmental Performance:** Which departments generate the greatest estimated value relative to their AI expenditure?
4. **Workforce Productivity:** How does AI-assisted work compare with non-AI-assisted work in terms of time saved, task success and output acceptance?
5. **Usage Patterns:** Which departments, AI models and business use cases account for the highest levels of AI consumption and associated costs?

The project also aims to make cost allocation assumptions and benefit attribution limitations transparent, supporting more informed business decisions.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Python | Synthetic dataset generation and data validation |
| MySQL | Data storage, relational modelling, SQL queries and analytical views |
| Power BI | Data modelling, DAX calculations and interactive dashboards |
| Power Query | Data transformation and preparation |
| DAX | KPI calculations, ROI analysis and departmental performance measures |
| Excel | Data inspection and validation |

### Data Architecture

The solution follows an analytical workflow:

1. Generate synthetic business and AI usage data using Python.
2. Validate data quality and relationships.
3. Load the datasets into MySQL.
4. Create SQL views for analytical reporting.
5. Connect MySQL to Power BI.
6. Build the data model, DAX measures and interactive report pages.

## Dataset Description

The project uses a synthetic dataset covering six months of simulated business activity across five operating departments.

### Dataset Summary

| Metric | Volume |
|---|---:|
| Work items | 10,000 |
| AI requests | 13,647 |
| Operating departments | 5 |
| AI models | 3 |
| Business use cases | 15 |
| Reporting period | 6 months |

### Main Data Tables

- **work_outcomes:** Task performance, AI assistance, time savings, success, acceptance and estimated labour capacity value.
- **ai_usage:** AI requests, token consumption, model usage, latency and token costs.
- **operating_costs:** Direct departmental and shared AI operating expenses.
- **departments:** Department reference data.
- **models:** AI model reference data.
- **use_cases:** Business use-case reference data.
- **cost_categories:** Operating cost classifications.
- **dim_date:** Calendar dimension for time-based analysis.

Three SQL views were created to support reporting: `vw_ai_usage`, `vw_work_outcomes` and `vw_operating_costs`.

## Key Findings

The analysis produced several important findings:

### Overall AI Investment
- Total AI investment: **£17,306.09**
- Estimated labour capacity value: **£6,473.75**
- Net estimated value: **-£10,832.34**
- Estimated AI ROI: **-62.59%**
- Value generated per £1 invested: **£0.37**

### Workforce Productivity
- 8,281 work items were AI-assisted, representing **82.81%** of all recorded work.
- Estimated time saved: **280.07 hours**.
- Overall task success rate: **94.97%**.
- Overall output acceptance rate: **71.00%**.

### Departmental Performance
- Marketing recorded the strongest departmental ROI at **-28.21%**.
- Sales recorded the weakest departmental ROI at **-92.76%**.
- Customer Support generated the highest AI request volume, with **4,079 requests**.

### AI Usage and Costs
- Total AI requests: **13,647**.
- Total token consumption: **38.34 million**.
- Total token expenditure: **£33.84**.
- Shared operating costs accounted for **£9,000** of total operating expenditure.

**Business interpretation:** The results suggest that estimated productivity benefits did not yet justify the overall AI investment in this simulated scenario. The findings highlight the importance of monitoring usage, operating costs, output quality and measurable business value when evaluating AI adoption.

## Methodology & Assumptions

### AI Return on Investment

The project uses the following calculations:

- **Total AI Investment** = Token Costs + Operating Costs
- **Net Estimated Value** = Estimated Labour Capacity Value − Total AI Investment
- **AI ROI** = (Net Estimated Value ÷ Total AI Investment) × 100
- **Value per £1 Spent** = Estimated Labour Capacity Value ÷ Total AI Investment

### Labour Capacity Value

Estimated labour capacity value is calculated using the net time saved on AI-assisted work and the associated hourly labour cost.

This represents the estimated financial value of released workforce capacity, not confirmed cash savings or additional revenue.

### Shared Cost Allocation

Shared operating costs are allocated to the five operating departments based on their respective shares of total AI requests.

This is an analytical assumption, not a direct measurement of each department's infrastructure consumption.

### Attribution Confidence

Work outcomes are classified by attribution confidence to reflect the strength of the relationship between AI assistance and the recorded outcome.

The analysis distinguishes medium-confidence outcomes from low-confidence outcomes. No high-confidence outcomes were recorded.

### Analytical Limitations

- All business records and financial figures are synthetic.
- The analysis does not establish that AI alone caused changes in productivity or output quality.
- Labour capacity value should not be interpreted as realised financial savings.
- Departmental shared-cost allocations depend on the chosen request-share assumption.
- Results are illustrative and should not be treated as audited financial performance.

## Power BI Report

The interactive Power BI report contains five analytical pages:

1. **Executive Overview:** Overall AI investment, estimated ROI and monthly trends.
2. **Departmental Analysis:** AI usage, operating costs and estimated value by department.
3. **AI Usage & Cost Analysis:** Token consumption, model performance and usage patterns.
4. **Workforce & Productivity:** AI-assisted work, time saved, task success and output quality.
5. **Methodology & Insights:** Business findings, calculation methods, allocation assumptions and limitations.

### Project Deliverables

- Power BI report (`.pbix`)
- PDF report export
- Five report-page screenshots
- Python data-generation and validation scripts
- MySQL database structure and analytical views

### Disclaimer

This is an independent portfolio project using fictional business scenarios and synthetically generated data. It is intended to demonstrate data analytics, business intelligence, financial analysis and reporting skills. It does not represent the actual financial or operational performance of any organisation.

## Report Screenshots

### 1. Executive Overview
![Executive Overview](reports/01_Executive_Overview.png)

### 2. Departmental Analysis
![Departmental Analysis](reports/02_Departmental_Analysis.png)

### 3. AI Usage & Cost Analysis
![AI Usage & Cost Analysis](reports/03_AI_Usage_Cost_Analysis.png)

### 4. Workforce & Productivity
![Workforce & Productivity](reports/04_Workforce_Productivity.png)

### 5. Methodology & Insights
![Methodology & Insights](reports/05_Methodology_Insights.png)
