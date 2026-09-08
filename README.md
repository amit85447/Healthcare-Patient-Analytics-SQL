# 🏥 Healthcare Patient Analytics & Clinical Operations (MySQL)

[![SQL](https://img.shields.io/badge/Language-MySQL-orange?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Domain](https://img.shields.io/badge/Domain-Healthcare_Analytics-blue?style=for-the-badge)](#)
[![Database](https://img.shields.io/badge/Database-MySQL_Workbench-informational?style=for-the-badge&logo=mysql)](#)

An end-to-end healthcare data analytics project focused on inpatient admission tracking, clinical department efficiency, Average Length of Stay (ALOS), and hospital revenue metrics.

---

## 📌 Project Overview
Hospital administrators require granular operational metrics to optimize bed turnover, lower unnecessary stay durations, identify high-cost clinical drivers, and balance emergency vs. routine admission workflows.

This project evaluates patient admission records via MySQL Workbench to extract actionable operational and clinical insights.

---

## 🏗️ Data Schema & Architecture
Target Table: `abc.healthcare_patient_analytics_seaborn`

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `patient_id` | INT | Unique identifier for each hospital admission |
| `visit_date` | DATETIME | Timestamp of patient admission |
| `age_group` | VARCHAR(20) | Demographic age category (18-30, 31-45, 46-60, 60+) |
| `gender` | VARCHAR(10) | Patient gender (Male, Female) |
| `region` | VARCHAR(20) | Patient geographic zone (North, South, East, West) |
| `department` | VARCHAR(50) | Medical specialty (General Medicine, Orthopedics, Neurology, Pediatrics, etc.) |
| `treatment_type` | VARCHAR(50) | Clinical protocol (Medication, Surgery, Therapy, Observation) |
| `visit_type` | VARCHAR(20) | Admission urgency (Emergency vs. Routine) |
| `length_of_stay_days` | DECIMAL(4,1) | Total inpatient duration in days |
| `treatment_cost` | DECIMAL(10,2) | Total billed medical cost |

---

## 🔍 Business Problems & SQL Implementations

### 1. Department Revenue & Operational Load
- **Business Goal:** Identify departments generating the highest billing and evaluate their average patient volume and stay duration.
- **SQL Skills:** `GROUP BY`, `SUM()`, `AVG()`, `COUNT()`, `ROUND()`.[cite: 1]

```sql
SELECT 
    department,
    COUNT(patient_id) AS total_patients,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_days,
    ROUND(SUM(treatment_cost), 2) AS total_revenue,
    ROUND(AVG(treatment_cost), 2) AS avg_cost_per_patient
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY department
ORDER BY total_revenue DESC;
```
### 2. Emergency vs. Routine Admission Impact
- **Objective:** Compare financial billing and average stay duration between unscheduled emergency admissions and routine consultations.
- **SQL Techniques:** Categorical grouping, comparative aggregate metrics.

```sql
SELECT 
    visit_type,
    COUNT(patient_id) AS patient_count,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_duration,
    ROUND(AVG(treatment_cost), 2) AS avg_treatment_cost
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY visit_type;
```
### 3. Highest Revenue Treatment Type per Department
- **Objective:** Identify the #1 revenue-generating procedure within each medical department using window ranking.
- **SQL Techniques:** Common Table Expressions (CTEs), Window Functions (`DENSE_RANK() OVER(PARTITION BY ...)`).

```sql
WITH RankedTreatments AS (
    SELECT 
        department,
        treatment_type,
        ROUND(SUM(treatment_cost), 2) AS total_cost,
        DENSE_RANK() OVER(PARTITION BY department ORDER BY SUM(treatment_cost) DESC) AS cost_rank
    FROM abc.healthcare_patient_analytics_seaborn
    GROUP BY department, treatment_type
)
SELECT department, treatment_type, total_cost
FROM RankedTreatments
WHERE cost_rank = 1;
```
### 4. Patient Demographics & Vulnerability Analysis
- **Objective:** Track average stay length and total billing across age brackets and genders.
- **SQL Techniques:** Multi-column aggregation (`GROUP BY age_group, gender`).

```sql
SELECT 
    age_group,
    gender,
    COUNT(patient_id) AS total_cases,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_days,
    ROUND(SUM(treatment_cost), 2) AS total_billing
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY age_group, gender
ORDER BY age_group, total_billing DESC;
```
### 5. Patient Acuity & Length of Stay Classification
- **Objective:** Classify patients into Short Stay (<3 days), Moderate Stay (3–6.9 days), and Critical/Prolonged Care (7+ days).
- **SQL Techniques:** Conditional logic (`CASE WHEN`).

```sql
SELECT 
    patient_id,
    department,
    treatment_type,
    length_of_stay_days,
    CASE 
        WHEN length_of_stay_days >= 7 THEN 'Prolonged / Critical Care'
        WHEN length_of_stay_days BETWEEN 3 AND 6.9 THEN 'Moderate Stay'
        ELSE 'Short Stay / Outpatient'
    END AS stay_category
FROM abc.healthcare_patient_analytics_seaborn
LIMIT 100;
```
