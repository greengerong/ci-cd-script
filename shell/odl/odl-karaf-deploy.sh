#/bin/bash
# require java 1.7 home, unzip, wget tools

odl_file="distribution-karaf-0.2.1-Helium-SR1"
odl_url="http://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.1-Helium-SR1/$odl_file.zip"
odl_page_url="http://localhost:8181/dlux/index.html" 
maxTimes=10

#export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_60.jdk/Contents/Home"
export JAVA_OPTS="-Xmx4096m -XX:MaxPermSize=512m"


j=$(ps -a | grep -i karaf )   
  if [ "$j" != "" ] ;then
     bash "$odl_file/bin/stop"
     set $j    
     kill $1  
     echo -e "kill karaf server...." 
  else 
     echo "No karaf running"      
  fi  

rm -rf "./$odl_file"
echo -e "delete $odl_file....." 
wget "$odl_url" 
unzip -o -q "$odl_file.zip" 
echo -e "unzip $odl_file.zip finish......"
rm -rf "$odl_file.zip"
cp -f org.apache.karaf.features.cfg "$odl_file/etc/"
bash "$odl_file/bin/start" 

echo "Wait for odl page started....."

sleep 15

times=1
while [ $times -le $maxTimes ]
do
  echo "($times time) try to get the url $odl_page_url"
  http_code=$(curl -o templ/response -s -w %{http_code} $odl_page_url) #http://xxx.com
  if [ $http_code != 200 ] ;then
    echo "Got server response with $http_code. "
    times=$[ $times + 1 ]
    sleep 60
  else 
    echo "Server was response $http_code."
    break
  fi

  j=$(ps -a | grep -i curl )   
  if [ "$j" != "" ] ;then
     set $j    
     kill $1       
  else 
     echo "No curl running"      
  fi  
done

if [  $times -gt $maxTimes ]; then
    echo -e "Try to deploy the opendaylight karaf error."
    exit 1
else
   echo -e "Deploy the opendaylight karaf success."
   exit 0
fi
