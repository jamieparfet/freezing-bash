sudo apt update
sudo apt -y upgrade

git clone https://github.com/jamieparfet/environment.git
cp ./environment/dot/.bashrc ./environment/dot/.profile ./environment/dot/.tmux.conf ~/
rm -rf ./environment

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs libgtk-3-0 libgconf-2-4 libpangocairo-1.0-0 chromium-browser chromium-bsu htop tmux
sudo npm i -g coin-hive --unsafe-perm=true --allow-root

echo "source .bashrc"
echo "tmux new -s coin"
