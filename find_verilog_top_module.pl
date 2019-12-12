use Getopt::Long;
use Verilog::Netlist;
use Verilog::Getopt;


die "-U- 
$0 -v_folder=<folder with all v files> 
" if ! @ARGV;

my ($v_folder);
GetOptions("v_folder=s"=>\$v_folder);
die "-F- no -v_folder \n"   if ! defined $v_folder;
#not working: you will get \n instead of new line...

# Setup options so files can be found
my $opt = new Verilog::Getopt;
$opt->parameter("+incdir+verilog","-y","verilog",);

# Prepare netlist
my $v_files = new Verilog::Netlist (options => $opt,link_read_nonfatal=>0,);
#foreach my $file ('./all.sv','../another.v') {
$v_folder=$v_folder."./*v";
foreach my $file (glob( $v_folder)) {
	$v_files->read_file (filename=>$file);
}
$v_files->link();

foreach my $mod ($v_files->top_modules_sorted) {printf $mod->name."\n";}

