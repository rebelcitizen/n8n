

PERSISTANT_CONFIG_FOLDER=$(pwd)/n8n-config
ORIGINAL_CONFIG_FOLDER=~/.n8n


echo "Loading..."
rm -r -f $ORIGINAL_CONFIG_FOLDER
mkdir $PERSISTANT_CONFIG_FOLDER &> /dev/null # make directory if not exist

# Creating sysmlink between persistant config folder and original config folder
ln -s $PERSISTANT_CONFIG_FOLDER $ORIGINAL_CONFIG_FOLDER