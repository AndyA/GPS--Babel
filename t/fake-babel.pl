# Fake gpsbabel for testing

use strict;
use warnings;
use Data::Dumper;

$| = 1;

my %response = ();
my $name     = undef;
while ( <DATA> ) {
    chomp;
    next if /^\s*$/;
    if ( /^=(\S+)/ ) {
        $name = $1;
    }
    elsif ( defined $name ) {
        s/\\t/\t/g;
        $response{$name} .= "$_\n";
    }
}

#warn join( ' ', @ARGV ), "\n";
my $dump = shift;
my $verb = shift;
defined( my $exit = shift )
  or die "fake-babel <dump file> <verb> <exit_code> <babel args>\n";

# Dump our args where the test can find them
open my $dh, '>', $dump or die "Can't write $dump\n";
print $dh Data::Dumper->Dump( [ \@ARGV ], ['$args'] );
close $dh;

my %personality = (
    'bork' => sub {
    },
    '1.2.5' => sub {
        if ( $ARGV[0] eq '-V' ) {
            print "\nGPSBabel Version 1.2.5\n\n";
        }
    },
    '1.3.0' => sub {
        if ( $ARGV[0] eq '-V' ) {
            print "\nGPSBabel Version 1.3.0\n\n";
        }
        elsif ( $ARGV[0] eq '-%1' ) {
            print $response{filters};
        }
        elsif ( $ARGV[0] eq '-^3' ) {
            print $response{formats};
        }
    },
    '1.3.3' => sub {
        if ( $ARGV[0] eq '-V' ) {
            print "\nGPSBabel Version 1.3.3 -beta20061125\n\n";
        }
        elsif ( $ARGV[0] eq '-%1' ) {
            print $response{filters};
        }
        elsif ( $ARGV[0] eq '-^3' ) {
            print $response{formats};
        }
    },
);

my $action = $personality{$verb} or die "Verb $verb not known\n";
$action->();
exit $exit;

__DATA__

=formats

internal\trw----\txcsv\t\t? Character Separated Values\txcsv
option\txcsv\tstyle\tFull path to XCSV style file\tfile\t\t\t
option\txcsv\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\txcsv\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\txcsv\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\txcsv\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\txcsv\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\txcsv\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\txcsv\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t--rw--\talantrl\ttrl\tAlan Map500 tracklogs (.trl)\talantrl
file\trw--rw\talanwpr\twpr\tAlan Map500 waypoints and routes (.wpr)\talanwpr
internal\trw----\ttabsep\t\tAll database fields on one tab-separated line\txcsv
option\ttabsep\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\ttabsep\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\ttabsep\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\ttabsep\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\ttabsep\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\ttabsep\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\ttabsep\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
serial\trwrwrw\tbaroiq\t\tBrauniger IQ Series Barograph Download\tbaroiq
file\trw----\tcambridge\tdat\tCambridge/Winpilot glider software\txcsv
option\tcambridge\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tcambridge\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tcambridge\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tcambridge\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tcambridge\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tcambridge\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tcambridge\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\tr-r-r-\tcst\tcst\tCarteSurTable data file\tcst
file\trwr---\tcetus\tpdb\tCetus for Palm/OS\tcetus
option\tcetus\tdbname\tDatabase name\tstring\t\t\t
option\tcetus\tappendicon\tAppend icon_descr to description\tboolean\t\t\t
file\trw--rw\tcoastexp\t\tCoastalExplorer XML\tcoastexp
file\trw----\tcsv\t\tComma separated values\txcsv
option\tcsv\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tcsv\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tcsv\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tcsv\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tcsv\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tcsv\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tcsv\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trwrwrw\tcompegps\t\tCompeGPS data files (.wpt/.trk/.rte)\tcompegps
option\tcompegps\tdeficon\tDefault icon name\tstring\t\t\t
option\tcompegps\tindex\tIndex of route/track to write (if more the one in source)\tinteger\t\t1\t
option\tcompegps\tradius\tGive points (waypoints/route points) a default radius (proximity)\tfloat\t\t0\t
option\tcompegps\tsnlen\tLength of generated shortnames (default 16)\tinteger\t16\t1\t
file\trw----\tcopilot\tpdb\tCoPilot Flight Planner for Palm/OS\tcopilot
file\trwr---\tcoto\tpdb\tcotoGPS for Palm/OS\tcoto
option\tcoto\tzerocat\tName of the 'unassigned' category\tstring\t\t\t
internal\trw----\tcustom\t\tCustom "Everything" Style\txcsv
option\tcustom\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tcustom\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tcustom\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tcustom\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tcustom\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tcustom\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tcustom\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t--r---\taxim_gpb\tgpb\tDell Axim Navigation System (.gpb) file format\taxim_gpb
file\trw-wrw\tan1\tan1\tDeLorme .an1 (drawing) file\tan1
option\tan1\ttype\tType of .an1 file\tstring\t\t\t
option\tan1\troad\tRoad type changes\tstring\t\t\t
option\tan1\tnogc\tDo not add geocache data to description\tboolean\t\t\t
option\tan1\tdeficon\tSymbol to use for point data\tstring\tRed Flag\t\t
option\tan1\tcolor\tColor for lines or mapnotes\tstring\tred\t\t
option\tan1\tzoom\tZoom level to reduce points\tinteger\t\t\t
option\tan1\twpt_type\tWaypoint type\tstring\t\t\t
option\tan1\tradius\tRadius for circles\tstring\t\t\t
file\t--rw--\tgpl\tgpl\tDeLorme GPL\tgpl
file\trw----\tsaplus\t\tDeLorme Street Atlas Plus\txcsv
option\tsaplus\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tsaplus\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tsaplus\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tsaplus\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tsaplus\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tsaplus\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tsaplus\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t--r---\tsaroute\tanr\tDeLorme Street Atlas Route\tsaroute
option\tsaroute\tturns_important\tKeep turns if simplify filter is used\tboolean\t\t\t
option\tsaroute\tturns_only\tOnly read turns; skip all other points\tboolean\t\t\t
option\tsaroute\tsplit\tSplit into multiple routes at turns\tboolean\t\t\t
option\tsaroute\tcontrols\tRead control points as waypoint/route/none\tstring\tnone\t\t
option\tsaroute\ttimes\tSynthesize track times\tboolean\t\t\t
file\trw----\txmap\twpt\tDeLorme XMap HH Native .WPT\txcsv
option\txmap\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\txmap\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\txmap\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\txmap\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\txmap\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\txmap\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\txmap\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\txmap2006\ttxt\tDeLorme XMap/SAHH 2006 Native .TXT\txcsv
option\txmap2006\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\txmap2006\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\txmap2006\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\txmap2006\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\txmap2006\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\txmap2006\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\txmap2006\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\txmapwpt\t\tDeLorme XMat HH Street Atlas USA .WPT (PPC)\txcsv
option\txmapwpt\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\txmapwpt\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\txmapwpt\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\txmapwpt\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\txmapwpt\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\txmapwpt\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\txmapwpt\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\teasygps\t.loc\tEasyGPS binary format\teasygps
internal\trwrwrw\tshape\tshp\tESRI shapefile\tshape
option\tshape\tname\tIndex of name field in .dbf\tstring\t\t0\t
option\tshape\turl\tIndex of URL field in .dbf\tinteger\t\t0\t
file\t--rwrw\tigc\t\tFAI/IGC Flight Recorder Data Format\tigc
option\tigc\ttimeadj\t(integer sec or 'auto') Barograph to GPS time diff\tstring\t\t\t
file\t-w-w-w\tgpssim\tgpssim\tFranson GPSGate Simulation\tgpssim
option\tgpssim\twayptspd\tDefault speed for waypoints (knots/hr)\tfloat\t\t\t
option\tgpssim\tsplit\tSplit input into separate files\tboolean\t0\t\t
file\trw----\tfugawi\ttxt\tFugawi\txcsv
option\tfugawi\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tfugawi\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tfugawi\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tfugawi\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tfugawi\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tfugawi\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tfugawi\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgarmin301\t\tGarmin 301 Custom position and heartrate\txcsv
option\tgarmin301\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgarmin301\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgarmin301\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgarmin301\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgarmin301\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgarmin301\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgarmin301\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t--rw--\tglogbook\txml\tGarmin Logbook XML\tglogbook
file\trwrwrw\tgdb\tgdb\tGarmin MapSource - gdb\tgdb
option\tgdb\tcat\tDefault category on output (1..16)\tinteger\t\t1\t16
option\tgdb\tver\tVersion of gdb file to generate (1,2)\tinteger\t2\t1\t2
option\tgdb\tvia\tDrop route points that do not have an equivalent waypoint (hidden points)\tboolean\t\t\t
file\trwrwrw\tmapsource\tmps\tGarmin MapSource - mps\tmapsource
option\tmapsource\tsnlen\tLength of generated shortnames\tinteger\t10\t1\t
option\tmapsource\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tmapsource\tmpsverout\tVersion of mapsource file to generate (3,4,5)\tinteger\t\t\t
option\tmapsource\tmpsmergeout\tMerge output with existing file\tboolean\t\t\t
option\tmapsource\tmpsusedepth\tUse depth values on output (default is ignore)\tboolean\t\t\t
option\tmapsource\tmpsuseprox\tUse proximity values on output (default is ignore)\tboolean\t\t\t
file\trwrwrw\tgarmin_txt\ttxt\tGarmin MapSource - txt (tab delimited)\tgarmin_txt
option\tgarmin_txt\tdate\tRead/Write date format (i.e. yyyy/mm/dd)\tstring\t\t\t
option\tgarmin_txt\tdatum\tGPS datum (def. WGS 84)\tstring\tWGS 84\t\t
option\tgarmin_txt\tdist\tDistance unit [m=metric, s=statute]\tstring\tm\t\t
option\tgarmin_txt\tgrid\tWrite position using this grid.\tstring\t\t\t
option\tgarmin_txt\tprec\tPrecision of coordinates\tinteger\t3\t\t
option\tgarmin_txt\ttemp\tTemperature unit [c=Celsius, f=Fahrenheit]\tstring\tc\t\t
option\tgarmin_txt\ttime\tRead/Write time format (i.e. HH:mm:ss xx)\tstring\t\t\t
option\tgarmin_txt\tutc\tWrite timestamps with offset x to UTC time\tinteger\t\t-23\t+23
file\trwrwrw\tpcx\tpcx\tGarmin PCX5\tpcx
option\tpcx\tdeficon\tDefault icon name\tstring\tWaypoint\t\t
option\tpcx\tcartoexploreur\tWrite tracks compatible with Carto Exploreur\tboolean\t\t\t
file\trw----\tgarmin_poi\t\tGarmin POI database\txcsv
option\tgarmin_poi\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgarmin_poi\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgarmin_poi\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgarmin_poi\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgarmin_poi\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgarmin_poi\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgarmin_poi\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
serial\trwrwrw\tgarmin\t\tGarmin serial/USB protocol\tgarmin
option\tgarmin\tsnlen\tLength of generated shortnames\tinteger\t\t1\t
option\tgarmin\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgarmin\tdeficon\tDefault icon name\tstring\t\t\t
option\tgarmin\tget_posn\tReturn current position as a waypoint\tboolean\t\t\t
option\tgarmin\tpower_off\tCommand unit to power itself down\tboolean\t\t\t
option\tgarmin\tcategory\tCategory number to use for written waypoints\tinteger\t\t1\t16
file\t---w--\tgtrnctr\t\tGarmin Training Centerxml\tgtrnctr
file\trw----\tgeo\tloc\tGeocaching.com .loc\tgeo
option\tgeo\tdeficon\tDefault icon name\tstring\t\t\t
option\tgeo\tnuke_placer\tOmit Placer name\tboolean\t\t\t
file\trw----\tgcdb\tpdb\tGeocachingDB for Palm/OS\tgcdb
file\trw----\tgeonet\ttxt\tGEOnet Names Server (GNS)\txcsv
option\tgeonet\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgeonet\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgeonet\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgeonet\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgeonet\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgeonet\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgeonet\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgeoniche\tpdb\tGeoNiche .pdb\tgeoniche
option\tgeoniche\tdbname\tDatabase name (filename)\tstring\t\t\t
option\tgeoniche\tcategory\tCategory name (Cache)\tstring\t\t\t
file\trwrwrw\tkml\tkml\tGoogle Earth (Keyhole) Markup Language\tkml
option\tkml\tdeficon\tDefault icon name\tstring\t\t\t
option\tkml\tlines\tExport linestrings for tracks and routes\tboolean\t1\t\t
option\tkml\tpoints\tExport placemarks for tracks and routes\tboolean\t1\t\t
option\tkml\tline_width\tWidth of lines, in pixels\tinteger\t6\t\t
option\tkml\tline_color\tLine color, specified in hex AABBGGRR\tstring\t64eeee17\t\t
option\tkml\tfloating\tAltitudes are absolute and not clamped to ground\tboolean\t0\t\t
option\tkml\textrude\tDraw extrusion line from trackpoint to ground\tboolean\t0\t\t
option\tkml\ttrackdata\tInclude extended data for trackpoints (default = 1)\tboolean\t1\t\t
option\tkml\tunits\tUnits used when writing comments ('s'tatute or 'm'etric)\tstring\ts\t\t
option\tkml\tlabels\tDisplay labels on track and routepoints  (default = 1)\tboolean\t1\t\t
option\tkml\tmax_position_points\tRetain at most this number of position points  (0 = unlimited)\tinteger\t0\t\t
file\t--r---\tgoogle\txml\tGoogle Maps XML\tgoogle
file\trw----\tgpilots\tpdb\tGpilotS\tgpilots
option\tgpilots\tdbname\tDatabase name\tstring\t\t\t
file\trwrwrw\tgtm\tgtm\tGPS TrackMaker\tgtm
file\trw----\tarc\ttxt\tGPSBabel arc filter file\txcsv
option\tarc\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tarc\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tarc\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tarc\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tarc\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tarc\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tarc\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgpsdrive\t\tGpsDrive Format\txcsv
option\tgpsdrive\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgpsdrive\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgpsdrive\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgpsdrive\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgpsdrive\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgpsdrive\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgpsdrive\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgpsdrivetrack\t\tGpsDrive Format for Tracks\txcsv
option\tgpsdrivetrack\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgpsdrivetrack\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgpsdrivetrack\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgpsdrivetrack\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgpsdrivetrack\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgpsdrivetrack\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgpsdrivetrack\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgpsman\t\tGPSman\txcsv
option\tgpsman\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tgpsman\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tgpsman\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tgpsman\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tgpsman\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tgpsman\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tgpsman\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tgpspilot\tpdb\tGPSPilot Tracker for Palm/OS\tgpspilot
option\tgpspilot\tdbname\tDatabase name\tstring\t\t\t
file\trw----\tgpsutil\t\tgpsutil\tgpsutil
file\trwrwrw\tgpx\tgpx\tGPX XML\tgpx
option\tgpx\tsnlen\tLength of generated shortnames\tinteger\t32\t1\t
option\tgpx\tsuppresswhite\tNo whitespace in generated shortnames\tboolean\t\t\t
option\tgpx\tlogpoint\tCreate waypoints from geocache log entries\tboolean\t\t\t
option\tgpx\turlbase\tBase URL for link tag in output\tstring\t\t\t
option\tgpx\tgpxver\tTarget GPX version for output\tstring\t1.0\t\t
file\trwrw--\thiketech\tgps\tHikeTech\thiketech
file\trw----\tholux\twpo\tHolux (gm-100) .wpo Format\tholux
file\trw----\thsandv\t\tHSA Endeavour Navigator export File\thsandv
file\t-w----\thtml\thtml\tHTML Output\thtml
option\thtml\tstylesheet\tPath to HTML style sheet\tstring\t\t\t
option\thtml\tencrypt\tEncrypt hints using ROT13\tboolean\t\t\t
option\thtml\tlogs\tInclude groundspeak logs if present\tboolean\t\t\t
option\thtml\tdegformat\tDegrees output as 'ddd', 'dmm'(default) or 'dms'\tstring\tdmm\t\t
option\thtml\taltunits\tUnits for altitude (f)eet or (m)etres\tstring\tm\t\t
file\t--rw--\tignrando\trdn\tIGN Rando track files\tignrando
option\tignrando\tindex\tIndex of track to write (if more the one in source)\tinteger\t\t1\t
file\trw----\tktf2\tktf\tKartex 5 Track File\txcsv
option\tktf2\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tktf2\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tktf2\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tktf2\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tktf2\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tktf2\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tktf2\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tkwf2\tkwf\tKartex 5 Waypoint File\txcsv
option\tkwf2\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tkwf2\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tkwf2\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tkwf2\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tkwf2\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tkwf2\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tkwf2\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trwrwrw\tpsitrex\t\tKuDaTa PsiTrex text\tpsitrex
file\trwrwrw\tlowranceusr\tusr\tLowrance USR\tlowranceusr
option\tlowranceusr\tignoreicons\tIgnore event marker icons\tboolean\t\t\t
option\tlowranceusr\tmerge\t(USR output) Merge into one segmented track\tboolean\t\t\t
option\tlowranceusr\tbreak\t(USR input) Break segments into separate tracks\tboolean\t\t\t
file\t-w----\tmaggeo\tgs\tMagellan Explorist Geocaching\tmaggeo
file\trwrwrw\tmapsend\t\tMagellan Mapsend\tmapsend
option\tmapsend\ttrkver\tMapSend version TRK file to generate (3,4)\tinteger\t4\t3\t4
file\trw----\tmagnav\tpdb\tMagellan NAV Companion for Palm/OS\tmagnav
file\trwrwrw\tmagellanx\tupt\tMagellan SD files (as for eXplorist)\tmagellanx
option\tmagellanx\tdeficon\tDefault icon name\tstring\t\t\t
option\tmagellanx\tmaxcmts\tMax number of comments to write (maxcmts=200)\tinteger\t\t\t
file\trwrwrw\tmagellan\t\tMagellan SD files (as for Meridian)\tmagellan
option\tmagellan\tdeficon\tDefault icon name\tstring\t\t\t
option\tmagellan\tmaxcmts\tMax number of comments to write (maxcmts=200)\tinteger\t\t\t
serial\trwrwrw\tmagellan\t\tMagellan serial protocol\tmagellan
option\tmagellan\tdeficon\tDefault icon name\tstring\t\t\t
option\tmagellan\tmaxcmts\tMax number of comments to write (maxcmts=200)\tinteger\t\t\t
option\tmagellan\tbaud\tNumeric value of bitrate (baud=4800)\tinteger\t\t\t
option\tmagellan\tnoack\tSuppress use of handshaking in name of speed\tboolean\t\t\t
option\tmagellan\tnukewpt\tDelete all waypoints\tboolean\t\t\t
file\t----r-\ttef\txml\tMap&Guide 'TourExchangeFormat' XML\ttef
option\ttef\troutevia\tInclude only via stations in route\tboolean\t\t\t
file\tr---r-\tmag_pdb\tpdb\tMap&Guide to Palm/OS exported files (.pdb)\tmag_pdb
file\trw----\tmapconverter\ttxt\tMapopolis.com Mapconverter CSV\txcsv
option\tmapconverter\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tmapconverter\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tmapconverter\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tmapconverter\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tmapconverter\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tmapconverter\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tmapconverter\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tmxf\tmxf\tMapTech Exchange Format\txcsv
option\tmxf\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tmxf\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tmxf\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tmxf\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tmxf\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tmxf\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tmxf\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t----r-\tmsroute\taxe\tMicrosoft AutoRoute 2002 (pin/route reader)\tmsroute
file\t----r-\tmsroute\test\tMicrosoft Streets and Trips (pin/route reader)\tmsroute
file\trw----\ts_and_t\ttxt\tMicrosoft Streets and Trips 2002-2006\txcsv
option\ts_and_t\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\ts_and_t\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\ts_and_t\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\ts_and_t\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\ts_and_t\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\ts_and_t\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\ts_and_t\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t----rw\tbcr\tbcr\tMotorrad Routenplaner (Map&Guide) .bcr files\tbcr
option\tbcr\tindex\tIndex of route to write (if more the one in source)\tinteger\t\t1\t
option\tbcr\tname\tNew name for the route\tstring\t\t\t
option\tbcr\tradius\tRadius of our big earth (default 6371000 meters)\tfloat\t6371000\t\t
file\trw----\tpsp\tpsp\tMS PocketStreets 2002 Pushpin\tpsp
file\trw----\ttpg\ttpg\tNational Geographic Topo .tpg (waypoints)\ttpg
option\ttpg\tdatum\tDatum (default=NAD27)\tstring\tN. America 1927 mean\t\t
file\t--r---\ttpo2\ttpo\tNational Geographic Topo 2.x .tpo\ttpo2
file\tr-r-r-\ttpo3\ttpo\tNational Geographic Topo 3.x/4.x .tpo\ttpo3
file\tr-----\tnavicache\t\tNavicache.com XML\tnavicache
option\tnavicache\tnoretired\tSuppress retired geocaches\tboolean\t\t\t
file\t----rw\tnmn4\trte\tNavigon Mobile Navigator .rte files\tnmn4
option\tnmn4\tindex\tIndex of route to write (if more the one in source)\tinteger\t\t1\t
file\trw----\tdna\tdna\tNavitrak DNA marker format\txcsv
option\tdna\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tdna\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tdna\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tdna\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tdna\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tdna\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tdna\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\tr-----\tnetstumbler\t\tNetStumbler Summary File (text)\tnetstumbler
option\tnetstumbler\tnseicon\tNon-stealth encrypted icon name\tstring\tRed Square\t\t
option\tnetstumbler\tnsneicon\tNon-stealth non-encrypted icon name\tstring\tGreen Square\t\t
option\tnetstumbler\tseicon\tStealth encrypted icon name\tstring\tRed Diamond\t\t
option\tnetstumbler\tsneicon\tStealth non-encrypted icon name\tstring\tGreen Diamond\t\t
option\tnetstumbler\tsnmac\tShortname is MAC address\tboolean\t\t\t
file\trw----\tnima\t\tNIMA/GNIS Geographic Names File\txcsv
option\tnima\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tnima\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tnima\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tnima\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tnima\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tnima\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tnima\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trwrw--\tnmea\t\tNMEA 0183 sentences\tnmea
option\tnmea\tsnlen\tMax length of waypoint name to write\tinteger\t6\t1\t64
option\tnmea\tgprmc\tRead/write GPRMC sentences\tboolean\t1\t\t
option\tnmea\tgpgga\tRead/write GPGGA sentences\tboolean\t1\t\t
option\tnmea\tgpvtg\tRead/write GPVTG sentences\tboolean\t1\t\t
option\tnmea\tgpgsa\tRead/write GPGSA sentences\tboolean\t1\t\t
option\tnmea\tdate\tComplete date-free tracks with given date (YYYYMMDD).\tinteger\t\t\t
option\tnmea\tget_posn\tReturn current position as a waypoint\tboolean\t\t\t
option\tnmea\tpause\tDecimal seconds to pause between groups of strings\tinteger\t\t\t
option\tnmea\tbaud\tSpeed in bits per second of serial port (baud=4800)\tinteger\t\t\t
file\trwrwrw\tozi\t\tOziExplorer\tozi
option\tozi\tsnlen\tMax synthesized shortname length\tinteger\t32\t1\t
option\tozi\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tozi\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tozi\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tozi\twptfgcolor\tWaypoint foreground color\tstring\tblack\t\t
option\tozi\twptbgcolor\tWaypoint background color\tstring\tyellow\t\t
file\t-w----\tpalmdoc\tpdb\tPalmDoc Output\tpalmdoc
option\tpalmdoc\tnosep\tNo separator lines between waypoints\tboolean\t\t\t
option\tpalmdoc\tdbname\tDatabase name\tstring\t\t\t
option\tpalmdoc\tencrypt\tEncrypt hints with ROT13\tboolean\t\t\t
option\tpalmdoc\tlogs\tInclude groundspeak logs if present\tboolean\t\t\t
option\tpalmdoc\tbookmarks_short\tInclude short name in bookmarks\tboolean\t\t\t
file\trwrwrw\tpathaway\tpdb\tPathAway Database for Palm/OS\tpathaway
option\tpathaway\tdate\tRead/Write date format (i.e. DDMMYYYY)\tstring\t\t\t
option\tpathaway\tdbname\tDatabase name\tstring\t\t\t
option\tpathaway\tdeficon\tDefault icon name\tstring\t\t\t
option\tpathaway\tsnlen\tLength of generated shortnames\tinteger\t10\t1\t
file\trw----\tquovadis\tpdb\tQuovadis\tquovadis
option\tquovadis\tdbname\tDatabase name\tstring\t\t\t
file\trw--rw\traymarine\trwf\tRaymarine Waypoint File (.rwf)\traymarine
option\traymarine\tlocation\tDefault location\tstring\tNew location\t\t
file\trw----\tcup\tcup\tSee You flight analysis data\txcsv
option\tcup\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tcup\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tcup\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tcup\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tcup\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tcup\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tcup\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\trw----\tsportsim\ttxt\tSportsim track files (part of zipped .ssz files)\txcsv
option\tsportsim\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\tsportsim\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\tsportsim\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\tsportsim\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\tsportsim\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\tsportsim\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\tsportsim\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t--rwrw\tstmsdf\tsdf\tSuunto Trek Manager (STM) .sdf files\tstmsdf
option\tstmsdf\tindex\tIndex of route (if more the one in source)\tinteger\t1\t1\t
file\trwrwrw\tstmwpp\ttxt\tSuunto Trek Manager (STM) WaypointPlus files\tstmwpp
option\tstmwpp\tindex\tIndex of route/track to write (if more the one in source)\tinteger\t\t1\t
file\trw----\topenoffice\t\tTab delimited fields useful for OpenOffice, Ploticus etc.\txcsv
option\topenoffice\tsnlen\tMax synthesized shortname length\tinteger\t\t1\t
option\topenoffice\tsnwhite\tAllow whitespace synth. shortnames\tboolean\t\t\t
option\topenoffice\tsnupper\tUPPERCASE synth. shortnames\tboolean\t\t\t
option\topenoffice\tsnunique\tMake synth. shortnames unique\tboolean\t\t\t
option\topenoffice\turlbase\tBasename prepended to URL on output\tstring\t\t\t
option\topenoffice\tprefer_shortnames\tUse shortname instead of description\tboolean\t\t\t
option\topenoffice\tdatum\tGPS datum (def. WGS 84)\tstring\t\t\t
file\t-w----\ttext\ttxt\tTextual Output\ttext
option\ttext\tnosep\tSuppress separator lines between waypoints\tboolean\t\t\t
option\ttext\tencrypt\tEncrypt hints using ROT13\tboolean\t\t\t
option\ttext\tlogs\tInclude groundspeak logs if present\tboolean\t\t\t
option\ttext\tdegformat\tDegrees output as 'ddd', 'dmm'(default) or 'dms'\tstring\tdmm\t\t
option\ttext\taltunits\tUnits for altitude (f)eet or (m)etres\tstring\tm\t\t
file\trw----\ttomtom\tov2\tTomTom POI file\ttomtom
file\trw----\ttmpro\ttmpro\tTopoMapPro Places File\ttmpro
file\trwrw--\tdmtlog\ttrl\tTrackLogs digital mapping (.trl)\tdmtlog
option\tdmtlog\tindex\tIndex of track (if more the one in source)\tinteger\t1\t1\t
file\trw----\ttiger\t\tU.S. Census Bureau Tiger Mapping Service\ttiger
option\ttiger\tnolabels\tSuppress labels on generated pins\tboolean\t\t\t
option\ttiger\tgenurl\tGenerate file with lat/lon for centering map\toutfile\t\t\t
option\ttiger\tmargin\tMargin for map.  Degrees or percentage\tfloat\t15%\t\t
option\ttiger\tsnlen\tMax shortname length when used with -s\tinteger\t10\t1\t
option\ttiger\toldthresh\tDays after which points are considered old\tinteger\t14\t\t
option\ttiger\toldmarker\tMarker type for old points\tstring\tredpin\t\t
option\ttiger\tnewmarker\tMarker type for new points\tstring\tgreenpin\t\t
option\ttiger\tsuppresswhite\tSuppress whitespace in generated shortnames\tboolean\t\t\t
option\ttiger\tunfoundmarker\tMarker type for unfound points\tstring\tbluepin\t\t
option\ttiger\txpixels\tWidth in pixels of map\tinteger\t768\t\t
option\ttiger\typixels\tHeight in pixels of map\tinteger\t768\t\t
option\ttiger\ticonismarker\tThe icon description is already the marker\tboolean\t\t\t
file\tr-----\tunicsv\t\tUniversal csv with field structure in first line\tunicsv
file\t-w----\tvcard\tvcf\tVcard Output (for iPod)\tvcard
option\tvcard\tencrypt\tEncrypt hints using ROT13\tboolean\t\t\t
file\trwrwrw\tvitosmt\tsmt\tVito Navigator II tracks\tvitosmt
file\tr-----\twfff\txml\tWiFiFoFum 2.0 for PocketPC XML\twfff
option\twfff\taicicon\tInfrastructure closed icon name\tstring\tRed Square\t\t
option\twfff\taioicon\tInfrastructure open icon name\tstring\tGreen Square\t\t
option\twfff\tahcicon\tAd-hoc closed icon name\tstring\tRed Diamond\t\t
option\twfff\tahoicon\tAd-hoc open icon name\tstring\tGreen Diamond\t\t
option\twfff\tsnmac\tShortname is MAC address\tboolean\t\t\t
file\t--r---\twbt-bin\t\tWintec WBT-100/200 Binary file format\twbt-bin
serial\t--r---\twbt\tbin\tWintec WBT-100/200 GPS Download\twbt
option\twbt\terase\tErase device data after download\tboolean\t0\t\t
file\tr-----\tyahoo\t\tYahoo Geocode API data\tyahoo
option\tyahoo\taddrsep\tString to separate concatenated address fields (default=", ")\tstring\t, \t\t

=filters

polygon\tInclude Only Points Inside Polygon
option\tpolygon\tfile\tFile containing vertices of polygon\tfile\t\t\t
option\tpolygon\texclude\tExclude points inside the polygon\tboolean\t\t\t
arc\tInclude Only Points Within Distance of Arc
option\tarc\tfile\tFile containing vertices of arc\tfile\t\t\t
option\tarc\tdistance\tMaximum distance from arc\tfloat\t\t\t
option\tarc\texclude\tExclude points close to the arc\tboolean\t\t\t
option\tarc\tpoints\tUse distance from vertices not lines\tboolean\t\t\t
radius\tInclude Only Points Within Radius
option\tradius\tlat\tLatitude for center point (D.DDDDD)\tfloat\t\t\t
option\tradius\tlon\tLongitude for center point (D.DDDDD)\tfloat\t\t\t
option\tradius\tdistance\tMaximum distance from center\tfloat\t\t\t
option\tradius\texclude\tExclude points close to center\tboolean\t\t\t
option\tradius\tnosort\tInhibit sort by distance to center\tboolean\t\t\t
option\tradius\tmaxcount\tOutput no more than this number of points\tinteger\t\t1\t
option\tradius\tasroute\tPut resulting waypoints in route of this name\tstring\t\t\t
interpolate\tInterpolate between trackpoints
option\tinterpolate\ttime\tTime interval in seconds\tinteger\t\t0\t
option\tinterpolate\tdistance\tDistance interval in miles or kilometers\tstring\t\t\t
option\tinterpolate\troute\tInterpolate routes instead\tboolean\t\t\t
track\tManipulate track lists
option\ttrack\tmove\tCorrect trackpoint timestamps by a delta\tstring\t\t\t
option\ttrack\tpack\tPack all tracks into one\tboolean\t\t\t
option\ttrack\tsplit\tSplit by date or time interval (see README)\tstring\t\t\t
option\ttrack\tsdistance\tSplit by distance\tstring\t\t\t
option\ttrack\tmerge\tMerge multiple tracks for the same way\tstring\t\t\t
option\ttrack\tname\tUse only track(s) where title matches given name\tstring\t\t\t
option\ttrack\tstart\tUse only track points after this timestamp\tinteger\t\t\t
option\ttrack\tstop\tUse only track points before this timestamp\tinteger\t\t\t
option\ttrack\ttitle\tBasic title for new track(s)\tstring\t\t\t
option\ttrack\tfix\tSynthesize GPS fixes (PPS, DGPS, 3D, 2D, NONE)\tstring\t\t\t
option\ttrack\tcourse\tSynthesize course\tboolean\t\t\t
option\ttrack\tspeed\tSynthesize speed\tboolean\t\t\t
sort\tRearrange waypoints by resorting
option\tsort\tgcid\tSort by numeric geocache ID\tboolean\t\t\t
option\tsort\tshortname\tSort by waypoint short name\tboolean\t\t\t
option\tsort\tdescription\tSort by waypoint description\tboolean\t\t\t
option\tsort\ttime\tSort by time\tboolean\t\t\t
nuketypes\tRemove all waypoints, tracks, or routes
option\tnuketypes\twaypoints\tRemove all waypoints from data stream\tboolean\t0\t\t
option\tnuketypes\ttracks\tRemove all tracks from data stream\tboolean\t0\t\t
option\tnuketypes\troutes\tRemove all routes from data stream\tboolean\t0\t\t
duplicate\tRemove Duplicates
option\tduplicate\tshortname\tSuppress duplicate waypoints based on name\tboolean\t\t\t
option\tduplicate\tlocation\tSuppress duplicate waypoint based on coords\tboolean\t\t\t
option\tduplicate\tall\tSuppress all instances of duplicates\tboolean\t\t\t
option\tduplicate\tcorrect\tUse coords from duplicate points\tboolean\t\t\t
position\tRemove Points Within Distance
option\tposition\tdistance\tMaximum positional distance\tfloat\t\t\t
option\tposition\tall\tSuppress all points close to other points\tboolean\t\t\t
discard\tRemove unreliable points with high hdop or vdop
option\tdiscard\thdop\tSuppress waypoints with higher hdop\tfloat\t-1.0\t\t
option\tdiscard\tvdop\tSuppress waypoints with higher vdop\tfloat\t-1.0\t\t
option\tdiscard\thdopandvdop\tLink hdop and vdop supression with AND\tboolean\t\t\t
reverse\tReverse stops within routes
stack\tSave and restore waypoint lists
option\tstack\tpush\tPush waypoint list onto stack\tboolean\t\t\t
option\tstack\tpop\tPop waypoint list from stack\tboolean\t\t\t
option\tstack\tswap\tSwap waypoint list with <depth> item on stack\tboolean\t\t\t
option\tstack\tcopy\t(push) Copy waypoint list\tboolean\t\t\t
option\tstack\tappend\t(pop) Append list\tboolean\t\t\t
option\tstack\tdiscard\t(pop) Discard top of stack\tboolean\t\t\t
option\tstack\treplace\t(pop) Replace list (default)\tboolean\t\t\t
option\tstack\tdepth\t(swap) Item to use (default=1)\tinteger\t\t0\t
simplify\tSimplify routes
option\tsimplify\tcount\tMaximum number of points in route\tinteger\t\t1\t
option\tsimplify\terror\tMaximum error\tstring\t\t0\t
option\tsimplify\tcrosstrack\tUse cross-track error (default)\tboolean\t\t\t
option\tsimplify\tlength\tUse arclength error\tboolean\t\t\t
transform\tTransform waypoints into a route, tracks into routes, ...
option\ttransform\twpt\tTransform track(s) or route(s) into waypoint(s) [R/T]\tstring\t\t\t
option\ttransform\trte\tTransform waypoint(s) or track(s) into route(s) [W/T]\tstring\t\t\t
option\ttransform\ttrk\tTransform waypoint(s) or route(s) into tracks(s) [W/R]\tstring\t\t\t
option\ttransform\tdel\tDelete source data after transformation\tboolean\tN\t\t
