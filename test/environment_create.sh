#curl -u new:guest -v -i -H "Content-Type: text/xml" -H "Accept: application/json" -X POST -d '<thing><name>Linda</name></thing>' http://localhost:3000/environments/environment
curl -u new:guest -v -i -H "Content-Type: application/xml" -H "Accept: application/xml" -X POST -d '<thing><name>Linda</name></thing>' http://siftraining.dd.com.au/api/environments/environment
