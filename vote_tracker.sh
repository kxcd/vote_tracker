#!/bin/bash
#set -x

#curl -s https://www.dashcentral.org/api/v1/budget| awk -F"\"name" '{for(i=2;i<=NF;i++){{print $i}}}'|
#cut -f2 -d":"|cut -f1 -d","|sed -e s/\"//g>current_props.txt

date=$(date +"%Y%m%d%H%M")
curl -s https://www.dashcentral.org/api/v1/budget|
awk -F"\"name" -v date=$date '{for(i=2;i<=NF;i++){{print date"\t"$i}}}'|
cut -f1-2 -d":"|cut -f1 -d","|sed -e s/[\":]//g>>current_props.txt



gobject_list=$(dash-cli gobject list)



##  List of tab separated fields
# date
# hash
# AbsoluteYesCount
# AbstainCount
# CollateralHash
# CreationTime
# IsValidReason
# NoCount
# ObjectType
# YesCount
# fBlockchainValidity
# fCachedDelete
# fCachedEndorsed
# fCachedFunding
# fCachedValid
# end_epoch
# name
# payment_address
# payment_amount
# start_epoch
# type
# url



echo "$gobject_list"|jq '.[].Hash'|while read;do
	#echo "$REPLY" 1>&2
	AbsoluteYesCount=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.AbsoluteYesCount")
	AbstainCount=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.AbstainCount")
	CollateralHash=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.CollateralHash"|sed 's/"//g')
	CreationTime=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.CreationTime")
	IsValidReason=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.IsValidReason"|sed 's/"//g')
	NoCount=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.NoCount")
	ObjectType=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.ObjectType")
	YesCount=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.YesCount")
	fBlockchainValidity=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.fBlockchainValidity")
	fCachedDelete=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.fCachedDelete")
	fCachedEndorsed=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.fCachedEndorsed")
	fCachedFunding=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.fCachedFunding")
	fCachedValid=$(echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.fCachedValid")
	hash=$(echo "$REPLY"|sed 's/"//g')
	echo -en "$date\t$hash\t$AbsoluteYesCount\t$AbstainCount\t$CollateralHash\t$CreationTime\t$IsValidReason\t$NoCount\t$ObjectType\t$YesCount\t$fBlockchainValidity\t$fCachedDelete\t$fCachedEndorsed\t$fCachedFunding\t$fCachedValid"
#	echo;echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.DataString";echo
	echo "$gobject_list"|jq ".[] | select(.Hash==$REPLY)|.DataString"|
	sed 's/\\"/"/g;s/^.*end_epoch/end_epoch/g;s/":/\t/g;s/,"/\t/g;s/"//g;s/}[]]*$//'|
#	sed 's/\\"/"/g;s/^"\[\["proposal",{//g;s/....$//g;s/":/\t/g;s/,"/\t/g;s/"//g'|
	sed 's/^end_epoch//g;s/	name//g;s/	payment_address//g;s/	payment_amount//g;s/	start_epoch//g;s/	type//g;s/	url//g;'
done|sed '/0000000000000000000000000000000000000000000000000000000000000000/d'>>proposals.txt




proposals=$(echo "$gobject_list" |grep "{"|grep -v "DataString"|cut -f2 -d"\""|grep -v "{")

#>prop_votes.txt


# Grabbing the vote text.
echo "$proposals"|while read ;do
	#echo "$REPLY"
	#prop_vote["$REPLY"]=$(dash-cli gobject getcurrentvotes "$REPLY")
	dash-cli gobject getcurrentvotes $REPLY|grep -v [{}]|sed 's/,$//g;s/[" ]//g;s/:/\t/g'|sed "s/\(.*\)/$date\t$REPLY\t\1/g">>prop_votes.txt
done

