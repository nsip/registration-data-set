# registration-data-set

Machine readable schemas for the NAPLAN Online registration data set. Derived from the _NAPLAN Online Registration Data Set_ specification, v2.00 (October 2018)

* *core.json* is a JSON Schema expression of the NAPLAN Online Registration Data Set specification, which is used in the [NIAS Golang NAPLAN Registration validation suite](https://github.com/nsip/nias2)
* *core_parent2.json* is an additional JSON Schema expression of the NAPLAN Online Registration Data Set specification, conveying the requirement that if one Parent2 field is present, all Parent2 fields must be present. This schema is also used in the [NIAS Golang NAPLAN Registration validation suite](https://github.com/nsip/nias2), and may be disabled if necessary.
* *Registration Data Set - Specifications v105.pdf* is the current registration data set specification.
* *studentpersonalgenerator_csv.pl* is a Perl script used to generate test data
* *400schools150students.csv* is a sample CSV file corresponding to 400 schools of 150 students each in South Australia.
* *400schools150students.xml.zip* is a sample XML file with the same content as *400schools150students.csv*.
 
These schemas will be updated in line with updates to the registration data set specification.
