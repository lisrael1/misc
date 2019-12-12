#run like this:
#examples:
#              perl <script_name>.pl -v_folder=./

use Getopt::Long;
use Verilog::Netlist;
use Verilog::Getopt;

die "-U- 
$0 -v_folder=<folder with all v files> 
" if ! @ARGV;

my ($v_folder);
GetOptions("v_folder=s"=>\$v_folder);
die "-F- no -v_folder \n"   if ! defined $v_folder;

# Setup options so files can be found
my $opt = new Verilog::Getopt;
$opt->parameter("+incdir+verilog","-y","verilog",);

# Prepare netlist
my $v_files = new Verilog::Netlist (options => $opt,link_read_nonfatal=>1,);
#foreach my $file ('./all.sv','../another.v') {
$v_folder=$v_folder."./*v";
foreach my $file (glob( $v_folder)) {
	$v_files->read_file (filename=>$file);
}

# Read in any sub-modules
$v_files->link();
#$v_files->lint();  # Optional, see docs; probably not wanted
#$v_files->exit_if_error();

my $a=$v_files->top_modules_sorted;
if ($a eq 0){print "no files, exit\n";exit();}

foreach my $mod ($v_files->top_modules_sorted) {
        print_hierarchy_full_instance_name ($mod, , "", "", "top");
}

sub print_hierarchy_full_instance_name {
	my $mod = shift;
	my $instance_full_path = shift;
	my $module_full_path = shift;
	my $cellname = shift;
	$mod_name=$mod->name;
        $instance_full_path .= ".$cellname";
        $module_full_path .= ".$mod_name";
        foreach $net ($mod->nets)
        	{printf ($indent." %s : %s -> %s\n", $instance_full_path, $module_full_path, $net->name);}
	my $last_sub_cell;
	foreach my $cell ($mod->cells_sorted) {
                $last_sub_cell=$cell->submodname;
                if ($cell->submod)
                        {print_hierarchy_full_instance_name ($cell->submod, $instance_full_path, $module_full_path, $cell->name);}
	}
}
