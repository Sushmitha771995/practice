if [ -z "$1"]; then
  echo "enter json file name"
  exit 1
fi
 aws ec2 request-spot-fleet --spot-fleet-request-config file://$1
