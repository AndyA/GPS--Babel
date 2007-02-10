use strict;
use warnings;
use GPS::Babel;
use File::Spec;
use Data::Dumper;
use Test::More;

my @tests;

BEGIN {
    my $ref_info = {
        'formats' => {
            'google' => {
                'nmodes' => 8,
                'parent' => 'google',
                'desc'   => 'Google Maps XML',
                'modes'  => '--r---',
                'ext'    => 'xml'
            },
            'nmn4' => {
                'nmodes'  => 3,
                'parent'  => 'nmn4',
                'options' => {
                    'index' => {
                        'min' => '1',
                        'desc' =>
                          'Index of route to write (if more the one in source)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Navigon Mobile Navigator .rte files',
                'modes' => '----rw',
                'ext'   => 'rte'
            },
            'tpg' => {
                'nmodes'  => 48,
                'parent'  => 'tpg',
                'options' => {
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'Datum (default=NAD27)',
                        'max'     => '',
                        'default' => 'N. America 1927 mean',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'National Geographic Topo .tpg (waypoints)',
                'modes' => 'rw----',
                'ext'   => 'tpg'
            },
            'mxf' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'MapTech Exchange Format',
                'modes' => 'rw----',
                'ext'   => 'mxf'
            },
            'igc' => {
                'nmodes'  => 15,
                'parent'  => 'igc',
                'options' => {
                    'timeadj' => {
                        'min' => '',
                        'desc' =>
                          '(integer sec or \'auto\') Barograph to GPS time diff',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'FAI/IGC Flight Recorder Data Format',
                'modes' => '--rwrw'
            },
            'magellan' => {
                'nmodes'  => 63,
                'parent'  => 'magellan',
                'options' => {
                    'nukewpt' => {
                        'min'     => '',
                        'desc'    => 'Delete all waypoints',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'noack' => {
                        'min' => '',
                        'desc' =>
                          'Suppress use of handshaking in name of speed',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'baud' => {
                        'min'     => '',
                        'desc'    => 'Numeric value of bitrate (baud=4800)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'maxcmts' => {
                        'min' => '',
                        'desc' =>
                          'Max number of comments to write (maxcmts=200)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Magellan SD files (as for Meridian)',
                'modes' => 'rwrwrw'
            },
            'lowranceusr' => {
                'nmodes'  => 63,
                'parent'  => 'lowranceusr',
                'options' => {
                    'merge' => {
                        'min'  => '',
                        'desc' => '(USR output) Merge into one segmented track',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'ignoreicons' => {
                        'min'     => '',
                        'desc'    => 'Ignore event marker icons',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'break' => {
                        'min' => '',
                        'desc' =>
                          '(USR input) Break segments into separate tracks',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Lowrance USR',
                'modes' => 'rwrwrw',
                'ext'   => 'usr'
            },
            'dmtlog' => {
                'nmodes'  => 60,
                'parent'  => 'dmtlog',
                'options' => {
                    'index' => {
                        'min'  => '1',
                        'desc' => 'Index of track (if more the one in source)',
                        'max'  => '',
                        'default' => '1',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'TrackLogs digital mapping (.trl)',
                'modes' => 'rwrw--',
                'ext'   => 'trl'
            },
            'garmin' => {
                'options' => {
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'power_off' => {
                        'min'     => '',
                        'desc'    => 'Command unit to power itself down',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'category' => {
                        'min' => '1',
                        'desc' =>
                          'Category number to use for written waypoints',
                        'max'     => '16',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Length of generated shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'get_posn' => {
                        'min'     => '',
                        'desc'    => 'Return current position as a waypoint',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                }
            },
            'bcr' => {
                'nmodes'  => 3,
                'parent'  => 'bcr',
                'options' => {
                    'index' => {
                        'min' => '1',
                        'desc' =>
                          'Index of route to write (if more the one in source)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'radius' => {
                        'min' => '',
                        'desc' =>
                          'Radius of our big earth (default 6371000 meters)',
                        'max'     => '',
                        'default' => '6371000',
                        'type'    => 'float'
                    },
                    'name' => {
                        'min'     => '',
                        'desc'    => 'New name for the route',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Motorrad Routenplaner (Map&Guide) .bcr files',
                'modes' => '----rw',
                'ext'   => 'bcr'
            },
            'msroute' => {
                'nmodes' => 2,
                'parent' => 'msroute',
                'desc'   => 'Microsoft Streets and Trips (pin/route reader)',
                'modes'  => '----r-',
                'ext'    => 'est'
            },
            'csv' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Comma separated values',
                'modes' => 'rw----'
            },
            'tomtom' => {
                'nmodes' => 48,
                'parent' => 'tomtom',
                'desc'   => 'TomTom POI file',
                'modes'  => 'rw----',
                'ext'    => 'ov2'
            },
            'gcdb' => {
                'nmodes' => 48,
                'parent' => 'gcdb',
                'desc'   => 'GeocachingDB for Palm/OS',
                'modes'  => 'rw----',
                'ext'    => 'pdb'
            },
            'gpssim' => {
                'nmodes'  => 21,
                'parent'  => 'gpssim',
                'options' => {
                    'wayptspd' => {
                        'min'     => '',
                        'desc'    => 'Default speed for waypoints (knots/hr)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'float'
                    },
                    'split' => {
                        'min'     => '',
                        'desc'    => 'Split input into separate files',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Franson GPSGate Simulation',
                'modes' => '-w-w-w',
                'ext'   => 'gpssim'
            },
            'yahoo' => {
                'nmodes'  => 32,
                'parent'  => 'yahoo',
                'options' => {
                    'addrsep' => {
                        'min' => '',
                        'desc' =>
                          'String to separate concatenated address fields (default=", ")',
                        'max'     => '',
                        'default' => ', ',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Yahoo Geocode API data',
                'modes' => 'r-----'
            },
            'wbt-bin' => {
                'nmodes' => 8,
                'parent' => 'wbt-bin',
                'desc'   => 'Wintec WBT-100/200 Binary file format',
                'modes'  => '--r---'
            },
            'stmsdf' => {
                'nmodes'  => 15,
                'parent'  => 'stmsdf',
                'options' => {
                    'index' => {
                        'min'  => '1',
                        'desc' => 'Index of route (if more the one in source)',
                        'max'  => '',
                        'default' => '1',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Suunto Trek Manager (STM) .sdf files',
                'modes' => '--rwrw',
                'ext'   => 'sdf'
            },
            'easygps' => {
                'nmodes' => 48,
                'parent' => 'easygps',
                'desc'   => 'EasyGPS binary format',
                'modes'  => 'rw----',
                'ext'    => 'loc'
            },
            'openoffice' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc' =>
                  'Tab delimited fields useful for OpenOffice, Ploticus etc.',
                'modes' => 'rw----'
            },
            'ktf2' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Kartex 5 Track File',
                'modes' => 'rw----',
                'ext'   => 'ktf'
            },
            'geo' => {
                'nmodes'  => 48,
                'parent'  => 'geo',
                'options' => {
                    'nuke_placer' => {
                        'min'     => '',
                        'desc'    => 'Omit Placer name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Geocaching.com .loc',
                'modes' => 'rw----',
                'ext'   => 'loc'
            },
            'pcx' => {
                'nmodes'  => 63,
                'parent'  => 'pcx',
                'options' => {
                    'cartoexploreur' => {
                        'min' => '',
                        'desc' =>
                          'Write tracks compatible with Carto Exploreur',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => 'Waypoint',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Garmin PCX5',
                'modes' => 'rwrwrw',
                'ext'   => 'pcx'
            },
            'xmap' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'DeLorme XMap HH Native .WPT',
                'modes' => 'rw----',
                'ext'   => 'wpt'
            },
            'holux' => {
                'nmodes' => 48,
                'parent' => 'holux',
                'desc'   => 'Holux (gm-100) .wpo Format',
                'modes'  => 'rw----',
                'ext'    => 'wpo'
            },
            'gpspilot' => {
                'nmodes'  => 48,
                'parent'  => 'gpspilot',
                'options' => {
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'GPSPilot Tracker for Palm/OS',
                'modes' => 'rw----',
                'ext'   => 'pdb'
            },
            'kml' => {
                'nmodes'  => 63,
                'parent'  => 'kml',
                'options' => {
                    'max_position_points' => {
                        'min' => '',
                        'desc' =>
                          'Retain at most this number of position points  (0 = unlimited)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'line_color' => {
                        'min'     => '',
                        'desc'    => 'Line color, specified in hex AABBGGRR',
                        'max'     => '',
                        'default' => '64eeee17',
                        'type'    => 'string'
                    },
                    'trackdata' => {
                        'min' => '',
                        'desc' =>
                          'Include extended data for trackpoints (default = 1)',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'line_width' => {
                        'min'     => '',
                        'desc'    => 'Width of lines, in pixels',
                        'max'     => '',
                        'default' => '6',
                        'type'    => 'integer'
                    },
                    'points' => {
                        'min'     => '',
                        'desc'    => 'Export placemarks for tracks and routes',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'lines' => {
                        'min'     => '',
                        'desc'    => 'Export linestrings for tracks and routes',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'floating' => {
                        'min' => '',
                        'desc' =>
                          'Altitudes are absolute and not clamped to ground',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'labels' => {
                        'min' => '',
                        'desc' =>
                          'Display labels on track and routepoints  (default = 1)',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'extrude' => {
                        'min' => '',
                        'desc' =>
                          'Draw extrusion line from trackpoint to ground',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'units' => {
                        'min' => '',
                        'desc' =>
                          'Units used when writing comments (\'s\'tatute or \'m\'etric)',
                        'max'     => '',
                        'default' => 's',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Google Earth (Keyhole) Markup Language',
                'modes' => 'rwrwrw',
                'ext'   => 'kml'
            },
            'wfff' => {
                'nmodes'  => 32,
                'parent'  => 'wfff',
                'options' => {
                    'snmac' => {
                        'min'     => '',
                        'desc'    => 'Shortname is MAC address',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'ahcicon' => {
                        'min'     => '',
                        'desc'    => 'Ad-hoc closed icon name',
                        'max'     => '',
                        'default' => 'Red Diamond',
                        'type'    => 'string'
                    },
                    'ahoicon' => {
                        'min'     => '',
                        'desc'    => 'Ad-hoc open icon name',
                        'max'     => '',
                        'default' => 'Green Diamond',
                        'type'    => 'string'
                    },
                    'aicicon' => {
                        'min'     => '',
                        'desc'    => 'Infrastructure closed icon name',
                        'max'     => '',
                        'default' => 'Red Square',
                        'type'    => 'string'
                    },
                    'aioicon' => {
                        'min'     => '',
                        'desc'    => 'Infrastructure open icon name',
                        'max'     => '',
                        'default' => 'Green Square',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'WiFiFoFum 2.0 for PocketPC XML',
                'modes' => 'r-----',
                'ext'   => 'xml'
            },
            'mapconverter' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Mapopolis.com Mapconverter CSV',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'cetus' => {
                'nmodes'  => 56,
                'parent'  => 'cetus',
                'options' => {
                    'appendicon' => {
                        'min'     => '',
                        'desc'    => 'Append icon_descr to description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Cetus for Palm/OS',
                'modes' => 'rwr---',
                'ext'   => 'pdb'
            },
            'alantrl' => {
                'nmodes' => 12,
                'parent' => 'alantrl',
                'desc'   => 'Alan Map500 tracklogs (.trl)',
                'modes'  => '--rw--',
                'ext'    => 'trl'
            },
            'glogbook' => {
                'nmodes' => 12,
                'parent' => 'glogbook',
                'desc'   => 'Garmin Logbook XML',
                'modes'  => '--rw--',
                'ext'    => 'xml'
            },
            'fugawi' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Fugawi',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'xmapwpt' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'DeLorme XMat HH Street Atlas USA .WPT (PPC)',
                'modes' => 'rw----'
            },
            'xmap2006' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'DeLorme XMap/SAHH 2006 Native .TXT',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'saroute' => {
                'nmodes'  => 8,
                'parent'  => 'saroute',
                'options' => {
                    'controls' => {
                        'min'  => '',
                        'desc' => 'Read control points as waypoint/route/none',
                        'max'  => '',
                        'default' => 'none',
                        'type'    => 'string'
                    },
                    'times' => {
                        'min'     => '',
                        'desc'    => 'Synthesize track times',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'turns_only' => {
                        'min'     => '',
                        'desc'    => 'Only read turns; skip all other points',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'turns_important' => {
                        'min'     => '',
                        'desc'    => 'Keep turns if simplify filter is used',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'split' => {
                        'min'     => '',
                        'desc'    => 'Split into multiple routes at turns',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'DeLorme Street Atlas Route',
                'modes' => '--r---',
                'ext'   => 'anr'
            },
            'gpx' => {
                'nmodes'  => 63,
                'parent'  => 'gpx',
                'options' => {
                    'logpoint' => {
                        'min'  => '',
                        'desc' => 'Create waypoints from geocache log entries',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Base URL for link tag in output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'gpxver' => {
                        'min'     => '',
                        'desc'    => 'Target GPX version for output',
                        'max'     => '',
                        'default' => '1.0',
                        'type'    => 'string'
                    },
                    'suppresswhite' => {
                        'min'     => '',
                        'desc'    => 'No whitespace in generated shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Length of generated shortnames',
                        'max'     => '',
                        'default' => '32',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'GPX XML',
                'modes' => 'rwrwrw',
                'ext'   => 'gpx'
            },
            'an1' => {
                'nmodes'  => 55,
                'parent'  => 'an1',
                'options' => {
                    'nogc' => {
                        'min'     => '',
                        'desc'    => 'Do not add geocache data to description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'radius' => {
                        'min'     => '',
                        'desc'    => 'Radius for circles',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'zoom' => {
                        'min'     => '',
                        'desc'    => 'Zoom level to reduce points',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Symbol to use for point data',
                        'max'     => '',
                        'default' => 'Red Flag',
                        'type'    => 'string'
                    },
                    'wpt_type' => {
                        'min'     => '',
                        'desc'    => 'Waypoint type',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'color' => {
                        'min'     => '',
                        'desc'    => 'Color for lines or mapnotes',
                        'max'     => '',
                        'default' => 'red',
                        'type'    => 'string'
                    },
                    'type' => {
                        'min'     => '',
                        'desc'    => 'Type of .an1 file',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'road' => {
                        'min'     => '',
                        'desc'    => 'Road type changes',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'DeLorme .an1 (drawing) file',
                'modes' => 'rw-wrw',
                'ext'   => 'an1'
            },
            'hsandv' => {
                'nmodes' => 48,
                'parent' => 'hsandv',
                'desc'   => 'HSA Endeavour Navigator export File',
                'modes'  => 'rw----'
            },
            'netstumbler' => {
                'nmodes'  => 32,
                'parent'  => 'netstumbler',
                'options' => {
                    'snmac' => {
                        'min'     => '',
                        'desc'    => 'Shortname is MAC address',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'nseicon' => {
                        'min'     => '',
                        'desc'    => 'Non-stealth encrypted icon name',
                        'max'     => '',
                        'default' => 'Red Square',
                        'type'    => 'string'
                    },
                    'nsneicon' => {
                        'min'     => '',
                        'desc'    => 'Non-stealth non-encrypted icon name',
                        'max'     => '',
                        'default' => 'Green Square',
                        'type'    => 'string'
                    },
                    'sneicon' => {
                        'min'     => '',
                        'desc'    => 'Stealth non-encrypted icon name',
                        'max'     => '',
                        'default' => 'Green Diamond',
                        'type'    => 'string'
                    },
                    'seicon' => {
                        'min'     => '',
                        'desc'    => 'Stealth encrypted icon name',
                        'max'     => '',
                        'default' => 'Red Diamond',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'NetStumbler Summary File (text)',
                'modes' => 'r-----'
            },
            'custom' => {
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                }
            },
            'gpsdrive' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'GpsDrive Format',
                'modes' => 'rw----'
            },
            'gtrnctr' => {
                'nmodes' => 4,
                'parent' => 'gtrnctr',
                'desc'   => 'Garmin Training Centerxml',
                'modes'  => '---w--'
            },
            'geonet' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'GEOnet Names Server (GNS)',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'html' => {
                'nmodes'  => 16,
                'parent'  => 'html',
                'options' => {
                    'altunits' => {
                        'min'     => '',
                        'desc'    => 'Units for altitude (f)eet or (m)etres',
                        'max'     => '',
                        'default' => 'm',
                        'type'    => 'string'
                    },
                    'encrypt' => {
                        'min'     => '',
                        'desc'    => 'Encrypt hints using ROT13',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'degformat' => {
                        'min' => '',
                        'desc' =>
                          'Degrees output as \'ddd\', \'dmm\'(default) or \'dms\'',
                        'max'     => '',
                        'default' => 'dmm',
                        'type'    => 'string'
                    },
                    'stylesheet' => {
                        'min'     => '',
                        'desc'    => 'Path to HTML style sheet',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'logs' => {
                        'min'     => '',
                        'desc'    => 'Include groundspeak logs if present',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'HTML Output',
                'modes' => '-w----',
                'ext'   => 'html'
            },
            'coto' => {
                'nmodes'  => 56,
                'parent'  => 'coto',
                'options' => {
                    'zerocat' => {
                        'min'     => '',
                        'desc'    => 'Name of the \'unassigned\' category',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'cotoGPS for Palm/OS',
                'modes' => 'rwr---',
                'ext'   => 'pdb'
            },
            'text' => {
                'nmodes'  => 16,
                'parent'  => 'text',
                'options' => {
                    'altunits' => {
                        'min'     => '',
                        'desc'    => 'Units for altitude (f)eet or (m)etres',
                        'max'     => '',
                        'default' => 'm',
                        'type'    => 'string'
                    },
                    'encrypt' => {
                        'min'     => '',
                        'desc'    => 'Encrypt hints using ROT13',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'degformat' => {
                        'min' => '',
                        'desc' =>
                          'Degrees output as \'ddd\', \'dmm\'(default) or \'dms\'',
                        'max'     => '',
                        'default' => 'dmm',
                        'type'    => 'string'
                    },
                    'nosep' => {
                        'min'  => '',
                        'desc' => 'Suppress separator lines between waypoints',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'logs' => {
                        'min'     => '',
                        'desc'    => 'Include groundspeak logs if present',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Textual Output',
                'modes' => '-w----',
                'ext'   => 'txt'
            },
            'geoniche' => {
                'nmodes'  => 48,
                'parent'  => 'geoniche',
                'options' => {
                    'category' => {
                        'min'     => '',
                        'desc'    => 'Category name (Cache)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name (filename)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'GeoNiche .pdb',
                'modes' => 'rw----',
                'ext'   => 'pdb'
            },
            'garmin_poi' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Garmin POI database',
                'modes' => 'rw----'
            },
            'tpo3' => {
                'nmodes' => 42,
                'parent' => 'tpo3',
                'desc'   => 'National Geographic Topo 3.x/4.x .tpo',
                'modes'  => 'r-r-r-',
                'ext'    => 'tpo'
            },
            'raymarine' => {
                'nmodes'  => 51,
                'parent'  => 'raymarine',
                'options' => {
                    'location' => {
                        'min'     => '',
                        'desc'    => 'Default location',
                        'max'     => '',
                        'default' => 'New location',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Raymarine Waypoint File (.rwf)',
                'modes' => 'rw--rw',
                'ext'   => 'rwf'
            },
            'garmin_txt' => {
                'nmodes'  => 63,
                'parent'  => 'garmin_txt',
                'options' => {
                    'grid' => {
                        'min'     => '',
                        'desc'    => 'Write position using this grid.',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'temp' => {
                        'min'  => '',
                        'desc' => 'Temperature unit [c=Celsius, f=Fahrenheit]',
                        'max'  => '',
                        'default' => 'c',
                        'type'    => 'string'
                    },
                    'prec' => {
                        'min'     => '',
                        'desc'    => 'Precision of coordinates',
                        'max'     => '',
                        'default' => '3',
                        'type'    => 'integer'
                    },
                    'time' => {
                        'min'  => '',
                        'desc' => 'Read/Write time format (i.e. HH:mm:ss xx)',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'date' => {
                        'min'     => '',
                        'desc'    => 'Read/Write date format (i.e. yyyy/mm/dd)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'utc' => {
                        'min'  => '-23',
                        'desc' => 'Write timestamps with offset x to UTC time',
                        'max'  => '+23',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'dist' => {
                        'min'     => '',
                        'desc'    => 'Distance unit [m=metric, s=statute]',
                        'max'     => '',
                        'default' => 'm',
                        'type'    => 'string'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => 'WGS 84',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Garmin MapSource - txt (tab delimited)',
                'modes' => 'rwrwrw',
                'ext'   => 'txt'
            },
            'magellanx' => {
                'nmodes'  => 63,
                'parent'  => 'magellanx',
                'options' => {
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'maxcmts' => {
                        'min' => '',
                        'desc' =>
                          'Max number of comments to write (maxcmts=200)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Magellan SD files (as for eXplorist)',
                'modes' => 'rwrwrw',
                'ext'   => 'upt'
            },
            'magnav' => {
                'nmodes' => 48,
                'parent' => 'magnav',
                'desc'   => 'Magellan NAV Companion for Palm/OS',
                'modes'  => 'rw----',
                'ext'    => 'pdb'
            },
            'maggeo' => {
                'nmodes' => 16,
                'parent' => 'maggeo',
                'desc'   => 'Magellan Explorist Geocaching',
                'modes'  => '-w----',
                'ext'    => 'gs'
            },
            'cambridge' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Cambridge/Winpilot glider software',
                'modes' => 'rw----',
                'ext'   => 'dat'
            },
            'pathaway' => {
                'nmodes'  => 63,
                'parent'  => 'pathaway',
                'options' => {
                    'date' => {
                        'min'     => '',
                        'desc'    => 'Read/Write date format (i.e. DDMMYYYY)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Length of generated shortnames',
                        'max'     => '',
                        'default' => '10',
                        'type'    => 'integer'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'PathAway Database for Palm/OS',
                'modes' => 'rwrwrw',
                'ext'   => 'pdb'
            },
            'gdb' => {
                'nmodes'  => 63,
                'parent'  => 'gdb',
                'options' => {
                    'via' => {
                        'min' => '',
                        'desc' =>
                          'Drop route points that do not have an equivalent waypoint (hidden points)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'cat' => {
                        'min'     => '1',
                        'desc'    => 'Default category on output (1..16)',
                        'max'     => '16',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'ver' => {
                        'min'     => '1',
                        'desc'    => 'Version of gdb file to generate (1,2)',
                        'max'     => '2',
                        'default' => '2',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Garmin MapSource - gdb',
                'modes' => 'rwrwrw',
                'ext'   => 'gdb'
            },
            'wbt' => {
                'options' => {
                    'erase' => {
                        'min'     => '',
                        'desc'    => 'Erase device data after download',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                }
            },
            'gpsutil' => {
                'nmodes' => 48,
                'parent' => 'gpsutil',
                'desc'   => 'gpsutil',
                'modes'  => 'rw----'
            },
            'vitosmt' => {
                'nmodes' => 63,
                'parent' => 'vitosmt',
                'desc'   => 'Vito Navigator II tracks',
                'modes'  => 'rwrwrw',
                'ext'    => 'smt'
            },
            'tiger' => {
                'nmodes'  => 48,
                'parent'  => 'tiger',
                'options' => {
                    'oldthresh' => {
                        'min'  => '',
                        'desc' => 'Days after which points are considered old',
                        'max'  => '',
                        'default' => '14',
                        'type'    => 'integer'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max shortname length when used with -s',
                        'max'     => '',
                        'default' => '10',
                        'type'    => 'integer'
                    },
                    'ypixels' => {
                        'min'     => '',
                        'desc'    => 'Height in pixels of map',
                        'max'     => '',
                        'default' => '768',
                        'type'    => 'integer'
                    },
                    'xpixels' => {
                        'min'     => '',
                        'desc'    => 'Width in pixels of map',
                        'max'     => '',
                        'default' => '768',
                        'type'    => 'integer'
                    },
                    'newmarker' => {
                        'min'     => '',
                        'desc'    => 'Marker type for new points',
                        'max'     => '',
                        'default' => 'greenpin',
                        'type'    => 'string'
                    },
                    'iconismarker' => {
                        'min'  => '',
                        'desc' => 'The icon description is already the marker',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'oldmarker' => {
                        'min'     => '',
                        'desc'    => 'Marker type for old points',
                        'max'     => '',
                        'default' => 'redpin',
                        'type'    => 'string'
                    },
                    'genurl' => {
                        'min' => '',
                        'desc' =>
                          'Generate file with lat/lon for centering map',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'outfile'
                    },
                    'suppresswhite' => {
                        'min'  => '',
                        'desc' => 'Suppress whitespace in generated shortnames',
                        'max'  => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'unfoundmarker' => {
                        'min'     => '',
                        'desc'    => 'Marker type for unfound points',
                        'max'     => '',
                        'default' => 'bluepin',
                        'type'    => 'string'
                    },
                    'nolabels' => {
                        'min'     => '',
                        'desc'    => 'Suppress labels on generated pins',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'margin' => {
                        'min'     => '',
                        'desc'    => 'Margin for map.  Degrees or percentage',
                        'max'     => '',
                        'default' => '15%',
                        'type'    => 'float'
                    }
                },
                'desc'  => 'U.S. Census Bureau Tiger Mapping Service',
                'modes' => 'rw----'
            },
            'alanwpr' => {
                'nmodes' => 51,
                'parent' => 'alanwpr',
                'desc'   => 'Alan Map500 waypoints and routes (.wpr)',
                'modes'  => 'rw--rw',
                'ext'    => 'wpr'
            },
            'gpsman' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'GPSman',
                'modes' => 'rw----'
            },
            'gpl' => {
                'nmodes' => 12,
                'parent' => 'gpl',
                'desc'   => 'DeLorme GPL',
                'modes'  => '--rw--',
                'ext'    => 'gpl'
            },
            'vcard' => {
                'nmodes'  => 16,
                'parent'  => 'vcard',
                'options' => {
                    'encrypt' => {
                        'min'     => '',
                        'desc'    => 'Encrypt hints using ROT13',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Vcard Output (for iPod)',
                'modes' => '-w----',
                'ext'   => 'vcf'
            },
            'tef' => {
                'nmodes'  => 2,
                'parent'  => 'tef',
                'options' => {
                    'routevia' => {
                        'min'     => '',
                        'desc'    => 'Include only via stations in route',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Map&Guide \'TourExchangeFormat\' XML',
                'modes' => '----r-',
                'ext'   => 'xml'
            },
            'arc' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'GPSBabel arc filter file',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'kwf2' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Kartex 5 Waypoint File',
                'modes' => 'rw----',
                'ext'   => 'kwf'
            },
            'cup' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'See You flight analysis data',
                'modes' => 'rw----',
                'ext'   => 'cup'
            },
            'quovadis' => {
                'nmodes'  => 48,
                'parent'  => 'quovadis',
                'options' => {
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'Quovadis',
                'modes' => 'rw----',
                'ext'   => 'pdb'
            },
            's_and_t' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Microsoft Streets and Trips 2002-2006',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'tpo2' => {
                'nmodes' => 8,
                'parent' => 'tpo2',
                'desc'   => 'National Geographic Topo 2.x .tpo',
                'modes'  => '--r---',
                'ext'    => 'tpo'
            },
            'cst' => {
                'nmodes' => 42,
                'parent' => 'cst',
                'desc'   => 'CarteSurTable data file',
                'modes'  => 'r-r-r-',
                'ext'    => 'cst'
            },
            'stmwpp' => {
                'nmodes'  => 63,
                'parent'  => 'stmwpp',
                'options' => {
                    'index' => {
                        'min' => '1',
                        'desc' =>
                          'Index of route/track to write (if more the one in source)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Suunto Trek Manager (STM) WaypointPlus files',
                'modes' => 'rwrwrw',
                'ext'   => 'txt'
            },
            'ignrando' => {
                'nmodes'  => 12,
                'parent'  => 'ignrando',
                'options' => {
                    'index' => {
                        'min' => '1',
                        'desc' =>
                          'Index of track to write (if more the one in source)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'IGN Rando track files',
                'modes' => '--rw--',
                'ext'   => 'rdn'
            },
            'navicache' => {
                'nmodes'  => 32,
                'parent'  => 'navicache',
                'options' => {
                    'noretired' => {
                        'min'     => '',
                        'desc'    => 'Suppress retired geocaches',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Navicache.com XML',
                'modes' => 'r-----'
            },
            'psitrex' => {
                'nmodes' => 63,
                'parent' => 'psitrex',
                'desc'   => 'KuDaTa PsiTrex text',
                'modes'  => 'rwrwrw'
            },
            'unicsv' => {
                'nmodes' => 32,
                'parent' => 'unicsv',
                'desc'   => 'Universal csv with field structure in first line',
                'modes'  => 'r-----'
            },
            'tmpro' => {
                'nmodes' => 48,
                'parent' => 'tmpro',
                'desc'   => 'TopoMapPro Places File',
                'modes'  => 'rw----',
                'ext'    => 'tmpro'
            },
            'shape' => {
                'options' => {
                    'url' => {
                        'min'     => '',
                        'desc'    => 'Index of URL field in .dbf',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'name' => {
                        'min'     => '',
                        'desc'    => 'Index of name field in .dbf',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                }
            },
            'saplus' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'DeLorme Street Atlas Plus',
                'modes' => 'rw----'
            },
            'dna' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Navitrak DNA marker format',
                'modes' => 'rw----',
                'ext'   => 'dna'
            },
            'gtm' => {
                'nmodes' => 63,
                'parent' => 'gtm',
                'desc'   => 'GPS TrackMaker',
                'modes'  => 'rwrwrw',
                'ext'    => 'gtm'
            },
            'compegps' => {
                'nmodes'  => 63,
                'parent'  => 'compegps',
                'options' => {
                    'index' => {
                        'min' => '1',
                        'desc' =>
                          'Index of route/track to write (if more the one in source)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'radius' => {
                        'min' => '',
                        'desc' =>
                          'Give points (waypoints/route points) a default radius (proximity)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'float'
                    },
                    'snlen' => {
                        'min'  => '1',
                        'desc' => 'Length of generated shortnames (default 16)',
                        'max'  => '',
                        'default' => '16',
                        'type'    => 'integer'
                    },
                    'deficon' => {
                        'min'     => '',
                        'desc'    => 'Default icon name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'CompeGPS data files (.wpt/.trk/.rte)',
                'modes' => 'rwrwrw'
            },
            'copilot' => {
                'nmodes' => 48,
                'parent' => 'copilot',
                'desc'   => 'CoPilot Flight Planner for Palm/OS',
                'modes'  => 'rw----',
                'ext'    => 'pdb'
            },
            'nmea' => {
                'nmodes'  => 60,
                'parent'  => 'nmea',
                'options' => {
                    'gpvtg' => {
                        'min'     => '',
                        'desc'    => 'Read/write GPVTG sentences',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'baud' => {
                        'min' => '',
                        'desc' =>
                          'Speed in bits per second of serial port (baud=4800)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'date' => {
                        'min' => '',
                        'desc' =>
                          'Complete date-free tracks with given date (YYYYMMDD).',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max length of waypoint name to write',
                        'max'     => '64',
                        'default' => '6',
                        'type'    => 'integer'
                    },
                    'get_posn' => {
                        'min'     => '',
                        'desc'    => 'Return current position as a waypoint',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'pause' => {
                        'min' => '',
                        'desc' =>
                          'Decimal seconds to pause between groups of strings',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'gpgga' => {
                        'min'     => '',
                        'desc'    => 'Read/write GPGGA sentences',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'gpgsa' => {
                        'min'     => '',
                        'desc'    => 'Read/write GPGSA sentences',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    },
                    'gprmc' => {
                        'min'     => '',
                        'desc'    => 'Read/write GPRMC sentences',
                        'max'     => '',
                        'default' => '1',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'NMEA 0183 sentences',
                'modes' => 'rwrw--'
            },
            'mapsource' => {
                'nmodes'  => 63,
                'parent'  => 'mapsource',
                'options' => {
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'mpsverout' => {
                        'min' => '',
                        'desc' =>
                          'Version of mapsource file to generate (3,4,5)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'mpsusedepth' => {
                        'min' => '',
                        'desc' =>
                          'Use depth values on output (default is ignore)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'mpsuseprox' => {
                        'min' => '',
                        'desc' =>
                          'Use proximity values on output (default is ignore)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Length of generated shortnames',
                        'max'     => '',
                        'default' => '10',
                        'type'    => 'integer'
                    },
                    'mpsmergeout' => {
                        'min'     => '',
                        'desc'    => 'Merge output with existing file',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Garmin MapSource - mps',
                'modes' => 'rwrwrw',
                'ext'   => 'mps'
            },
            'axim_gpb' => {
                'nmodes' => 8,
                'parent' => 'axim_gpb',
                'desc'   => 'Dell Axim Navigation System (.gpb) file format',
                'modes'  => '--r---',
                'ext'    => 'gpb'
            },
            'gpsdrivetrack' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'GpsDrive Format for Tracks',
                'modes' => 'rw----'
            },
            'hiketech' => {
                'nmodes' => 60,
                'parent' => 'hiketech',
                'desc'   => 'HikeTech',
                'modes'  => 'rwrw--',
                'ext'    => 'gps'
            },
            'psp' => {
                'nmodes' => 48,
                'parent' => 'psp',
                'desc'   => 'MS PocketStreets 2002 Pushpin',
                'modes'  => 'rw----',
                'ext'    => 'psp'
            },
            'sportsim' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Sportsim track files (part of zipped .ssz files)',
                'modes' => 'rw----',
                'ext'   => 'txt'
            },
            'ozi' => {
                'nmodes'  => 63,
                'parent'  => 'ozi',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '32',
                        'type'    => 'integer'
                    },
                    'wptbgcolor' => {
                        'min'     => '',
                        'desc'    => 'Waypoint background color',
                        'max'     => '',
                        'default' => 'yellow',
                        'type'    => 'string'
                    },
                    'wptfgcolor' => {
                        'min'     => '',
                        'desc'    => 'Waypoint foreground color',
                        'max'     => '',
                        'default' => 'black',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'OziExplorer',
                'modes' => 'rwrwrw'
            },
            'tabsep' => {
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                }
            },
            'coastexp' => {
                'nmodes' => 51,
                'parent' => 'coastexp',
                'desc'   => 'CoastalExplorer XML',
                'modes'  => 'rw--rw'
            },
            'palmdoc' => {
                'nmodes'  => 16,
                'parent'  => 'palmdoc',
                'options' => {
                    'encrypt' => {
                        'min'     => '',
                        'desc'    => 'Encrypt hints with ROT13',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'nosep' => {
                        'min'     => '',
                        'desc'    => 'No separator lines between waypoints',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'bookmarks_short' => {
                        'min'     => '',
                        'desc'    => 'Include short name in bookmarks',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'logs' => {
                        'min'     => '',
                        'desc'    => 'Include groundspeak logs if present',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'PalmDoc Output',
                'modes' => '-w----',
                'ext'   => 'pdb'
            },
            'xcsv' => {
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'style' => {
                        'min'     => '',
                        'desc'    => 'Full path to XCSV style file',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'file'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                }
            },
            'mapsend' => {
                'nmodes'  => 63,
                'parent'  => 'mapsend',
                'options' => {
                    'trkver' => {
                        'min'  => '3',
                        'desc' => 'MapSend version TRK file to generate (3,4)',
                        'max'  => '4',
                        'default' => '4',
                        'type'    => 'integer'
                    }
                },
                'desc'  => 'Magellan Mapsend',
                'modes' => 'rwrwrw'
            },
            'garmin301' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'Garmin 301 Custom position and heartrate',
                'modes' => 'rw----'
            },
            'nima' => {
                'nmodes'  => 48,
                'parent'  => 'xcsv',
                'options' => {
                    'snunique' => {
                        'min'     => '',
                        'desc'    => 'Make synth. shortnames unique',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'snwhite' => {
                        'min'     => '',
                        'desc'    => 'Allow whitespace synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'urlbase' => {
                        'min'     => '',
                        'desc'    => 'Basename prepended to URL on output',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snupper' => {
                        'min'     => '',
                        'desc'    => 'UPPERCASE synth. shortnames',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    },
                    'datum' => {
                        'min'     => '',
                        'desc'    => 'GPS datum (def. WGS 84)',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    },
                    'snlen' => {
                        'min'     => '1',
                        'desc'    => 'Max synthesized shortname length',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'integer'
                    },
                    'prefer_shortnames' => {
                        'min'     => '',
                        'desc'    => 'Use shortname instead of description',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'boolean'
                    }
                },
                'desc'  => 'NIMA/GNIS Geographic Names File',
                'modes' => 'rw----'
            },
            'mag_pdb' => {
                'nmodes' => 34,
                'parent' => 'mag_pdb',
                'desc'   => 'Map&Guide to Palm/OS exported files (.pdb)',
                'modes'  => 'r---r-',
                'ext'    => 'pdb'
            },
            'gpilots' => {
                'nmodes'  => 48,
                'parent'  => 'gpilots',
                'options' => {
                    'dbname' => {
                        'min'     => '',
                        'desc'    => 'Database name',
                        'max'     => '',
                        'default' => '',
                        'type'    => 'string'
                    }
                },
                'desc'  => 'GpilotS',
                'modes' => 'rw----',
                'ext'   => 'pdb'
            }
        },
        'for_ext' => {
            'anr'    => ['saroute'],
            'rwf'    => ['raymarine'],
            'tpg'    => ['tpg'],
            'mxf'    => ['mxf'],
            'sdf'    => ['stmsdf'],
            'gpl'    => ['gpl'],
            'bcr'    => ['bcr'],
            'xml'    => [ 'glogbook', 'google', 'tef', 'wfff' ],
            'gpssim' => ['gpssim'],
            'trl'   => [ 'alantrl', 'dmtlog' ],
            'cup'   => ['cup'],
            'pcx'   => ['pcx'],
            'wpt'   => ['xmap'],
            'rte'   => ['nmn4'],
            'kml'   => ['kml'],
            'cst'   => ['cst'],
            'est'   => ['msroute'],
            'gs'    => ['maggeo'],
            'rdn'   => ['ignrando'],
            'gps'   => ['hiketech'],
            'loc'   => [ 'easygps', 'geo' ],
            'tmpro' => ['tmpro'],
            'ov2'   => ['tomtom'],
            'axe'   => ['msroute'],
            'dna'   => ['dna'],
            'gtm'   => ['gtm'],
            'gpx'   => ['gpx'],
            'an1'   => ['an1'],
            'wpo'   => ['holux'],
            'txt'   => [
                'xmap2006', 'fugawi',       'garmin_txt', 'geonet',
                'arc',      'mapconverter', 's_and_t',    'sportsim',
                'stmwpp',   'text'
            ],
            'vcf'  => ['vcard'],
            'html' => ['html'],
            'dat'  => ['cambridge'],
            'gpb'  => ['axim_gpb'],
            'kwf'  => ['kwf2'],
            'psp'  => ['psp'],
            'usr'  => ['lowranceusr'],
            'mps'  => ['mapsource'],
            'upt'  => ['magellanx'],
            'smt'  => ['vitosmt'],
            'ktf'  => ['ktf2'],
            'pdb'  => [
                'cetus',    'copilot', 'coto',     'gcdb',
                'geoniche', 'gpilots', 'gpspilot', 'magnav',
                'mag_pdb',  'palmdoc', 'pathaway', 'quovadis'
            ],
            'wpr' => ['alanwpr'],
            'tpo' => [ 'tpo2', 'tpo3' ],
            'gdb' => ['gdb']
        },
        'filters' => {
            'transform' => {
                'options' => {
                    'del' => {
                        'desc'  => 'Delete source data after transformation',
                        'type'  => 'boolean',
                        'valid' => ['N']
                    },
                    'wpt' => {
                        'desc' =>
                          'Transform track(s) or route(s) into waypoint(s) [R/T]',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'trk' => {
                        'desc' =>
                          'Transform waypoint(s) or route(s) into tracks(s) [W/R]',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'rte' => {
                        'desc' =>
                          'Transform waypoint(s) or track(s) into route(s) [W/T]',
                        'type'  => 'string',
                        'valid' => []
                    }
                },
                'desc' =>
                  'Transform waypoints into a route, tracks into routes, ...'
            },
            'discard' => {
                'options' => {
                    'vdop' => {
                        'desc'  => 'Suppress waypoints with higher vdop',
                        'type'  => 'float',
                        'valid' => ['-1.0']
                    },
                    'hdopandvdop' => {
                        'desc'  => 'Link hdop and vdop supression with AND',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'hdop' => {
                        'desc'  => 'Suppress waypoints with higher hdop',
                        'type'  => 'float',
                        'valid' => ['-1.0']
                    }
                },
                'desc' => 'Remove unreliable points with high hdop or vdop'
            },
            'stack' => {
                'options' => {
                    'discard' => {
                        'desc'  => '(pop) Discard top of stack',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'depth' => {
                        'desc'  => '(swap) Item to use (default=1)',
                        'type'  => 'integer',
                        'valid' => [ '', '0' ]
                    },
                    'append' => {
                        'desc'  => '(pop) Append list',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'copy' => {
                        'desc'  => '(push) Copy waypoint list',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'push' => {
                        'desc'  => 'Push waypoint list onto stack',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'replace' => {
                        'desc'  => '(pop) Replace list (default)',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'swap' => {
                        'desc' =>
                          'Swap waypoint list with <depth> item on stack',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'pop' => {
                        'desc'  => 'Pop waypoint list from stack',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Save and restore waypoint lists'
            },
            'track' => {
                'options' => {
                    'course' => {
                        'desc'  => 'Synthesize course',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'stop' => {
                        'desc' => 'Use only track points before this timestamp',
                        'type' => 'integer',
                        'valid' => []
                    },
                    'move' => {
                        'desc'  => 'Correct trackpoint timestamps by a delta',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'fix' => {
                        'desc' =>
                          'Synthesize GPS fixes (PPS, DGPS, 3D, 2D, NONE)',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'name' => {
                        'desc' =>
                          'Use only track(s) where title matches given name',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'merge' => {
                        'desc'  => 'Merge multiple tracks for the same way',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'speed' => {
                        'desc'  => 'Synthesize speed',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'sdistance' => {
                        'desc'  => 'Split by distance',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'title' => {
                        'desc'  => 'Basic title for new track(s)',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'pack' => {
                        'desc'  => 'Pack all tracks into one',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'split' => {
                        'desc' => 'Split by date or time interval (see README)',
                        'type' => 'string',
                        'valid' => []
                    },
                    'start' => {
                        'desc'  => 'Use only track points after this timestamp',
                        'type'  => 'integer',
                        'valid' => []
                    }
                },
                'desc' => 'Manipulate track lists'
            },
            'radius' => {
                'options' => {
                    'nosort' => {
                        'desc'  => 'Inhibit sort by distance to center',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'maxcount' => {
                        'desc'  => 'Output no more than this number of points',
                        'type'  => 'integer',
                        'valid' => [ '', '1' ]
                    },
                    'asroute' => {
                        'desc' =>
                          'Put resulting waypoints in route of this name',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'distance' => {
                        'desc'  => 'Maximum distance from center',
                        'type'  => 'float',
                        'valid' => []
                    },
                    'lat' => {
                        'desc'  => 'Latitude for center point (D.DDDDD)',
                        'type'  => 'float',
                        'valid' => []
                    },
                    'lon' => {
                        'desc'  => 'Longitude for center point (D.DDDDD)',
                        'type'  => 'float',
                        'valid' => []
                    },
                    'exclude' => {
                        'desc'  => 'Exclude points close to center',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Include Only Points Within Radius'
            },
            'position' => {
                'options' => {
                    'distance' => {
                        'desc'  => 'Maximum positional distance',
                        'type'  => 'float',
                        'valid' => []
                    },
                    'all' => {
                        'desc'  => 'Suppress all points close to other points',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Remove Points Within Distance'
            },
            'reverse'  => { 'desc' => 'Reverse stops within routes' },
            'simplify' => {
                'options' => {
                    'length' => {
                        'desc'  => 'Use arclength error',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'count' => {
                        'desc'  => 'Maximum number of points in route',
                        'type'  => 'integer',
                        'valid' => [ '', '1' ]
                    },
                    'crosstrack' => {
                        'desc'  => 'Use cross-track error (default)',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'error' => {
                        'desc'  => 'Maximum error',
                        'type'  => 'string',
                        'valid' => [ '', '0' ]
                    }
                },
                'desc' => 'Simplify routes'
            },
            'sort' => {
                'options' => {
                    'shortname' => {
                        'desc'  => 'Sort by waypoint short name',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'time' => {
                        'desc'  => 'Sort by time',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'gcid' => {
                        'desc'  => 'Sort by numeric geocache ID',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'description' => {
                        'desc'  => 'Sort by waypoint description',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Rearrange waypoints by resorting'
            },
            'nuketypes' => {
                'options' => {
                    'waypoints' => {
                        'desc'  => 'Remove all waypoints from data stream',
                        'type'  => 'boolean',
                        'valid' => ['0']
                    },
                    'routes' => {
                        'desc'  => 'Remove all routes from data stream',
                        'type'  => 'boolean',
                        'valid' => ['0']
                    },
                    'tracks' => {
                        'desc'  => 'Remove all tracks from data stream',
                        'type'  => 'boolean',
                        'valid' => ['0']
                    }
                },
                'desc' => 'Remove all waypoints, tracks, or routes'
            },
            'interpolate' => {
                'options' => {
                    'distance' => {
                        'desc'  => 'Distance interval in miles or kilometers',
                        'type'  => 'string',
                        'valid' => []
                    },
                    'time' => {
                        'desc'  => 'Time interval in seconds',
                        'type'  => 'integer',
                        'valid' => [ '', '0' ]
                    },
                    'route' => {
                        'desc'  => 'Interpolate routes instead',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Interpolate between trackpoints'
            },
            'duplicate' => {
                'options' => {
                    'shortname' => {
                        'desc'  => 'Suppress duplicate waypoints based on name',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'correct' => {
                        'desc'  => 'Use coords from duplicate points',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'location' => {
                        'desc' => 'Suppress duplicate waypoint based on coords',
                        'type' => 'boolean',
                        'valid' => []
                    },
                    'all' => {
                        'desc'  => 'Suppress all instances of duplicates',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Remove Duplicates'
            },
            'polygon' => {
                'options' => {
                    'file' => {
                        'desc'  => 'File containing vertices of polygon',
                        'type'  => 'file',
                        'valid' => []
                    },
                    'exclude' => {
                        'desc'  => 'Exclude points inside the polygon',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Include Only Points Inside Polygon'
            },
            'arc' => {
                'options' => {
                    'distance' => {
                        'desc'  => 'Maximum distance from arc',
                        'type'  => 'float',
                        'valid' => []
                    },
                    'points' => {
                        'desc'  => 'Use distance from vertices not lines',
                        'type'  => 'boolean',
                        'valid' => []
                    },
                    'file' => {
                        'desc'  => 'File containing vertices of arc',
                        'type'  => 'file',
                        'valid' => []
                    },
                    'exclude' => {
                        'desc'  => 'Exclude points close to the arc',
                        'type'  => 'boolean',
                        'valid' => []
                    }
                },
                'desc' => 'Include Only Points Within Distance of Arc'
            }
        }
    };

    @tests = (
        {
            name    => 'Broken gpsbabel',
            args    => [ 'bork', 0 ],
            version => '0.0.0',
            info    => {
                formats => {},
                for_ext => {},
                filters => {},
            },
        },
        {
            name    => 'gpsbabel 1.2.5',
            args    => [ '1.2.5', 0 ],
            version => '1.2.5',
            info    => {
                formats => {},
                for_ext => {},
                filters => {},
            },
            actions => [
                {
                    comment => 'No auto conversion',
                    method  => 'convert',
                    args    => [ 'in.kml', 'out.gpx' ],
                    error   => qr/No format handles/,
                },
                {
                    comment => 'Format specified',
                    method  => 'convert',
                    args    => [
                        'in.kml', 'out.gpx',
                        { in_format => 'kml', out_format => 'gpx' }
                    ],
                    expect => [
                        '-p',  '',   '-r',     '-t', '-w',  '-i',
                        'kml', '-f', 'in.kml', '-o', 'gpx', '-F',
                        'out.gpx'
                    ],
                },
            ],
        },
        {
            name    => 'gpsbabel 1.3.0',
            args    => [ '1.3.0', 0 ],
            version => '1.3.0',
            info    => $ref_info,
            actions => [
                {
                    comment => 'Format guessed',
                    method  => 'convert',
                    args    => [ 'in.kml', 'out.gpx', ],
                    expect  => [
                        '-p',  '',   '-r',     '-t', '-w',  '-i',
                        'kml', '-f', 'in.kml', '-o', 'gpx', '-F',
                        'out.gpx'
                    ],
                },
                {
                    comment => 'Format specified',
                    method  => 'convert',
                    args    => [
                        'in.kml', 'out.gpx',
                        { in_format => 'kml', out_format => 'gpx' }
                    ],
                    expect => [
                        '-p',  '',   '-r',     '-t', '-w',  '-i',
                        'kml', '-f', 'in.kml', '-o', 'gpx', '-F',
                        'out.gpx'
                    ],
                },
            ],
        },
    );

    my $count = 4 + @tests * 7;

    for my $test ( @tests ) {
        $count += 2 * @{ $test->{actions} || [] };
    }

    plan tests => $count;
}

my $dump = File::Spec->catfile( File::Spec->tmpdir, "babel-test-$$" );

sub get_fake {
    return [ $^X, File::Spec->catfile( 't', 'fake-babel.pl' ), $dump, @_ ];
}

sub deeply {
    my ( $got, $want, $msg ) = @_;
    unless ( is_deeply $got, $want, $msg ) {
        diag( Data::Dumper->Dump( [$got],  ['$got'] ) );
        diag( Data::Dumper->Dump( [$want], ['$want'] ) );
    }
}

# Get the arguments that were passed to gpsbabel
sub get_args {
    our $args;
    eval "require '$dump'";
    die "Can't require $dump ($@)" if $@;
    return $args;
}

{
    ok my $babel = GPS::Babel->new( { exename => get_fake( 'bork', 1 ) } ),
      'create ok';
    isa_ok $babel, 'GPS::Babel';
    eval { $babel->check_exe };
    ok !$@, 'check exe OK';

    my $version = eval { $babel->version };
    like $@, qr/failed/, 'error OK';
}

for my $test ( @tests ) {
    my $name = $test->{name};
    my $exe  = get_fake( @{ $test->{args} } );
    ok my $babel = GPS::Babel->new( { exename => $exe } ), "$name: create OK";
    isa_ok $babel, "GPS::Babel";
    eval { $babel->check_exe };
    ok !$@, "$name: check exe OK";

    my $version = $babel->version;
    is $version, $test->{version}, "$name: version OK";

    my $info = $babel->get_info;
    ok defined delete $info->{banner},  "$name: got banner OK";
    ok defined delete $info->{version}, "$name: got banner OK";

    deeply( $info, $test->{info}, "$name: get_info OK" );

    if ( my $actions = $test->{actions} ) {
        for my $spec ( @$actions ) {
            my $method  = delete $spec->{method};
            my $comment = delete $spec->{comment};
            my $result  = eval { $babel->$method( @{ $spec->{args} } ) };
            if ( my $error = $spec->{error} ) {
                like $@, $error, "$name, $comment: $method throws error";
                pass "$name: arg check skipped";
            }
            else {
                unless ( ok !$@, "$name, $comment: $method OK" ) {
                    diag "Got error: $@";
                }
                deeply(
                    get_args(),
                    $spec->{expect} || {},
                    "$name, $comment: gpsbabel args match"
                );
            }
        }
    }
}

unlink $dump;
