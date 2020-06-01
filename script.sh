#! /bin/bash
set -e # Stop script on error

echo "

                      Welcome to...

      ___           ___           ___           ___     
     /\  \         /\__\         /\  \         /\  \    
    /::\  \       /:/  /         \:\  \       /::\  \   
   /:/\:\  \     /:/  /           \:\  \     /:/\:\  \  
  /::\~\:\  \   /:/  /  ___       /::\  \   /:/  \:\  \ 
 /:/\:\ \:\__\ /:/__/  /\__\     /:/\:\__\ /:/__/ \:\__\\
 \/__\:\/:/  / \:\  \ /:/  /    /:/  \/__/ \:\  \ /:/  /
      \::/  /   \:\  /:/  /    /:/  /       \:\  /:/  / 
      /:/  /     \:\/:/  /     \/__/         \:\/:/  /  
     /:/  /       \::/  /                     \::/  /   
     \/__/         \/__/                       \/__/    
      ___           ___           ___           ___     
     /\  \         /\  \         /\  \         /\__\    
    /::\  \       /::\  \       /::\  \       /:/  /    
   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/__/     
  /::\~\:\  \   /::\~\:\  \   /:/  \:\  \   /::\  \ ___ 
 /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/ \:\__\ /:/\:\  /\__\\
 \/__\:\/:/  / \/_|::\/:/  / \:\  \  \/__/ \/__\:\/:/  /
      \::/  /     |:|::/  /   \:\  \            \::/  / 
      /:/  /      |:|\/__/     \:\  \           /:/  /  
     /:/  /       |:|  |        \:\__\         /:/  /   
     \/__/         \|__|         \/__/         \/__/    

                 
                 Press any key to continue.
"

# Don't start until user is ready
read ; echo

# show drives available
echo "Here are the drives that are seen by your system." ; echo


    if [ $1 -ge 18 ]
    then
    echo You may go to the party.
    elif [ $2 == 'yes' ]
    then
    echo You may go to the party but be back before midnight.
    else
    echo You may not go to the party.
    fi


# Set drive for installation
echo
echo "Which drive you wish to install to? "
echo "Your argument should have a format like this -> '/dev/sda'"
read -p "Enter the path to that drive that you wish to install to: " TGTDEV
