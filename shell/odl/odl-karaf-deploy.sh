#/bin/bash
# require java 1.7 home, unzip, wget tools

odl_file="distribution-karaf-0.2.1-Helium-SR1"
odl_url="http://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.1-Helium-SR1/$odl_file.zip"
odl_page_url="http://localhost:8181/dlux/index.html" 
maxTimes=10

#export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_60.jdk/Contents/Home"
export JAVA_OPTS="-Xmx4096m -XX:MaxPermSize=512m"

bash "$odl_file/bin/stop" 
j=$(ps -a | grep -ir karaf )   
  if [ "$j" != "" ] ;then
     set $j    
     kill $1       
  else 
     echo "No karaf running"      
  fi  
rm -rf "$odl_dir"
wget "$odl_url" 
unzip -o "$odl_file.zip" 
rm -rf "$odl_file.zip"
cp -f org.apache.karaf.features.cfg "$odl_file/etc/"
bash "$odl_file/bin/start" 

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

  j=$(ps -a | grep -ir curl )   
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
