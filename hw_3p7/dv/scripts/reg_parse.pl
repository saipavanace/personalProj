#!/usr/bin/env perl
use strict;
use warnings;

sub usage 
{
    print "\nUsage: reg_parse.pl <ProjectFile>\n";
    print "       reg_parse.pl -help (for help)\n\n";	

    print "Prepare all the csv file in one folder, source the main register file as argument\n\n";
}

if (@ARGV == 0 or @ARGV == 1 and $ARGV[0] =~ /-help/)
{ 
    usage();
    exit(0);
}

my $proj_file = $ARGV[0];
my $work_dir;
my $output_file;
my $num_cnt = 0;
my $bit_cnt = 0;
my @RstVal;

if ($proj_file =~ m/(\/.*\/)(.*).csv/)
{
    $work_dir = $1;
    $output_file = $2;
    $output_file =~ s/\W/_/g;
}
else
{
    die ("The format of ProjectFile argument should be </FilePath/FileName>\n");
}

#######################################
# printing main structure
#######################################

open (IN, "<", "$proj_file") or die (">>> Check file path, Cannot find file in it.");
open (OUT, ">", "$work_dir/$output_file.xml") or die (">>> Check file path, it doesn't exist there.");
print OUT '<?xml version="1.0" encoding="UTF-8"?>';
print OUT "\n";
print OUT '<spirit:component xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:spirit="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009" xmlns:artve="http://www.arteris.com" xsi:schemaLocation="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009 http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009/index.xsd">';
print OUT "\n    <spirit:vendor>arteris.com</spirit:vendor>\n";
print OUT "    <spirit:library>FLEXNOC</spirit:library>\n";
print OUT "    <spirit:name>ccti_struct</spirit:name>\n";
print OUT "    <spirit:version>3.1.1-SP7</spirit:version>\n";
print OUT "    <spirit:memoryMaps>\n";
print OUT "        <spirit:memoryMap>\n";
print OUT "            <spirit:name>concerto_registers</spirit:name>\n";

my $reg_cnt;
while (<IN>)
{
    # print addressBlock
    if ($_ =~ /.+,,,,,,,,/)
    { 
	print_addrBlock1($_);
	$reg_cnt = 0;
    }
    
    # print register
    if ($_ =~ /(.*),(.*),(0x.*),(0x.*),0x(.*),0x.*,.*,.*,/)
    {
        $reg_cnt++;
        $num_cnt++;
	if ($reg_cnt == 1)
        {
	    print_addrBlock2($3, $4);
	}
	print OUT "                <spirit:register>\n";
	print OUT "                    <spirit:name>$1</spirit:name>\n";
	my $dec = hex($5) * 4;
	my $hex = sprintf("0x%03X" ,$dec);
	print OUT "                    <spirit:addressOffset>$hex</spirit:addressOffset>\n";
	print OUT "                    <spirit:size>32</spirit:size>\n";
        #print "$1\n";
 
	# print reset block and field block
	if (length($2) != 0)
	{
	    print_reset($2); 
	    print_field($2);
	}
	print OUT "                </spirit:register>\n";
    }
	 
}
print OUT "            </spirit:addressBlock>\n";
print OUT "        </spirit:memoryMap>\n";
print OUT "    </spirit:memoryMaps>\n";
print OUT "</spirit:component>\n";
close (IN);
close (OUT);
print "\n>>> Total Number of registers: $num_cnt\n";

#######################################
# Subroutins
#######################################

# print address block
sub print_addrBlock1 
{
    if ($_ =~ /Coherent Agent Interface Unit/) 
    {
	print OUT "            <spirit:addressBlock>\n";
	print OUT "                <spirit:name>Coherent_Agent_Interface_Unit</spirit:name>\n"; 
    }
    elsif ($_ =~ /Non-coherent Bridge Unit/)
    {
	print OUT "            </spirit:addressBlock>\n";
	print OUT "            <spirit:addressBlock>\n";
	print OUT "                <spirit:name>Non_coherent_Bridge_Unit</spirit:name>\n";
    }
    elsif ($_ =~ /Directory Unit/)
    {
	print OUT "            </spirit:addressBlock>\n";
	print OUT "            <spirit:addressBlock>\n";
	print OUT "                <spirit:name>Directory_Unit</spirit:name>\n"; 
    }
    elsif ($_ =~ /Coherent Memory Interface Unit/)
    {
	print OUT "            </spirit:addressBlock>\n";
	print OUT "            <spirit:addressBlock>\n";
	print OUT "                <spirit:name>Coherent_Memory_Interface_Unit</spirit:name>\n"; 
    }
    elsif ($_ =~ /Coherent Subsystem,+/)
    {
	print OUT "            </spirit:addressBlock>\n";
	print OUT "            <spirit:addressBlock>\n";
	print OUT "                <spirit:name>Coherent_Subsystem</spirit:name>\n"; 
    }
}

sub print_addrBlock2
{
    my ($PageLo, $PageHi) = @_;
    print OUT '                <spirit:baseAddress spirit:prompt="Base Address:" spirit:format="long">';
    print OUT "$PageLo";
    print OUT "</spirit:baseAddress>\n";
    print OUT "                <spirit:range>$PageHi</spirit:range>\n";
    print OUT "                <spirit:width>32</spirit:width>\n";
}


# Reset Value Calculation
sub print_reset
{
	my $HexDigit;
	my $HexStr = 'E';
	Forge($2);

	# convert & concatenate
	for (my $i = 0; $i < 32; $i = $i + 4){
		if (($RstVal[$i] =~ /\d/) and ($RstVal[$i+1] =~ /\d/) and ($RstVal[$i+2] =~ /\d/) and ($RstVal[$i+3] =~ /\d/)){
			$HexDigit = BiToHex($RstVal[$i], $RstVal[$i+1], $RstVal[$i+2], $RstVal[$i+3]);
		}
		else {
			$HexDigit = 'X';	
		}
		$HexStr = $HexDigit.$HexStr;			
	}

	if ($HexStr =~ /XXXXXXXXE/){
		$HexStr = 'XxXXXXXXXX';
	}
	else {
		$HexStr =~ s/E$//;
		$HexStr = '0x'.$HexStr;
	}
	#print "The Hex Value is : $HexStr\n";

	print OUT "                    <spirit:reset>\n";
	print OUT "                        <spirit:value>$HexStr</spirit:value>\n";
	print OUT "                        <spirit:mask>0xFFFFFFFF</spirit:mask>\n";
	print OUT "                    </spirit:reset>\n";
	close (IH)
}

sub BiToHex {
	my ($bit1, $bit2, $bit3, $bit4) = @_;
	my $Dec;
	my $Hex;
	$Dec = $bit4*8 + $bit3*4 + $bit2*2 + $bit1*1;	
	$Hex = sprintf ("%01X", $Dec);
	return ($Hex);
}

sub HexToBi {
	my ($HiBit, $LowBit, $HexVal) =  @_;
	my $Dec = hex($HexVal);
	my @BinVal;
	my $bit_taken = 0;
	#print "Width : $Width \nLSB   : $LowBit \nHex   : $HexVal\n\n";
	
	if ($Dec == 0){
		for (my $i = $LowBit; $i <= $HiBit; $i++){
			$RstVal[$i] = 0;
		}
	}
	else{	
		while ($Dec >= 1){
			$BinVal[$bit_taken] = $Dec%2;	
			$Dec = $Dec - $Dec%2;
			$Dec = $Dec/2;	
			$bit_taken++;
		}
		#print "bit taken : $bit_taken\n";
		for (my $i = $LowBit; $i <= $HiBit; $i++){
			if (($i - $LowBit) < $bit_taken){
				$RstVal[$i] = $BinVal[$i-$LowBit];
			}
			else {
				$RstVal[$i] = 0;
			}
		}
	}	
}

sub Forge {	
	#print "$2.csv\n";
	open (IH, "<", "$work_dir/$2.csv") or die (">>> Check file path, $2 doesn't exist there.");
	while (<IH>)
	{
		$_ =~ s/[\n\r]/,\n/g;
		if ($_ =~ /(.*),(\d+),(\d+),(\d+),CFG,(.*),(.*),(.*),/){
			for (my $i = $4; $i <= $3; $i++){
				$RstVal[$i] = 0;
			}
		}
		if ($_ =~ /(.*),(\d+),(\d+),(\d+),Xx(.*),(.*),(.*),(.*),/){
			for (my $i = $4; $i <= $3; $i++){
				$RstVal[$i] = 'X';
			}
		}
		if ($_ =~ /(.*),(\d+),(\d+),(\d+),0x(.*),(.*),(.*),(.*),/){	
			HexToBi($3, $4, $5);	
		}	
	}
	#print "Reset Value : @RstVal\n";
	close (IH);
}

# print field
sub print_field
{
    open (IH, "<", "$work_dir/$2.csv");
    my $RsvdCnt = 0;
    while (<IH>)
    {
        my $RsvdName = 0;
	$_ =~ s/[\n\r]/,\n/g;
      
	    if ($_ =~ /(.*),(\d+),(\d+),(\d+),(.*),(.*),(.*),(.*),/)
	    {
            #printf ("%20s%5s%5s%50s\n", $1, $2, $4, $8);
            print OUT "                    <spirit:field>\n";
            if ($1 ne 'Rsvd'){	
                print OUT "                        <spirit:name>$1</spirit:name>\n";            
            }
            elsif ($1 eq 'Rsvd') {	
                $RsvdCnt = $RsvdCnt + 1;
                $RsvdName = $1.$RsvdCnt; 
                print OUT "                        <spirit:name>$RsvdName</spirit:name>\n";
            } 
            print OUT "                        <spirit:description>$8</spirit:description>\n";
            print OUT "                        <spirit:bitOffset>$4</spirit:bitOffset>\n";
            print OUT "                        <spirit:bitWidth>$2</spirit:bitWidth>\n";
            if ($6 =~ /RO/)     { print OUT "                        <spirit:access>read-only</spirit:access>\n"; }
            elsif ($6 =~ /RW$/) { print OUT "                        <spirit:access>read-write</spirit:access>\n"; }
            elsif ($6 =~ /RW1C/){ print OUT "                        <spirit:access>read-write</spirit:access>\n"; 
                                  print OUT "                        <spirit:modifiedWriteValue>oneToClear</spirit:modifiedWriteValue>\n"; }
            print OUT "                    </spirit:field>\n";   	   
	    }
    }
    close (IH);
}

print ">>> Parsing register information is done.\n";

#######################################
# Sanity Check
#######################################

my $reg_complete = 1;
open (IN, "<", "$output_file.xml");
    while (<IN>)
    {
        if ($_ =~ /<spirit:register>/)
        {
            if ($bit_cnt == 32)
            {
                $reg_complete = $reg_complete and 1;
            }
            else 
            {
                $reg_complete = $reg_complete and 0;
            }
            $num_cnt--;
            $bit_cnt = 0;
        }
	if ($_ =~ /<spirit:bitWidth>(\d+)</)
        {
            $bit_cnt = $bit_cnt + $1;   
        } 
    }
close(IN);

if ($num_cnt == 0 and $reg_complete == 1){
    print ">>> SANITY CHECK PASSED!\n\n";
}

