for i in $(seq 1 100); do
  curl -s -o /dev/null "http://211.253.25.128.sslip.io:30453/productpage"
done