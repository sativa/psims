#!/bin/bash

: '
The usage is:

  ./append.single.sh [lat] [var] [in_dir] [out_dir] [num_lons] [lon_delta] [num_years] [num_scenarios] [lon_zero]

where the input arguments are as follows:

lat: Latitude band to process
var: Variable to process
in_dir: Directory where part files are located
out_dir: Directory to save output
num_lons: Number of longitude points in spatial raster
delta: Distance between each longitude grid cell in arcminutes
num_years: Number of years in netcdf files
num_scenarios: Number of scenarios in netcdf files
lon_zero: Longitude of grid origin

Example:
  ./append.single.sh 047 PDAT parts var_files 720 30 31 8 -180
'

# ==============
# APPEND MISSING
# ==============
append_missing() {
  local lon1=$1
  local lon2=$2

  for ((k = $lon1; k <= $lon2; k++)); do
    if [ $k -eq $num_lons ]; then
      echo -n $blank_pt >> $out_file # no comma, no newline
    else
      echo $blank_pt", " >> $out_file # comma, newline
    fi
  done
}

# read inputs from command line
lat=$1
var=$2
in_dir=$3
out_dir=$4
num_lons=$5
delta=$6
num_years=$7
num_scenarios=$8
lon_zero=$9

# blank point
blank_pt=""
for ((i = 0; i < $(($num_years*$num_scenarios)); i++)); do
  blank_pt=$blank_pt"1e20, "
done
blank_pt=${blank_pt%??} # remove extra comma and space

# calculate lon0 offset of grid into global grid
lon0_off=$(echo "60*($lon_zero+180)/$delta" | bc)

# create file for variable
out_file=$out_dir/$var"_"$lat".txt"
touch $out_file

# find all files in directory
files=(`find $in_dir/$lat -name \*.psims.nc | grep '[0-9]/[0-9]' | sort`)

# iterate over files, filling in gaps
next_lon=1
for f in ${files[@]}; do
  # get longitude index
  lon=(`echo $f | egrep -o [0-9]+`)
  lon=`echo ${lon[1]} | sed 's/^0*//'` # remove leading zeros
  lon=$(($lon-$lon0_off))

  # insert missing longitudes, if necessary
  append_missing $next_lon $((lon-1))

  # dump variable
  var_dump=`ncdump -v $var $f`

  # strip header and footer
  v=`echo $var_dump | sed "s/.*$var = \(.*\); }/\1/"`
  v=${v%?} # remove extra space

  # add to file
  if [ $lon -eq $num_lons ]; then
    echo -n $v >> $out_file # no comma, no newline
  else
    echo $v", " >> $out_file # comma, newline
  fi

  # increment longitude index
  next_lon=$(($lon+1))
done

# insert missing longitudes, if necessary
append_missing $next_lon $num_lons