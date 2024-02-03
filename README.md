# Snowflake-Native-Application-Project
This repository contains all the necessary files and instructions to set up and deploy a Snowflake Native Application. This application leverages the powerful data platform of Snowflake for enhanced performance, security, and ease of use, making it ideal for businesses looking to integrate tightly with their data.
# Contents
scripts/: Contains SQL scripts for setting up schemas, tables, stored procedures, and other database objects.
python/: Includes Python code for User-Defined Functions (UDFs) or other Python integrations.
streamlit/: Contains Streamlit application files for interactive web applications.
manifest.yml: A manifest file listing all the components of the application.
# Usage
The application can be used for a variety of purposes, depending on the business logic implemented in the scripts. It could range from data analysis, reporting, to complex data manipulation tasks.
# Contributing
Contributions to this project are welcome. Please ensure to follow the best practices for coding and documentation.

Creating and deploying a Snowflake Native Application involves several detailed steps. Here's a comprehensive guide to walk you through the process:

By following these steps, you can successfully develop, deploy and manage a native application in Snowflake. Each step is crucial in ensuring the application is built correctly and functions as intended. This guide provides a structured pathway, guiding through each phase of development, from initial setup to final deployment. This guide is especially useful for those new to Snowflake, offering a clear roadmap to successfully build and manage a native application.

GitHub Repository: The complete code for this project, including scripts and configuration files, can be found at a  GitHub repository.

1. Create the Application Files : (Key files:) README.md, manifest.yml, and folders for scripts and Python code.
      i> /scripts/Setup_Vishal1.sql (setup script)
     ii> manifest.yml
    iii> readme.md
    Setup script: Contains business logic, stored procedures and functions.
    Manifest file: Lists all components of the application.
2. Create an Application Package :
   GRANT CREATE APPLICATION PACKAGE ON ACCOUNT TO ROLE accountadmin;
   CREATE APPLICATION PACKAGE NativeApp_snowflake_package;
   SHOW APPLICATION PACKAGES;

3. Upload Application Files to the Named Stage(from step 1) : Uploading files to a named stage, which acts as a wrapper for the application.
   -- Create a stage in Snowflake and upload key application files
   USE APPLICATION PACKAGE Native_snowflake_package;
   CREATE SCHEMA Vishal_stage_content;
   CREATE OR REPLACE STAGE NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage
   FILE_FORMAT = (TYPE = 'csv' FIELD_DELIMITER = '|' SKIP_HEADER = 1);
   LIST @NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage;

4. Add Application Logic:  
   In Step 2 created an application package. However, the application package doesn’t yet contain any data content or   
   application files.In this step, we will add a stored procedure to the application by adding the code for the stored 
   procedure to the setup script "scripts/Setup_Vishal1.sql"

5. Install the Application: create an application containing a stored procedure that add application logic to an application.
   CREATE APPLICATION Vishal_SNOWFLAKE_APP FROM APPLICATION PACKAGE NativeApp_snowflake_package
   USING '@NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage';
   SHOW APPLICATIONS;

   -- To run the stored procedure that was added to Setup_Vishal1.sql in a previous section, run the following command:
    CALL Schema_Name.procedure_name(); -- procedure name details fetch from scripts/Setup_Vishal1.sql

6.  Create a Database to Share with an Application: 
    In this step include data content with an application by creating a database within the application package and granting privileges to share this database with the 
    application (insert the sample static data in the application package)
    
    USE APPLICATION PACKAGE NATIVEAPP_SNOWFLAKE_PACKAGE;
    CREATE SCHEMA IF NOT EXISTS shared_data;
    CREATE TABLE IF NOT EXISTS accounts (ID INT, NAME VARCHAR, VALUE VARCHAR);
    
    INSERT INTO accounts VALUES
    (1, 'Nihar', 'Snowflake'),
    (2, 'Frank', 'Snowflake'),
    (3, 'Benoit', 'Snowflake'),
    (4, 'Steven', 'Acme');

    SELECT * FROM accounts;

    -- To ensure that the 'accounts' table is accessible to all applications derived from the application package, it is necessary to grant appropriate privileges on 
    -- the objects within the package.
    -- Important:
    -- For any object in an application package that you intend to share with a consumer, it is mandatory to assign the USAGE privilege to that specific object."

    GRANT USAGE ON SCHEMA shared_data TO SHARE IN APPLICATION PACKAGE NATIVEAPP_SNOWFLAKE_PACKAGE;
    GRANT SELECT ON TABLE accounts TO SHARE IN APPLICATION PACKAGE NATIVEAPP_SNOWFLAKE_PACKAGE;
    -- If you dont want consumer to see the data from table outside the application UI. In order to manage the consumer's access,  assign the USAGE privilege to the 
    -- role for this specific table, and not granting SELECT privileges. This approach effectively controls the consumer's ability to interact with the data. To 
    -- reiterate, while I am granting USAGE on the schema, I am withholding SELECT privileges on the table itself. As a result, although the stored procedure can 
    -- access and read the table content, the consumer is restricted from executing a SELECT query on this table. From the consumer's perspective, the table 
    -- essentially does not exist, rendering it invisible and inaccessible for direct querying.

7. Add a View to Access Data Content :
   Update the setup script("/scripts/Setup_Vishal1.sql") to add a view that allows the application to access the data in the ACCOUNTS table.

8. Test the Updated Application : Reinstall the application and query the Accounts table using the view within the installed application.
   -- After uploading the updated setup script to the named stage
   DROP APPLICATION Vishal_SNOWFLAKE_APP

   CREATE APPLICATION Vishal_SNOWFLAKE_APP FROM APPLICATION PACKAGE NativeApp_snowflake_package 
   USING '@NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage';

9. Enhancing Application functionality with Python Code:  In the setup script ("/scripts/Setup_Vishal1.sql"), include your custom Python function:

   CREATE or REPLACE FUNCTION code_schema.multiply(num1 float, num2 float)
   RETURNS float
   LANGUAGE PYTHON
   RUNTIME_VERSION=3.8
   IMPORTS = ('/python/udf_python.py')
   HANDLER='udf_python.multiply'; -- This line specifies the Python function named as the handler for this UDF. The handler function is the actual  
                                  -- implementation of the UDF logic.
   GRANT USAGE ON FUNCTION code_schema.multiply(FLOAT, FLOAT) TO APPLICATION ROLE app_public;

   -- Create a subfolder named "python" in named stage folder.
   -- Inside the "python" subfolder, create a file named "udf_python.py" with the  content:

   -- By following these steps added a Python UDF to an application that references an external Python module for use in the application package.

10. Install and Test the Updated Application :
    -- Upload the revised setup files to the named stage.
    -- To remove the existing application, run the following command:
    DROP APPLICATION Vishal_SNOWFLAKE_APP;
    -- To create a new version of the application, run the following commands:
    CREATE APPLICATION Vishal_SNOWFLAKE_APP FROM APPLICATION PACKAGE NativeApp_snowflake_package 
    USING '@NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage';
    -- To test the referenced Python function, run the following command:
    SELECT code_schema.multiply(1,2);

11. Add a Streamlit App to  Application : Create the Streamlit App File
    -- Streamlit is an open source Python framework for developing data science and machine learning applications. Include Streamlit apps within a Native App to add 
    -- user interaction and data visualization.
    -- create a subfolder named streamlit. In the streamlit folder, create a python file filename_snowflake.py.(refer github file in the streamlit folder
    -- This file contains :
    # Import python packages
    # Write directly to the app
    # Get the current account credentials
    # Create a data frame using the view
    # Execute the query and convert it into a Pandas data frame
    # Display the Pandas data frame as a Streamlit data frame.
 
12. Add the Streamlit Object to the Setup Script :
    -- Add the following statement at the end of the Setup_Vishal1.sql file to create the Streamlit object:
    CREATE STREAMLIT code_schema.Vishal_snowflake_streamlit
    FROM '/streamlit' MAIN_FILE = '/filename_snowflake.py';
    -- This statement creates a STREAMLIT object in the  schema.
    -- Add the following statement at the end of the setup.sql file to allow the role to access the Streamlit object:
    GRANT USAGE ON STREAMLIT code_schema.Vishal_snowflake_streamlit TO APPLICATION ROLE app_public;
    -- Upload the new and updated application files to the named stage

13. Install the Updated Application :
    -- To remove the existing application, run the following command:
    DROP APPLICATION Vishal_SNOWFLAKE_APP;
    -- To create a new version of the application, run the following commands:
    CREATE APPLICATION Vishal_SNOWFLAKE_APP FROM APPLICATION PACKAGE NativeApp_snowflake_package 
    USING '@NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage';

14. Add a Version to Application : 
    ALTER APPLICATION PACKAGE NativeApp_snowflake_package ADD VERSION v1_0 
    USING '@NativeApp_snowflake_package.Vishal_stage_content.Vishal_SF_stage';
    SHOW VERSIONS IN APPLICATION PACKAGE NativeApp_snowflake_package;
    -- Redeploy Application using the version
    DROP APPLICATION hello_snowflake_app;
    CREATE APPLICATION Vishal_SNOWFLAKE_APP FROM APPLICATION PACKAGE NativeApp_snowflake_package 
    USING VERSION V1_0;

15. Set the Default Release Directive :
    -- To create a listing for application package, it's essential to define a release directive first. This directive indicates the specific version of application 
    -- that is accessible to consumers.
    ALTER APPLICATION PACKAGE hello_snowflake_package SET DEFAULT RELEASE DIRECTIVE
    VERSION = v1_0 PATCH = 0;
    

16. Create a Listing for Your Application : Create a private listing containing the application package as the shared data content.
    After defining the release directive for application package, create a listing and add the application package as its data content. This enables to share the 
    application with other Snowflake users, allowing them to install and use it in their accounts.
    -- To create a listing for your application:
    i.> Sign in to Snowsight. In the left navigation bar, select Data » Provider Studio.
    ii.> Click + Listing to open the Create Listing window. Provide a name for your listing.
         Under "Who can discover the listing," select "Only specified consumers" to privately share the listing with specific accounts.
         Click + Select to choose the application package for the listing.
         Add a description for your listing.
    iii> In the "Add consumer accounts" section, include the account identifier for the account where you intend to test the consumer experience of installing the 
         application from the listing.


17. Install the Application : Next, install the application associated with the listing in a different account to simulate how a consumer would install the application 
     in their own account.
    -- To install the application from the listing:
    i.> Sign in to Snowsight. In the left navigation bar, select Apps.Choose the tile for the listing that was recently shared & Click Get.
    ii.> Provide a customer-facing name for the application , Select the warehouse to install the application & Click Get.
    iii.> Choose Open to view the listing or Done to complete the installation process.




