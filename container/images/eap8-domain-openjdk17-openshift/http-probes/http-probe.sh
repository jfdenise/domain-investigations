#!/bin/sh

systime=$(date +%s.%N)
reply_file=reply-$systime.json
CURL="curl -s -o $reply_file"
INVALID="JBOSS_EAP-HTTP-PROBE-INVALID-REPLY"

if [ -n "${ADMIN_USERNAME}" -a -n "${ADMIN_PASSWORD}" ]; then
  CURL="$CURL --digest -u ${ADMIN_USERNAME}:${ADMIN_PASSWORD}"
fi

function get_result() {
  if [ -f $reply_file ]; then
    outcome=$(jq '.outcome' $reply_file)
    result=$(jq '.result' $reply_file)
    if [ "$outcome" == "\"success\"" ]; then
      echo "$result"
    else
      echo $INVALID
    fi
  else
   echo $INVALID
  fi
}

function send() {
  rm -rf $reply_file
  $CURL localhost:9990/management --header "Content-Type: application/json" -d $1
  if [ $? -ne 0 ]; then
    rm -rf $reply_file
    exit 1
  fi
}

send '{"operation":"read-attribute","address":["host","'"${JBOSS_EAP_DOMAIN_HOST_NAME}"'","server","'"${JBOSS_EAP_DOMAIN_SERVER_NAME}"'"],"name":"server-state"}'
ret=$(get_result)
if [ "$ret" == "$INVALID" ]; then
 echo "Invalid server reply"
 rm -rf $reply_file
 exit 1
fi

if [ "$ret" != "\"running\"" ]; then
  echo "Invalid server state $ret"
  rm -rf $reply_file
  exit 1
else
  echo "Valid server state $ret"
fi

send '{"operation":"read-attribute","address":["host","'"${JBOSS_EAP_DOMAIN_HOST_NAME}"'","server","'"${JBOSS_EAP_DOMAIN_SERVER_NAME}"'"],"name":"running-mode"}'
ret=$(get_result)
if [ "$ret" == "$INVALID" ]; then
 echo "Invalid server reply"
 rm -rf $reply_file
 exit 1
fi

if [ "$ret" != "\"NORMAL\"" ]; then
  echo "Invalid server running mode $ret"
  rm -rf $reply_file
  exit 1
else
  echo "Valid running mode $ret"
fi

send '{"operation":"read-boot-errors","address":["host","'"${JBOSS_EAP_DOMAIN_HOST_NAME}"'","server","'"${JBOSS_EAP_DOMAIN_SERVER_NAME}"'","core-service","management"]}'
ret=$(get_result)
if [ "$ret" == "$INVALID" ]; then
 echo "Invalid server reply"
 rm -rf $reply_file
 exit 1
fi

if [ "$ret" != "[]" ]; then
  echo "Boot errors found: $ret"
  rm -rf $reply_file
  exit 1
else
  echo "Valid boot errors $ret"
fi

send '{"operation":"read-attribute","address":["host","'"${JBOSS_EAP_DOMAIN_HOST_NAME}"'","server","'"${JBOSS_EAP_DOMAIN_SERVER_NAME}"'","deployment","*"],"name":"status","json.pretty":1}'
ret=$(get_result)

if [ "$ret" == "$INVALID" ]; then
 echo "Invalid server reply"
 rm -rf $reply_file
 exit 1
fi

jq -c '.[]' <<< $ret | while read i; do
   outcome=$(jq '.outcome' <<< $i)
   result=$(jq '.result' <<< $i)
   if [ "$outcome" != "\"success\"" ]; then
     echo "Invalid deployment reply $i"
     rm -rf $reply_file
     exit 1
   fi
   if [ "$result" != "\"OK\"" ]; then
     echo "Invalid deployment status $i"
     rm -rf $reply_file
     exit 1
   fi
   echo "Valid deployment $i"
done
rm -rf $reply_file

