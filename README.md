# 🏘️ Airbnb Price Prediction in Boston: A Dynamic Modeling Approach 📊

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Airbnb_Logo_B%C3%A9lo.svg/1200px-Airbnb_Logo_B%C3%A9lo.svg.png" alt="Airbnb Boston Banner" width="600">
  <span style="font-size: 3rem; color: #FF5A5F; font-weight: bold; font-family: 'Arial';">Boston, Massachusetts, USA</span>

</p>

## 📝 Description

This project focuses on developing a dynamic model to estimate **[Airbnb](https://www.airbnb.com/)** listing prices in the city of Boston. We've analyzed various factors impacting price, including location, property type, host characteristics, and seasonal variations. The goal is to build a robust and reliable predictive model.

## ✨ Objective

The key objectives of this project are to:

*   Develop a model for Airbnb listing prices in Boston.
*   Explore the relationships between various features and price.
*   Apply dynamic modeling techniques to improve prediction accuracy.
*   Provide insights relevant to hosts, potential investors, and the city government.

<p align="center">
    <a href="https://www.airbnb.com/">
        <img src="https://img.shields.io/badge/Airbnb-FF5A5F?style=for-the-badge&logo=airbnb&logoColor=white" alt="Airbnb" />
    </a>
</p>

## 📖 Context
This project was carried out within the scope of the **UC Introdução a Modelos Dinâmicos** (*Introduction to Dynamic Models* - IMD) course in the **[Licenciatura em Ciência de Dados](https://www.iscte-iul.pt/degree/code/0322/bachelor-degree-in-data-science)** (*Bachelor Degree in Data Science*) at **ISCTE-IUL**.

## 🗺️ Data Source

We utilized data from the [Inside Airbnb website](http://insideairbnb.com/get-the-data/). These data focuses on Boston:

*   **`listings.csv`**: Detailed information about Airbnb listings in Boston.
*   Features: *id, name, host_id, host_name, neighbourhood_group, neighbourhood, latitude, longitude, room_type, price, minimum_nights, number_of_reviews, last_review, reviews_per_month, calculated_host_listings_count, availability_365, license, number_of_reviews_ltm*.

## ⚙️ Technologies Used

*   **[R](https://www.r-project.org/)**: The primary programming language and statistical computing environment.
*   **[RStudio](https://www.rstudio.com/)**: Integrated Development Environment (IDE) for R. 
    * *In addition, the models may also be tested on the "IRkernel"(Jupyter Notebook)*

<p align="center">
    <a href="https://www.r-project.org/">
        <img src="https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white" alt="R" />
    </a>
    <a href="https://www.rstudio.com/">
        <img src="https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=rstudio&logoColor=white" alt="RStudio" />
    </a>
    <a href="https://jupyter.org/">
        <img src="https://img.shields.io/badge/Jupyter-F37626?style=for-the-badge&logo=jupyter&logoColor=white" alt="Jupyter Notebook" />
    </a>
    <a href="https://cran.r-project.org/web/packages/IRkernel/index.html">
        <img src="https://img.shields.io/badge/IRkernel-276DC3?style=for-the-badge&logo=r&logoColor=white" alt="IRkernel" />
    </a>
    <a href="https://www.markdownguide.org/">
        <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white" alt="Markdown" />
    </a>
</p>

*   **[Power BI](https://powerbi.microsoft.com/)**: for visualizing the results.
 
<p align="center">
   <a href="https://powerbi.microsoft.com/">
        <img src="https://img.shields.io/badge/Power_BI-F2C800?style=for-the-badge&logoColor=black" alt="Power BI" />
    </a>
</p>

---

<br>

## 💻 Project Structure (Focus: Dynamic Modeling)

1.  **Business Understanding:** 💡

    *   Explored a website to help understand the database with the meaning of its factors (ex: *Airbnb*).
    *   Define Problem: Price a database, so we needed to choose factors to explain data (and make an **ETL**). The methodology used was **CRISP-DM**.

<p align="center">
    <a href="https://www.ibm.com/cloud/learn/crisp-dm">
        <img src="./Img/CRISP-DM_Methodology.png" alt="CRISP-DM" width="600">
    </a>
</p>


2.  **Data Understanding:** 🔍

    *   Loaded and inspected the structure of the `listing.csv` datasets.
    *   Understood the meaning of each variables: the data is related on AirBnb for Boston in *15/September/2022*.
    *   **Exploratory Data Analysis (EDA):** Analyzed the distribution of variables, relationships between features, and potential patterns.
  

3.  **Data Preparation:** 🛠️
    
    *   **Data Cleaning:** Removed missing values, outliers, and irrelevant columns.
    *   **Feature Engineering:** Created new variables and transformed existing ones.
    *   **Data Transformation:** Normalized and standardized the data.

4.  **Modeling:** 🤖
   
    *   The goal was to study the **Price** by applying linear regression models with specific datasets and with supervisionated analysis.
    *  **Simple/ Multiple Linear Regression Assumptions:** 
        *   **Linearity:** The relationship between the independent and dependent variables is linear.
        *   **Independence:** Observations are independent of each other.
        *   **Homoscedasticity:** The variance of the residuals is constant across all levels of the independent variables.
        *   **Normality:** The residuals are normally distributed.
        *   **No Multicollinearity:** The independent variables are not highly correlated with each other.
    *   **Model Selection:** We tested different models and selected the best one based on performance metrics.
  

5.  **Evaluation:** ✅

    *   Show how many variables may have influence over the model, and tested some values and outliers.
    *   The model validation had two main points: in and out-sample data evaluation.
    *   **Model Evaluation Metrics:** 
        *   **Residual Error:** The difference between the predicted and actual values.
        *   **R-Squared ($R^2$):** The proportion of the variance in the dependent variable that is predictable from the independent variables.
        *   **AIC (Akaike Information Criterion):** A measure of the relative quality of a statistical model.
        *   **BIC (Bayesian Information Criterion):** A criterion for model selection among a finite set of models.
        *   **MAPE (Mean Absolute Percentage Error):** A measure of prediction accuracy. (*out-of-sample* and *in-sample*).

6.  **Deployment:** 🚀

    *   Developed the final report.
    *   Created a Power BI dashboard to visualize the results.
  
---

## 📊 Power BI Dashboard

This is how Power BI dashboard looked:

<p align="center">
  <img src="./Img/PowerBI_ExamplePage.png" alt="Power Bi Dashboard" width="800">
</p>
  
## 🇵🇹 Note

This project was developed using Portuguese from Portugal 🇵🇹.
