# file_cleaner

### Set up
Clone the repo and switch to specified ruby version.  
`bundle install` gems (rspec).  
Run `rspec spec` and verify that all tests pass.

### Usage
You can run this directly against an input file from the root directory (args optional):
```
ruby file_cleaner.rb input_filename_arg output_filename_arg validation_arg
```
input_filename_arg - name of the input file  
output_filename_arg - name of the output file  
validation_arg - bool, default true. this controls whether optional validation should run. optional validation results stored in report.txt  

### Output
All rows that parse without issue will be cleaned/transformed and written to the output file.  

All rows that fail to parse due to malformed data or fail the required validation constraints are stored with details per row/column in report.txt  

I noticed that some of the rows may contain suspect data that is not addressed in the required validation. I included some basic
optional validation to check for duplicate member_ids and effective_dates that start after expiry_dates. Optional validation results
are stored in report.txt. Rows that fail optional validation are NOT excluded from the output file.  


### Assumptions
#### Phone Numbers
Phone numbers with 10 digits will be parsed to e164 format (including the US country code).  

Phone numbers with less than 10 digits will raise an error and cause the row to fail parsing.  

Phone number with greater than 10 digits will only be parsed if the first (11th) digit is equal to the US country code (1). Otherwise, will raise an error and fail parsing.  

### Dates
Dates that are not parsed with the set list of formats will raise an error and cause the row to fail parsing.  

There is an additional check for rows that are successfully parsed with a given format. Parsing dates without knowing the exact format can some produce the wrong result without raising an error. 
 For example:  
 
`9/30/19` parsed using `%m/%d/%Y` will produce `0019-09-30`  

`verify_date` in `date_utils.rb` checks to see that the parsed date falls within what I'm assuming is a reasonable range (1900 < date < 2200). 

### General
I left some `TODOs` in the code for things I ran out of time to get to or was thinking about. In general I tried to focus on breaking the code apart into pieces that are easier to test and maintain. I payed less attention to producing the cleanest possible code so refactoring is something I would focus on with more time. 


