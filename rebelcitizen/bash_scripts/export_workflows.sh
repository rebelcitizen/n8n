export PATH=$PATH:$(pwd)/node_modules/.bin

source config.sh
bash persistent.sh


echo "Exporting Workflows"

cd bin

python export_n8n_items.py -o ./exports --decrypted