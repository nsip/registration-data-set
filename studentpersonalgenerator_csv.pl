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
	open F, "<$ARGV[4]";
	while(<F>){
		chomp;
		$include_schools{$_}++;
	}
	close F;
}

#open F, "<a";
open F, "<asl_schools.csv";
my $i;
while(<F>){
        $i++;
        chomp;
	s/\r//g;
        my @a = split m/,/;
        push @{$acara_schools{$a[1]}}, $a[0] if ($include_schools{$a[0]} or not %include_schools);
        push @{$deewr_schools{$a[1]}}, sprintf("%06d", $i) if ($include_schools{$a[0]} or not %include_schools);
}

close F;

my @schools;

sub yearlevel($$){
        my ($student_ordinal, $student_count) = @_;
        #return ceil(rand(4))*2+1;
        my $ret = floor($student_ordinal*4 / $student_count);
        return $ret * 2 + 3;
}


if($ARGV[4]){
	open F, "<$ARGV[4]";
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
printf qq{LocalId,SectorId,DiocesanId,OtherId,TAAId,JurisdictionId,NationalId,PlatformId,PreviousLocalId,PreviousSectorId,PreviousDiocesanId,PreviousOtherId,PreviousTAAId,PreviousJurisdictionId,PreviousNationalId,PreviousPlatformId,FamilyName,GivenName,PreferredName,MiddleName,BirthDate,Sex,CountryOfBirth,EducationSupport,FFPOS,VisaCode,IndigenousStatus,LBOTE,StudentLOTE,YearLevel,TestLevel,FTE,ClassGroup,ASLSchoolId,SchoolLocalId,LocalCampusId,MainSchoolFlag,OtherSchoolId,ReportingSchoolId,HomeSchooledStudent,Sensitive,OfflineDelivery,Parent1SchoolEducation,Parent1NonSchoolEducation,Parent1Occupation,Parent1LOTE,Parent2SchoolEducation,Parent2NonSchoolEducation,Parent2Occupation,Parent2LOTE\n};
}
my ($j);

my  ($acaraId, $localSchoolId);


for ($j=0;$j<$schoolcount;$j++){

if($ARGV[4]){
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
