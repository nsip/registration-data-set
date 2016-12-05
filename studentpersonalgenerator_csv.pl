use Data::GUID::Any 'guid_as_string';
use Data::Random::Contact;
use String::Random;
use POSIX;

use strict;

# eg : perl studentpersonalgenerator_csv.pl xml 20 100 SA : generate 20 students per school for 100 schools in SA as XML
# eg : perl studentpersonalgenerator_csv.pl csv 20 100 SA a.txt : generate 20 students per school for 100 schools in SA as CSV, restricted to schools with IDs in a.txt

my $randomizer = Data::Random::Contact->new();
my $string_gen = String::Random->new;
my %acara_schools;
my %deewr_schools;

my $xml = ($ARGV[0] eq 'xml');
my $studentcount = $ARGV[1];
my $schoolcount = $ARGV[2];
my $state = $ARGV[3];
my $schoolslist = $ARGV[4];

my %include_schools = ();

if($schoolslist){
	open F, "<$ARGV[3]";
	while(<F>){
		chomp;
		$include_schools{$_}++;
	}
	close F;
}

#open F, "<a";
open F, "<asl_schools.csv";
while(<F>){
#<A B Paterson College,ARUNDEL,QLD,4214,Primary/Secondary,Non-Government,Open,48096,13495
        chomp;
	s/\r//g;
        my @a = split m/,/;
        push @{$acara_schools{$a[2]}}, $a[7] if ($include_schools{$a[7]} or not %include_schools);
        push @{$deewr_schools{$a[2]}}, $a[8] if ($include_schools{$a[7]} or not %include_schools);
}

my %location;

open F, "<postcode.csv";
while(<F>) {
	my @a = split m/,/;
	$a[1] =~ s/"//g;
	$a[0] = sprintf ("%04d", $a[0]);
	$location{$a[0]} = $a[1] unless exists $location{$a[0]};
}
close F;

my @schools;

sub postcode_gen($){
my ($state) = @_;
my ($low, $high, $ret);
if($state eq 'ACT') { $low = 2620; $high = 2899;}
if($state eq 'NSW') { $low = 1000; $high = 2600;}
if($state eq 'VIC') { $low = 3000; $high = 3999;}
if($state eq 'NT') { $low = 800; $high = 999;}
if($state eq 'QLD') { $low = 4000; $high = 4999;}
if($state eq 'SA') { $low = 5000; $high = 5999;}
if($state eq 'WA') { $low = 6000; $high = 6999;}
if($state eq 'TAS') { $low = 7000; $high = 7999;}
for(
        $ret = sprintf ("%04d", ceil ($low + rand($high-$low)) );
        !$location{$ret} ;
        $ret = sprintf ("%04d", ceil ($low + rand($high-$low)))
){ }
return $ret;
}

sub yearlevel($$){
        my ($student_ordinal, $student_count) = @_;
        #return ceil(rand(4))*2+1;
        my $ret = floor($student_ordinal*4 / $student_count);
        return $ret * 2 + 3;
}


if($ARGV[3]){
	open F, "<$ARGV[3]";
	while(<F>){
	chomp;
	my @a = split m/\t/;
	push @schools, $a[0];
	}
	close F;
	$schoolcount = scalar @schools;
}

if($xml) {
printf qq{<StudentPersonals xmlns="http://www.sifassociation.org/au/datamodel/3.4">};
} else {
printf qq{LocalId,SectorId,DiocesanId,OtherId,TAAId,StateProvinceId,NationalId,PlatformId,PreviousLocalId,PreviousSectorId,PreviousDiocesanId,PreviousOtherId,PreviousTAAId,PreviousStateProvinceId,PreviousNationalId,PreviousPlatformId,FamilyName,GivenName,PreferredName,MiddleName,BirthDate,Sex,CountryOfBirth,EducationSupport,FFPOS,VisaCode,IndigenousStatus,LBOTE,StudentLOTE,YearLevel,TestLevel,FTE,ClassCode,ASLSchoolId,SchoolLocalId,LocalCampusId,MainSchoolFlag,OtherSchoolId,ReportingSchoolId,HomeSchooledStudent,Sensitive,OfflineDelivery,Parent1SchoolEducation,Parent1NonSchoolEducation,Parent1Occupation,Parent1LOTE,Parent2SchoolEducation,Parent2NonSchoolEducation,Parent2Occupation,Parent2LOTE,AddressLine1,AddressLine2,Locality,Postcode,StateTerritory\n};
}
my ($i, $j);

my  ($acaraId, $localSchoolId);


for ($j=0;$j<$schoolcount;$j++){

if($ARGV[3]){
	$acaraId = $schools[$j];
	$localSchoolId = $schools[$j];
} else {
	$acaraId = $acara_schools{$state}[$j];
	$localSchoolId = $deewr_schools{$state}[$j];
}

for ($i=0;$i<$studentcount;$i++){

my $refid = guid_as_string();
my $person = $randomizer->person();
$$person{'address'}{'home'}{'street_1'} =~ s/\&/\&amp;/g;
$$person{'address'}{'home'}{'street_2'} =~ s/\&/\&amp;/g;
$$person{'address'}{'home'}{'street_1'} =~ s/"/\&quot;/g;
$$person{'address'}{'home'}{'street_2'} =~ s/"/\&quot;/g;
$$person{'address'}{'home'}{'street_1'} =~ s/,\s*/ /g;
$$person{'address'}{'home'}{'street_2'} =~ s/,\s*/ /g;
$$person{'address'}{'home'}{'street_1'} =~ s/[\n\r]/ /g;
$$person{'address'}{'home'}{'street_2'} =~ s/[\n\r]/ /g;
$$person{'address'}{'home'}{'street_1'} = "57 Mt Pleasant Street" unless $$person{'address'}{'home'}{'street_1'};
$$person{'address'}{'home'}{'street_1'} = "57 Mt Pleasant Street" if length($$person{'address'}{'home'}{'street_1'}) > 40;
$$person{'address'}{'home'}{'street_2'} = "57 Mt Pleasant Street" if length($$person{'address'}{'home'}{'street_2'}) > 40;

#my $yearlevel = ceil(rand(4))*2+1;
my $yearlevel = yearlevel($i, $studentcount);

my $postcode = postcode_gen($state);
#print $location{$postcode}, $postcode, "\n";
#
if($xml){
printf qq{
<StudentPersonal RefId="%s">
  <LocalId>%s</LocalId>
  <StateProvinceId>%s</StateProvinceId>
  <OtherIdList>
    <OtherId Type="SectorStudentId">%s</OtherId>
    <OtherId Type="DiocesanStudentId">%s</OtherId>
    <OtherId Type="OtherStudentId">%s</OtherId>
    <OtherId Type="TAAStudentId">%s</OtherId>
    <OtherId Type="NationalStudentId">%s</OtherId>
    <OtherId Type="NAPPlatformStudentId">%s</OtherId>
    <OtherId Type="PreviousLocalSchoolStudentId">%s</OtherId>
    <OtherId Type="PreviousSectorStudentId">%s</OtherId>
    <OtherId Type="PreviousDiocesanStudentId">%s</OtherId>
    <OtherId Type="PreviousOtherStudentId">%s</OtherId>
    <OtherId Type="PreviousTAAStudentId">%s</OtherId>
    <OtherId Type="PreviousStateProvinceId">%s</OtherId>
    <OtherId Type="PreviousNationalStudentId">%s</OtherId>
    <OtherId Type="PreviousNAPPlatformStudentId">%s</OtherId>
  </OtherIdList>
  <PersonInfo>
    <Name Type="LGL">
      <FamilyName>%s</FamilyName>
      <GivenName>%s</GivenName>
      <MiddleName>%s</MiddleName>
      <PreferredGivenName>%s</PreferredGivenName>
    </Name>
    <Demographics>
      <IndigenousStatus>%d</IndigenousStatus>
      <Sex>%d</Sex>
      <BirthDate>%s</BirthDate>
      <CountryOfBirth>1101</CountryOfBirth>
      <LanguageList>
        <Language>
          <Code>%04d</Code>
          <LanguageType>4</LanguageType>
        </Language>
      </LanguageList>
      <VisaSubClass>101</VisaSubClass>
      <LBOTE>%s</LBOTE>
    </Demographics>
    <AddressList>
      <Address Type="0765" Role="012B">
        <Street>
          <Line1>%s</Line1>
          <Line2>%s</Line2>
        </Street>
        <City>%s</City>
        <StateProvince>%s</StateProvince>
        <Country>1101</Country>
        <PostalCode>%s</PostalCode>
      </Address>
    </AddressList>
  </PersonInfo>
  <MostRecent>
    <SchoolLocalId>%s</SchoolLocalId>
    <YearLevel><Code>%s</Code></YearLevel>
    <FTE>%0.2f</FTE>
    <Parent1Language>%d</Parent1Language>
    <Parent2Language>%d</Parent2Language>
    <Parent1EmploymentType>%d</Parent1EmploymentType>
    <Parent2EmploymentType>%d</Parent2EmploymentType>
    <Parent1SchoolEducationLevel>%d</Parent1SchoolEducationLevel>
    <Parent2SchoolEducationLevel>%d</Parent2SchoolEducationLevel>
    <Parent1NonSchoolEducation>%d</Parent1NonSchoolEducation>
    <Parent2NonSchoolEducation>%d</Parent2NonSchoolEducation>
    <LocalCampusId>%s</LocalCampusId>
    <SchoolACARAId>%s</SchoolACARAId>
    <TestLevel><Code>%d</Code></TestLevel>
    <ClassCode>%s</ClassCode>
    <MembershipType>01</MembershipType>
    <FFPOS>%s</FFPOS>
    <ReportingSchoolId>%s</ReportingSchoolId>
    <OtherEnrollmentSchoolACARAId>%s</OtherEnrollmentSchoolACARAId>
  </MostRecent>
  <EducationSupport>%s</EducationSupport>
  <HomeSchooledStudent>%s</HomeSchooledStudent>
  <Sensitive>%s</Sensitive>
  <OfflineDelivery>%s</OfflineDelivery>
</StudentPersonal>
}, 
$refid, 
$string_gen->randregex('[a-z]{5}\d{3}'),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
$$person{'surname'} ,
$$person{'given'},
$$person{'middle'},
$$person{'given'},
ceil(rand(4)),
$$person{'gender'} eq 'male' ? 1 : 2,
dateofbirth($yearlevel),
language(),
yesno(),
$$person{'address'}{'home'}{'street_1'},
$$person{'address'}{'home'}{'street_2'},
$location{$postcode},
$state,
$postcode,
$localSchoolId,
$yearlevel,
rand(),
language(),
language(),
rand(4)+1,
rand(4)+1,
rand(4)+1,
rand(4)+1,
rand(4)+5,
rand(4)+5,
"01",
$acaraId,
$yearlevel,
$yearlevel . chr(ord('A') + rand(6)),
ceil(rand(2)),
$acaraId,
$string_gen->randregex('[a-z]{5}\d{3}'),
yesno(),
yesno(),
yesno(),
yesno(),

;
} else {
print join(',',
(
$string_gen->randregex('[a-z]{5}\d{3}'),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
psi(),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
ceil(rand(100000)),
psi(),
$$person{'surname'} ,
$$person{'given'},
$$person{'given'},
$$person{'middle'},
dateofbirth($yearlevel),
$$person{'gender'} eq 'male' ? 1 : 2,
1101,
yesno(),
ceil(rand(2)),
101,
ceil(rand(4)),
yesno(),
language(),
$yearlevel,
$yearlevel,
sprintf("%0.2f", rand()),
$yearlevel . chr(ord('A') + rand(6)),
$acaraId,
$localSchoolId,
"01",
ceil(rand(2)),
$string_gen->randregex('[a-z]{5}\d{3}'),
$acaraId,
yesno(),
yesno(),
yesno(),
floor(rand(4)+1),
floor(rand(4)+5),
floor(rand(4)+1),
language(),
floor(rand(4)+1),
floor(rand(4)+5),
floor(rand(4)+1),
language(),
$$person{'address'}{'home'}{'street_1'},
$$person{'address'}{'home'}{'street_2'},
$location{$postcode},
$postcode,
$state,

)), "\n";
}

}}
printf qq{</StudentPersonals>} if $xml;

sub yesno() {
	my $r = rand();
	return  $r < .45 ? 'Y' :
		$r < .9 ? 'N' :
		$r < .95 ? 'X' : 'U' ;
}

sub language(){
	my $r = rand();
	return $r < .8 ? 1201 :
		$r < .85 ? 7101 :
		$r < .9 ? 2201 :
		$r < .95 ? 5203 : 9601;
}

sub dateofbirth($){
	my ($yrlevel) = @_;
	my $year = 2010-$yrlevel;
	return sprintf "%s-%02d-%02d", $year, ceil (rand(12)), ceil (rand(28));
}

sub psi($){
	return sprintf "%s%09d%s", 
		rand() < 0.1 ? "D" : "R",
		rand(1000000000), "K";
	# ignoring checksum for now

}
