#!/bin/bash


channel_id=$1
token=$2
file_path=$3
$mattermost_url=$4


echo "channel id :"$channel_id
echo "token :"$token
echo "message :"$message
echo "file_path :"$file_path

 post_file_request=$(curl  -F "files=@$file_path" -F "channel_id=$channel_id" --header "authorization: Bearer $token" --silent --write-out "HTTPSTATUS:%{http_code}"  $mattermost_url/api/v4/files ) 
# extract the body
post_file_request_body=$(echo $post_file_request | sed -e 's/HTTPSTATUS:.*//g' )
# extract the status
post_file_request_status=$(echo $post_file_request | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo "$post_file_request_body"
echo "$post_file_request_status"
if [  ! "$post_file_request_status" -eq "201"   ]; then
  echo "Error [HTTP status: $post_file_request_status]"
  exit 1
else 
echo "File is uploaded Right now"

file_id=$(echo $post_file_request_body | grep  -oP '(?<="id":)\"(.*?)\"')

echo "file_id is : $file_id"

create_post_request=$(curl --request POST --silent --write-out "HTTPSTATUS:%{http_code}" --header "authorization: Bearer $token" --header 'Content-Type: application/json' --data '{
    "channel_id": "'$channel_id'",
    
    "file_ids": [ '$file_id' ]}' --url $mattermost_url/api/v4/posts )

echo "$create_post_request"
create_post_request_body=$(echo "$create_post_request" | sed -e 's/HTTPSTATUS:.*//g' )

create_post_request_status=$(echo $create_post_request | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

echo "create_post_request_status:"$create_post_request_status
if [ ! "$create_post_request_status" -eq "201" ]; then
  echo "Error [HTTP status: $create_post_request_status]"
  exit 1
else 
  echo "Success [HTTP status: $create_post_request_status]"
  exit 0
fi
fi 
fi
