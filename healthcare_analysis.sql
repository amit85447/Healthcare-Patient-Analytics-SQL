SELECT * FROM abc.healthcare_patient_analytics_seaborn;

SELECT 
    department,
    COUNT(patient_id) AS total_patients,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_days,
    ROUND(SUM(treatment_cost), 2) AS total_revenue,
    ROUND(AVG(treatment_cost), 2) AS avg_cost_per_patient
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY department
ORDER BY total_revenue DESC;

SELECT 
    visit_type,
    COUNT(patient_id) AS patient_count,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_duration,
    ROUND(AVG(treatment_cost), 2) AS avg_treatment_cost
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY visit_type;

WITH RankedTreatments AS (
    SELECT 
        department,
        treatment_type,
        ROUND(SUM(treatment_cost), 2) AS total_cost,
        DENSE_RANK() OVER(PARTITION BY department ORDER BY SUM(treatment_cost) DESC) as cost_rank
    FROM abc.healthcare_patient_analytics_seaborn
    GROUP BY department, treatment_type
)
SELECT department, treatment_type, total_cost
FROM RankedTreatments
WHERE cost_rank = 1;

SELECT 
    age_group,
    gender,
    COUNT(patient_id) AS total_cases,
    ROUND(AVG(length_of_stay_days), 1) AS avg_stay_days,
    ROUND(SUM(treatment_cost), 2) AS total_billing
FROM abc.healthcare_patient_analytics_seaborn
GROUP BY age_group, gender
ORDER BY age_group, total_billing DESC;

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