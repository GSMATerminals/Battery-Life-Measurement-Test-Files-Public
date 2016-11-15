#!/usr/bin/env perl

# Copyright (c) 2007-2013 Stefano Sabatini + Modified by Cyril B.
#
# This file is part of FFmpeg.
#
# FFmpeg is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# FFmpeg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with FFmpeg; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

=head1 NAME

plotframes - Plot video frame sizes using ffprobe and gnuplot

=head1 SYNOPSIS

plotframes [I<options>] [I<input>]

=head1 DESCRIPTION

plotframes reads a multimedia files with ffprobe, and plots the
collected video sizes with gnuplot.

=head1 OPTIONS

=over 4

=item B<--input|-i> I<infile>

Specify multimedia file to read. This is the file passed to the
ffprobe command. If not specified it is the first argument passed to
the script.

=item B<--help|--usage|-h|-?>

Print a brief help message and exit.

=item B<--manpage|-m>

Print the man page.

=item B<--output|-o> I<outfile>

Set the name of the output used by gnuplot. If not specified no output
is created. Must be used in conjunction with the B<terminal> option.

=item B<--stream|--s> I<stream_specifier>

Specify stream. The value must be a string containing a stream
specifier. Default value is "v".

=item B<--terminal|-t> I<terminal>

Set the name of the terminal used by gnuplot. By default it is
"x11". Must be used in conjunction with the B<output> option. Check
the gnuplot manual for the valid values.

=back

=cut

=head1 SEE ALSO

ffprobe(1), gnuplot(1)

=cut

use warnings;
use strict;

# Add this to use local JSON.pm
use lib "./lib";

use File::Temp;
use JSON -support_by_pp;
use Getopt::Long;
use Pod::Usage;
use POSIX;
use Switch;

my $input = $ARGV[0];
my $stream_specifier = "v";
my $gnuplot_terminal = "x11";
my $gnuplot_output;

GetOptions (
    'input|i=s'      => \$input,
    'help|usage|?|h' => sub { pod2usage ( { -verbose => 1, -exitval => 0 }) },
    'manpage|m'      => sub { pod2usage ( { -verbose => 2, -exitval => 0 }) },
    'stream|s=s'     => \$stream_specifier,
    'terminal|t=s'   => \$gnuplot_terminal,
    'output|o=s'     => \$gnuplot_output,
    ) or pod2usage( { -message=> "Parsing error", -verbose => 1, -exitval => 1 });

die "You must specify an input file\n" unless $input;

my $fps = 0;
$fps = `ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 $input 2>&1`;
if ($fps) {
#	$fps =~ m/([0-9]+\.*[0-9]*)\//;
	$fps =~ s/\n//;
	$fps = sprintf "%.2f", eval ($fps);
	$fps=29.97;
	switch($fps){
	   case "29.97"	{ $fps = 30; }
	   case "30"	{ $fps = 30; }
	   case "59.94"	{ $fps = 60; }
	   case "60"	{ $fps = 60; }
	   else			{ die "Unknown fps (${fps}) on file $input"; }
	}
	print "Found video at $fps fps\n";
}
else {
	die "ffprobe command failed to extract fps $input - Is ffprobe in the path?";
}

my $avgBitRate = 0;
$avgBitRate = `ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 $input 2>&1`;
if ($avgBitRate) {
	$avgBitRate =~ m/([0-9]+)/;
	$avgBitRate =~ s/\n//;
	$avgBitRate = int($avgBitRate / 1000);
	print "Found video bit rate: $avgBitRate kbit/s\n";
}
else {
	die "ffprobe command failed to extract average bit rate $input - Is ffprobe in the path?";
}

# fetch data
my @cmd = (qw{ffprobe -show_entries frame -select_streams}, $stream_specifier, "-of", "json", $input);
print STDERR "Executing command: @cmd\n";
my $json_struct;
{
    open(FH, "-|", @cmd) or die "ffprobe command failed: $!\n";
    local $/;
    my $json_text = <FH>;
    close FH;
    die "ffprobe command failed" if $?;
    eval { $json_struct = decode_json($json_text); };
    die "JSON parsing error: $@\n" if $@;
}

# collect and print frame statistics per pict_type
my $smoothPeriod = 30;

my %stats;
my $frames = $json_struct->{frames};
my $frame_count = 0;
my $brType1="Bit rate (1s period)";
my $totalBr = 0;

my $brType2="Average Bit Rate";
my $totalBrAvg = 0;

my $brType3="Bit rate (${smoothPeriod}s period)";
my $lastWindowStart = 0;
my $totalBrSmoothed = 0;


foreach my $frame (@{$frames}) {
    my $type = $frame->{pict_type};
    $frame->{count} = $frame_count++;
    if (not $stats{$type}) {
        $stats{$type}->{tmpfile} = File::Temp->new(SUFFIX => '.dat');
        my $fn = $stats{$type}->{tmpfile}->filename;
        open($stats{$type}->{fh}, ">", $fn) or die "Can't open $fn";
    }
    if (not $stats{"$brType1"}) {
        $stats{"$brType1"}->{tmpfile} = File::Temp->new(SUFFIX => '.dat');
        my $fn = $stats{"$brType1"}->{tmpfile}->filename;
        open($stats{"$brType1"}->{fh}, ">", $fn) or die "Can't open $fn";
	print { $stats{"$brType1"}->{fh} } "$frame->{count} ", $frame->{pkt_size} * 8 / 1000, "\n";
    }
    if (not $stats{"$brType2"}) {
        $stats{"$brType2"}->{tmpfile} = File::Temp->new(SUFFIX => '.dat');
        my $fn = $stats{"$brType2"}->{tmpfile}->filename;
        open($stats{"$brType2"}->{fh}, ">", $fn) or die "Can't open $fn";
    	print { $stats{"$brType2"}->{fh} } "$frame->{count} ", $frame->{pkt_size} * 8 / 1000, "\n";
    }
    if (not $stats{"$brType3"}) {
        $stats{"$brType3"}->{tmpfile} = File::Temp->new(SUFFIX => '.dat');
        my $fn = $stats{"$brType3"}->{tmpfile}->filename;
        open($stats{"$brType3"}->{fh}, ">", $fn) or die "Can't open $fn";
 	print { $stats{"$brType3"}->{fh} } "$frame->{count} ", $frame->{pkt_size} * 8 / 1000, "\n";
    }

    print { $stats{$type}->{fh} }
        "$frame->{count} ", $frame->{pkt_size} * 8 / 1000, "\n";

    # Compute bit rate of last second
    if (($frame_count % $fps) == 0) {
		$totalBr += $frame->{pkt_size} * 8 / 1000;
		print { $stats{"$brType1"}->{fh} } "$frame->{count} ", $totalBr, "\n";

		$totalBrAvg += $totalBr;
	    	print { $stats{"$brType2"}->{fh} } "$frame->{count} ", $fps*$totalBrAvg/$frame->{count}, "\n";
		$totalBr = 0;

		$totalBrSmoothed += $frame->{pkt_size} * 8 / 1000;
		# Smooth on longer period
	    	if (($frame_count % ($fps*$smoothPeriod)) == 0) {
	    		print { $stats{"$brType3"}->{fh} } "$frame->{count} ", $totalBrSmoothed/$smoothPeriod, "\n";
			$totalBrSmoothed = 0;
			$lastWindowStart = $frame->{count};
		}

	}
	else {
		$totalBr += $frame->{pkt_size} * 8 / 1000;
		$totalBrSmoothed += $frame->{pkt_size} * 8 / 1000;
	}
}

foreach (keys %stats) { close $stats{$_}->{fh}; }

# write gnuplot script
my %type_color_map = (
    "I" => "red",
    "P" => "green",
    "B" => "blue",
    "$brType1" => "blue",
    "$brType2" => "red",
    "$brType3" => "green"
    );

my $gnuplot_script_tmpfile = File::Temp->new(SUFFIX => '.gnuplot');
my $fn = $gnuplot_script_tmpfile->filename;
open(FH, ">", $fn) or die "Couldn't open $fn: $!";
my $outputTmpString1 = "";
my $outputTmpString2 = "";


my $outputString = "";
$outputString .= "set termoption enhanced\n";
$outputString .= "set encoding utf8\n";
if ($gnuplot_output) {
	$outputString .= "set terminal png size 1920,1080\n";
	$outputString .= "set output \"$gnuplot_output\"\n";
}
else {
	$outputString .= "set terminal \"$gnuplot_terminal\"\n";
}
$outputString .= "set xlabel \"Frame number\"\n";
$outputString .= "set multiplot layout 2,1\n";

my $sep1 = "";
my $sep2 = "";

foreach my $type (keys %stats) {
    my $fn = $stats{$type}->{tmpfile}->filename;
    switch($type){
        case "$brType1"	{
		$outputTmpString2 .= "$sep2\"$fn\" title \"$type\" with line";
		$outputTmpString2 .= " linecolor rgb \"$type_color_map{$type}\"" if $type_color_map{$type};
		$sep2 = ", ";
	}
        case "$brType2"	{
		$outputTmpString2 .= "$sep2\"$fn\" title \"$type\" with line lw 3";
		$outputTmpString2 .= " linecolor rgb \"$type_color_map{$type}\"" if $type_color_map{$type};
		$sep2 = ", ";
	}
        case "$brType3"	{
#		$outputTmpString2 .= "$sep2\"$fn\" title \"$type\" with line smooth csplines lw 3";
		$outputTmpString2 .= "$sep2\"$fn\" title \"$type\" smooth frequency with fsteps lw 3";
		$outputTmpString2 .= " linecolor rgb \"$type_color_map{$type}\"" if $type_color_map{$type};
		$sep2 = ", ";
	}
	else	{
		$outputTmpString1 .= "$sep1\"$fn\" title \"$type frames\" with impulses";
		$outputTmpString1 .= " linecolor rgb \"$type_color_map{$type}\"" if $type_color_map{$type};
		$sep1 = ", ";
	}
    }
}

$outputString .= "
set title \"Video throughput ($avgBitRate kbit/s)\"
set ylabel \"Video throughput (Kbit/s)\"
set grid
";
$outputString .= "plot $outputTmpString2\n";

$outputString .= "
set title \"Video frames sizes\"
set ylabel \"Video frames size (Kbit)\"
set grid
";
$outputString .= "plot $outputTmpString1\n";
$outputString .= "unset multiplot\n";
$outputString .= "\n";
print FH $outputString;
close FH;


# launch gnuplot with the generated script
#system ("cat", $gnuplot_script_tmpfile->filename);
system ("gnuplot", "--persist", $gnuplot_script_tmpfile->filename);
