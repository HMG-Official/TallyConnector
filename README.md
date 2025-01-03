# Tally Connector Application

## Overview
Tally Connector is a desktop application designed to establish a connection with Tally ERP or Tally Prime through the Open Database Connectivity (ODBC) interface. It allows users to fetch essential data tables such as Daybook, Ledger Master, and Stock Master directly into a structured format. This data can be exported in multiple formats for further analysis or integration into other systems.

## Features
- **Port Configuration:** Specify the Tally ODBC port (default: `9000`).
- **Connect Tally:** One-click connection to Tally.
- **Data Imports:** Import Daybook, Ledger Master, Stock Master, and forensic data tables.
- **Multiple Formats:** Export data in CSV, HTML, Excel, and XML formats.
- **Dynamic Tab Addition:** Add new data tabs dynamically.
- **Remove Empty Columns:** A feature to clean up the imported data by removing empty Columns.
- **User Interface:** Intuitive and user-friendly UI designed for ease of use.

## Installation Instructions
1. Download the application executable from the [https://github.com/HMG-Official/TallyConnector].
2. Run the application EXE file.
3. Ensure Tally is running and ODBC connectivity is enabled.

### Prerequisites
- **Tally ERP/Prime:** Ensure Tally is running and configured with the required ODBC settings.
- **Windows OS:** The application currently supports Windows OS.
- **ODBC Configuration:** Verify that the Tally ODBC server is active and set to the correct port.

## How to Use

### 1. Launch the Application
- Open the Tally Connector application.

### 2. Configure Port
- Ensure that the ODBC port matches the port set in Tally.
- By default, the port is `9000`.

### 3. Connect to Tally
- Click on the **"Connect Tally"** button.
- The status bar will update with a connection message upon successful connection.

### 4. Select Data Tables
- Use the tabs (Daybook, Ledger Master, Stock Master, Forensics) to select the data you want to import. Note: This requires TechCA Tally TDL to be installed. For more details click About Page.
- Click the **"Import All"** button to import all available tables at once.

### 5. Export Data
- After the data is fetched, you can export it using the available formats:
  - **CSV:** Exports the data to a comma-separated values file.
  - **HTML:** Creates a table-formatted HTML file.
  - **Excel:** Direct export to Excel for easier data manipulation.
  - **XML:** Export data as XML for system integrations.

### 6. Remove Empty Columns
- Use the **"Remove Empty"** button to automatically clean the table by removing empty columns.

### 7. Add Custom Tabs
- Click **"Add Tab"** to create a new custom tab for additional data tables which can be selected from the combobox.

## Forensic Analysis
The Forensic tab enables the user to import critical financial data and perform checks for anomalies such as unusual ledger entries, duplicate transactions, and other indicators of inconsistency.

## Common Issues & Troubleshooting
- **Tally Not Connected:** Ensure that Tally is running and ODBC is enabled.
- **Port Mismatch:** Verify that the port in the application matches the ODBC port set in Tally.
- **Empty Tables:** Ensure that the selected data exists in Tally.
- **Permissions Issue:** Run the application with appropriate permissions if data cannot be fetched.


## Upcoming Features
- Support for JSON and PDF export.
- Data filtering and advanced search.
- Auto-scheduling of data imports.

## Contribution Guidelines
We welcome contributions! If you'd like to improve the software or fix issues:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description.

## License
This project is licensed under the GPL 3.0 License. See the LICENSE file for details.

## Contact
For questions, issues, or feature requests, contact:
- **Email:** [srathinagiri@gmail.com]
- **GitHub Issues:** Open an issue in the repository.

---

Thank you for using Tally Connector! Your feedback helps us improve the application.

