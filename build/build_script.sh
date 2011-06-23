#! /bin/sh -x

############################################################################
#
# MODULE:       osmphgarmin map build script
#
# AUTHOR(S):    Emmanuel Sambale esambale@yahoo.com emmanuel.sambale@gmail.com
#
# PURPOSE:      Shell script for creating Garmin maps from OSM data.
#               Requires mkgmap, gmapi-builder python script, nsis. 
#
#               This program is free software under the GNU General Public
#               License (>=v2).
#
#############################################################################

#Set these directory paths

download_dir=------
output_dir=------
split_dir=------
download_link=---


#Nothing to change below
#===========
cd ${download_dir}

# Download from geofabrik site
wget -c ${download_link}
ls -al

# Split the file using splitter.jar
java -jar splitter.jar --max-nodes=1000000  philippines.osm.pbf --output-dir=${split_dir}

ls -al

# compile map with logging properties report
#time java -Dlog.config=logging.properties -Xmx2012m -jar mkgmap.jar --read-config=args.list ${output_dir} 
time java -Xmx2012m -jar mkgmap.jar --read-config=args.list --series-name="OSM Philippines $(date +%Y%m%d)" --description="OSM Philippines $(date +%Y%m%d)" --output-dir=${output_dir} ~/osm/routable_garmin/dev/split/*.osm.pbf


# gmapsupp.img generation
time java -Xmx2012m -jar mkgmap.jar --read-config=args2.list ~/osm/routable_garmin/dev/split/*.osm.pbf ~/osm/routable_garmin/dev/MINIMAL.TYP

ls -al

zip osmph_img_latest_dev.zip gmapsupp.img


# Gmapi for Mac Roadtrip installer
python gmapi-builder -t ${output_dir}/40000001.tdb -b ${output_dir}/40000001.img -s ${output_dir}/MINIMAL.TYP -i ${output_dir}/40000001.mdx -m ${output_dir}/40000001_mdr.img ${output_dir}/*.img

ls -al
zip -r osmph_macroadtrip_latest_dev.zip "OSM Philippines $(date +%Y%m%d).gmapi"
#mv osmph_macroadtrip_latest_dev.zip /home/maning/osm/routable_garmin/dev/
rm -rf "OSM Philippines $(date +%Y%m%d).gmapi"

cd ${output_dir}

ls -al

# Win Mapsource installer
makensis osmph_mapsource_installer_.nsi
mv osmph_winmapsource_latest_.exe /home/maning/osm/routable_garmin/dev/osmph_winmapsource_latest_dev.exe

#temporary mv
#mv osmph_winmapsource_latest_.exe /home/maning/Downloads/osm/routable_garmin/data/

rm *.img 
rm *.mdx 
rm *.tdb 

cd ..
rm *.img 
rm *.tdb
rm *.mdx

date > log.txt

#Miscellaneous

cd ${download_dir}

# upload to server
# archiving downloaded philippine osm file
mv philippines.osm.pbf archive/philippines_$(date +%Y%m%d).osm.pbf

