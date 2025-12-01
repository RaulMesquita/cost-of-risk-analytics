# 📘 **CREDIX - Cost of Risk Analytics Platform**  
### _Analytics Engineer Case Study_

---

## 🧭 1. **Project Objective**

This project implements a analytical pipeline to compute **Cost of Risk** for loan origination cohorts using **Point-in-Time (PIT)** logic.

The output is a trustworthy, auditable, and BI-ready dataset consumed by:

- Risk Team  
- Finance / P&L  
- Go-to-Market  
- Board & Investors  

---

## 📊 2. **Business Definition: Cost of Risk**

The business defines:

Cost of Risk = Face Value * Provision Rate

### **Provision Rate Priority Logic (highest → lowest):**

#### 1. **Settled Assets (Paid)**

#### 2. **Defaulted Assets (>30 days overdue)**

#### 3. **Active Assets (not settled & not defaulted)**
Provision depends on **Buyer Rating (PIT)**:

| Rating | Provision Rate |
|--------|----------------|
| A | 1% |
| B | 5% |
| C | 10% |
| D | 20% |
| E | 30% |
| F | 40% |

---

## ⏳ 3. **Point-in-Time Requirements (PIT)**

The system must **never** use `CURRENT_DATE()` or "today".

Overdue & default definitions must use only **historically observable data**:

If `settled_at` is NULL → the asset is considered **active**, not overdue.

PIT ensures:

> The rating used is the one that was valid at the time the asset was originated.

---

## 🧱 4. **Architecture Overview (Medallion + dbt)**

### **Staging (stg_)**
- Cleans input data  
- Removes duplicates  
- Standardizes datatypes  
- No business rules applied  

### **Intermediate (int_)**
- Builds rating validity windows  
- Computes PIT-origin rating  
- Derives settled / overdue / default flags  

### **Marts (mrt_)**
- Cohort-level aggregation  
- Applies final Cost of Risk logic  
- BI-ready  

### **Semantic Layer**
- Defines dimensions, entities, measures, and ratios  
- Enables no-SQL exploration in BI tools  

---

## 🧬 5. **Rating Dimension (`dim_rating`)**

Managed via a dbt **seed** (`seeds/dim_rating.csv`):

| rating | provision_rate |
|--------|----------------|
| A | 0.01 |
| B | 0.05 |
| C | 0.10 |
| D | 0.20 |
| E | 0.30 |
| F | 0.40 |

This avoids hardcoding business logic inside models.

---

## 📈 6. Final Gold Model (mrt_cost_of_risk)**

This model computes the final provision rate using the correct business priority:

```
CASE
  WHEN settled_flag = 1 THEN 0.00
  WHEN default_flag = 1 THEN 1.00
  ELSE base_rate
END AS provision_rate
```

### **Output Grain:**
(cohort_month, segment, seller_name)

### Output Metrics:**
- total_face_value
- cost_of_risk
- avg_provision_rate
- n_assets
- settled_face_value
- overdue_face_value
- default_face_value

---

## 🧠 7. Semantic Layer (metrics.yml)**

### The semantic model defines:**

### **Dimensions**
- cohort_month
- segment
- seller_name

### **Measures**
- cost_of_risk
- total_face_value
- n_assets
- overdue_face_value
- default_face_value
- settled_face_value

### **Derived Metrics**
- avg_provision_rate_ratio = cost_of_risk / total_face_value
- default_rate = default_face_value / total_face_value
- overdue_rate = overdue_face_value / total_face_value

This enables BI tools to query metrics without SQL.

---

## 🧪 8. Testing Strategy**

### **Staging**
- not_null on key fields
- duplicate prevention
- type validations

### **Intermediate**
- PIT correctness
- rating-to-asset relationship tests
- overdue/default consistency

### **Marts**
- unique grain:
- cohort_month, segment, seller_name
- not_null on metrics

### **Seeds**
- unique & not_null on rating