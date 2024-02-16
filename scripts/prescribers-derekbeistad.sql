SELECT *
FROM prescriber;

SELECT *
FROM prescription;

-- 1A. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi,
	SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;

-- OR via subquery
SELECT npi,
	SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
HAVING SUM(total_claim_COUNT) =(SELECT SUM(total_claim_count) AS total_claims
	FROM prescription
	GROUP BY npi
	ORDER BY total_claims DESC
	LIMIT 1)

-- 		A. npi: 1881634483	total: 99707

-- 1B. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT prescription.npi,
	prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description,
	SUM(prescription.total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY prescription.npi, prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description
ORDER BY total_claims DESC;
-- 		A. 1881634483	"BRUCE"	"PENDLEY"	"Family Practice"	99707

-- 2A. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(prescription.total_claim_count) AS total_claims,
	prescriber.specialty_description
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;
-- 		A. 9752347	"Family Practice"

-- 2B. Which specialty had the most total number of claims for opioids?
SELECT prescriber.specialty_description, SUM(opioid_npi.total_claims) AS sum_opioid_claims
FROM prescriber
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
		FROM prescription
		WHERE drug_name IN (SELECT drug_name
				FROM drug
				WHERE opioid_drug_flag ILIKE 'y')
		GROUP BY npi) as opioid_npi
ON prescriber.npi = opioid_npi.npi
GROUP BY prescriber.specialty_description
ORDER BY sum_opioid_claims DESC;
-- 		A. "Nurse Practitioner"	900845
		
-- 3A. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS total_generic_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY total_generic_cost DESC;
-- 		A. "INSULIN GLARGINE,HUM.REC.ANLOG"	104264066.35

-- 3A.alt. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, AVG(prescription.total_drug_cost) AS total_generic_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY total_generic_cost DESC;
-- 		A. "ASFOTASE ALFA"	1890733.045000000000

-- 3B. Which drug (generic_name) has the highest total cost per day?
SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost / prescription.total_day_supply), 2) AS cost_per_day
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC;
-- 		A. "LEDIPASVIR/SOFOSBUVIR"	88270.87

-- 3B.alt. Which drug (generic_name) has the highest total cost per day?
SELECT drug.generic_name, ROUND(AVG(prescription.total_drug_cost / prescription.total_day_supply), 2) AS cost_per_day
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC;
-- 		A. "C1 ESTERASE INHIBITOR"	3418.84
