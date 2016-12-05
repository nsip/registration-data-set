# registration-data-set

Machine readable schemas for the NAPLAN Online registration data set. Derived from the _NAPLAN Online Registration Data Set_ specification, v. 0.98 (May 23 2016)

* *NAPLANRegistrationDraft.xsd* is the XSD for a subset of the [SIF 1.4 specification](http://specification.sifassociation.org/Implementation/AU/1.4/html/), containing only the objects, elements and code sets required for NAPLAN Online registration of students.
* *core.json* is a JSON Schema expression of the NAPLAN Online Registration Data Set specification, which is used in the [NIAS Golang NAPLAN Registration validation suite](https://github.com/nsip/nias-go-naplan-registration)
* *core_parent2.json* is an additional JSON Schema expression of the NAPLAN Online Registration Data Set specification, conveying the requirement that if one Parent2 field is present, all Parent2 fields must be present. This schema is also used in the [NIAS Golang NAPLAN Registration validation suite](https://github.com/nsip/nias-go-naplan-registration), and may be disabled if necessary.
* *Registration Data Set - Specifications v098.docx* is the Microsoft Word document of the current registration data set specification.
* *studentpersonalgenerator_csv.pl* is a Perl script used to generate test data
 
These schemas will be updated in line with updates to the registration data set specification.
