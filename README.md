# Coffee Sales Dashboard – SQL + Power BI

This project presents an analysis of coffee sales developed in two complementary phases:

1. **SQL** – initial data exploration and analysis, using queries to extract key metrics and trends.  
2. **Power BI** – construction of an interactive dashboard based on the same dataset, translating the SQL findings into dynamic and accessible visualizations.

---

## 🎯 Objective

- Understand sales patterns of coffee (products, periods, locations, etc.).  
- Use SQL to perform rigorous and structured data analysis.  
- Recreate and expand the analysis in Power BI, making insights more visual and user-friendly.  

---

## 📂 Project Structure

| Folder / File | Description |
|---------------|-------------|
| `sql/`        | SQL scripts used for queries, metric calculations, and initial exploration. |
| `powerbi/`    | `.pbix` file containing the Power BI dashboard. |
| `data/`       | Raw data (CSV/Excel, if applicable). |
| `README.md`   | This documentation file. |

---

## 🗂 Part I – SQL

The first phase was carried out entirely in SQL and included:

- **Data exploration**: inspecting tables, columns, and relationships.  
- **Cleaning and preparation**: handling duplicates, missing values, normalization.  
- **Key calculations**:
  - Total revenue by period.  
  - Quantity sold by product and/or category.  
  - Monthly trends and regional comparisons.  
  - Detection of outliers or underperforming products.  

This step provided the initial insights and the foundation for the next stage.

---

## 📊 Part II – Power BI

Based on the SQL analysis, an interactive dashboard was created in Power BI, including:

- **Time series charts** – sales trends over time.  
- **KPIs** – total revenue, units sold, margins.  
- **Comparisons** – by product, category, region.  
- **Interactive filters (slicers)** – date, coffee type, location.  

The dashboard reproduces the SQL findings while enabling further discovery through user interaction.

---

## ✔ Key Results

- Identification of best-selling and least profitable products.  
- Detection of seasonality and peak sales periods.  
- Regional performance comparisons to guide business strategies.  

---

## 🛠 Technologies Used

- **SQL** – (specify DBMS, e.g., MySQL, PostgreSQL).  
- **Power BI Desktop** – version used (e.g., September 2023).  
- **Excel / CSV** – raw data source (if applicable).  

---

## 🚀 How to Reproduce

1. **SQL**
   - Run the provided scripts in your database to generate calculations and supporting tables.  

2. **Power BI**
   - Open the `.pbix` file.  
   - Explore the interactive dashboards (no database connection required since the analysis was performed beforehand).  

---

## 📌 Future Improvements

- Automate data loading to avoid manual updates.  
- Include predictive analysis (sales forecasting).  
- Publish the dashboard on Power BI Service for online access.  

---

## 👥 Authors

- Cintia Oliveira
- 
© All rights reserved to the YouTube channel [Data Tutorials](https://www.youtube.com/@DataTutorials).
