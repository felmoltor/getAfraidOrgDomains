#!/bin/bash

# This script queries for free domain names to afraid.org to help you introduce them in your blacklists
# A big part of those domains are used for phising and C&C.

OUTPUTFOLDER="."
PUBLICOUTPUT="$OUTPUTFOLDER/results/public.afraid.org.domains.list"
PRIVATEOUTPUT="$OUTPUTFOLDER/results/private.afraid.org.domains.list"
NPAGES=1005

if [[ "$1" != "" ]];then
    echo "Exploring the first $1 pages of afraid.org domain registry"
    NPAGES=$1
fi

if [[ "$2" != "" ]];then
    # Delete trailing slash if it has one
    echo "Saving output in folder $2"
    OUTPUTFOLDER=$2
    lastchar=${OUTPUTFOLDER:${#OUTPUTFOLDER} - 1}
    if [ $lastchar == "/" ];then
        OUTPUTFOLDER=${OUTPUTFOLDER:0:$((${#OUTPUTFOLDER}-1))}
    fi
    PUBLICOUTPUT="$OUTPUTFOLDER/results/public.afraid.org.domains.list"
    PRIVATEOUTPUT="$OUTPUTFOLDER/results/private.afraid.org.domains.list"
fi

###############
# CREATE DIRS #
###############
if [[ ! -d $OUTPUTFOLDER ]]; then
    echo "Creating output folder hierarchy $OUTPUTFOLDER..."
fi
if  [[ ! -d "$OUTPUTFOLDER/tmp" ]]; then
    mkdir -p "$OUTPUTFOLDER/tmp"
fi
if  [[ ! -d "$OUTPUTFOLDER/results" ]]; then
    mkdir -p "$OUTPUTFOLDER/results"
fi

######################
# FLUSH RESULT FILES #
######################
echo -n "" > "$OUTPUTFOLDER/results/afraid.org.domains.csv" 
echo -n "" > $PUBLICOUTPUT 
echo -n "" > $PRIVATEOUTPUT 

###################
# VISIT THE PAGES #
###################
echo ""
echo "Harvesting the public and private domains of afraid.org. Please be patient..."
for i in $(seq 1 $NPAGES); do 
    modulo=$(($i%10))
    if [ $modulo == 0 ];then
        echo "Downloading HTML output to file $OUTPUTFOLDER/tmp/afraidorg.$i.html ($i/$NPAGES)"
    fi
    curl -s -o "$OUTPUTFOLDER/tmp/"afraidorg.$i.html https://freedns.afraid.org/domain/registry/page-$i.html
done
# Once queried explore the output to get only the domain names

####################
# PARSE THE OUTPUT #
####################
echo ""
echo "Extracting info from output HTML files..."
echo "Domain:Host in use:Visibility" >> "$OUTPUTFOLDER/results/afraid.org.domains.csv" 
for i in $(seq 1 $NPAGES); do
    modulo=$(($i%10))
    if [ $modulo == 0 ];then
        echo "Parsing file $OUTPUTFOLDER/tmp/afraidorg.$i.html ($i/$NPAGES)"
    fi
    grep "<a href=/subdomain/edit.php?edit_domain_id=" "$OUTPUTFOLDER/tmp/"afraidorg.$i.html | sed 's/^.*edit_domain_id=[[:digit:]]\{1,\}>\(.*\)<\/a><br><span> (\([[:digit:]]\{1,\}\) hosts in use).*<td>\(public\|private\)<\/td>.*$/\1:\2:\3/g' >> "$OUTPUTFOLDER/results/afraid.org.domains.csv" 
done

###########################
# EXTRACTING DOMAINS ONLY #
###########################
echo ""
echo "Extracting only domains names to $OUTPUTFOLDER/results/..."
grep -i -E ":public$" "$OUTPUTFOLDER/results/afraid.org.domains.csv" | cut -f1 -d':'  >> $PUBLICOUTPUT
grep -i -E ":private$" "$OUTPUTFOLDER/results/afraid.org.domains.csv" | cut -f1 -d':' >> $PRIVATEOUTPUT

###########################
# DELETING TEMPORAL FILES #
###########################
echo ""
echo "Sacando la basura de casa..."
rm -rf "$OUTPUTFOLDER/tmp/"
