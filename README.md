# Tidy ROTEM sigma exports

*Note: I have no relationship to companies that make or distribute the ROTEM sigma.*

These R scripts can be used to store ROTEM sigma data for research purposes and audit. 


The ROTEM sigma exported text files do not import into R in usable format - each ROTEM channel gets placed on its own line, so an individual patient will have multiple lines per individual test. In addition, each test has its own start time making grouping of tests dififcult. 

This script takes the exported TXT files from the ROTEM sigma ([https://werfen.com/au/en/haemostasis-diagnostics/rotem-sigma](https://werfen.com/au/en/haemostasis-diagnostics/rotem-sigma)) and tidies them. The output is consistent with Tidyverse principles of one row per patient/test and one cell per variable (see [https://en.wikipedia.org/wiki/Tidyverse](https://en.wikipedia.org/wiki/Tidyverse)). It also has a script to upload to a REDCap project. 

  
**It is assumed that the patient's ID is in the ROTEM 'Patient ID' column**


*   STEP 1: Import the txt files. You will need to enter the path to the text files in the file.path command. A unique ID is created from the MRN and the start date and time of the fibtem channel. The MRN is kept in a separate column. The uni\_id is needed as a unique record\_id is required for REDCap, as the MRN (which can be repeated if there is more than one ROTEM per patient) won't suffice as a record\_id for grouping purposes. The uni\_id identifies the record as an individual ROTEM cartridge with multiple channels, and the MRN can be used to identify the patient. 
*   STEP 2: PIVOT the ROTEM results wide. This creates a column for each of the ROTEM measurements for each test. If the test was stopped before the measurement was completed, NA's are entered (for example, ROTEM stopped at 30mins, EXTEM C ML60 will be NA).
*   STEP 3: Add a label if HEPTEM was not invalid (eg a HEPTEM was run) as this is likely a cardiac surgery case. This field may or maynot be useful as vascular patients given heparin may also have HEPTEM ROTEMs performed. 
*   STEP 4: Upload to REDCap. You will need your own REDCap project but you should use the data dictionry provided here. The data dictionary in this repository will be needed to map the R project fields with the REDCap project, otherwise the upload will fail. 
*   STEP 5: Upload the image files if you have exported them.

  

**Note**: for steps 1 and 5, you need to enter the path of the exported ROTEM .txt and image files.

*   For line 17: To enter the file.path correctly enter the folders and then the filename like ("C:", "ROTEM" , "Backups" , "filename.txt")
*   For lines 125, 132, 140: To enter the file.path correctly enter the folders but NOT the filename ("C:", "ROTEM" , "Backups")

  

The final data frame consists of the following columns. Note: ct = clotting time, cft = clot formation time, ml = maximum lysis, li = lysis. the sample_id column is a field on the ROTEM sigma that could be used to identify a sampe for a study, for example listing blood products given. 

| uni\_id |
| --- |
| patient\_id |
| sample\_id |
| patient\_name |
| lot\_1 |
| rotem\_start\_time |
| rotem\_run\_time |
| start\_time\_fibtem\_c |
| start\_time\_extem\_c |
| start\_time\_intem\_c |
| start\_time\_heptem\_c |
| start\_time\_aptem\_c |
| run\_time\_fibtem\_c |
| run\_time\_extem\_c |
| run\_time\_intem\_c |
| run\_time\_heptem\_c |
| run\_time\_aptem\_c |
| ct\_fibtem\_c |
| ct\_extem\_c |
| ct\_intem\_c |
| ct\_heptem\_c |
| ct\_aptem\_c |
| a5\_fibtem\_c |
| a5\_extem\_c |
| a5\_intem\_c |
| a5\_heptem\_c |
| a5\_aptem\_c |
| a10\_fibtem\_c |
| a10\_extem\_c |
| a10\_intem\_c |
| a10\_heptem\_c |
| a10\_aptem\_c |
| a20\_fibtem\_c |
| a20\_extem\_c |
| a20\_intem\_c |
| a20\_heptem\_c |
| a20\_aptem\_c |
| a30\_fibtem\_c |
| a30\_extem\_c |
| a30\_intem\_c |
| a30\_heptem\_c |
| a30\_aptem\_c |
| cft\_fibtem\_c |
| cft\_extem\_c |
| cft\_intem\_c |
| cft\_heptem\_c |
| cft\_aptem\_c |
| mcf\_fibtem\_c |
| mcf\_extem\_c |
| mcf\_intem\_c |
| mcf\_heptem\_c |
| mcf\_aptem\_c |
| li30\_fibtem\_c |
| li30\_extem\_c |
| li30\_intem\_c |
| li30\_heptem\_c |
| li30\_aptem\_c |
| li45\_fibtem\_c |
| li45\_extem\_c |
| li45\_intem\_c |
| li45\_heptem\_c |
| li45\_aptem\_c |
| li60\_fibtem\_c |
| li60\_extem\_c |
| li60\_intem\_c |
| li60\_heptem\_c |
| li60\_aptem\_c |
| ml\_fibtem\_c |
| ml\_extem\_c |
| ml\_intem\_c |
| ml\_heptem\_c |
| ml\_aptem\_c |
| possible\_cardiac |
| fibtem\_image |
| aptem\_image |
| intem\_image |
| heptem\_image |
| extem\_image |
