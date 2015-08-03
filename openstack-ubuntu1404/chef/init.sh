# install base packages
sudo apt-get -y update
sudo apt-get -y -qq upgrade
sudo apt-get -y -qq install bash curl git build-essential bison openssl vim wget libx11-dev libx11-doc libxcb1-dev python-virtualenv
export LANG="en_US.UTF-8"
git config --global url."https://".insteadOf git://

# chef
TMP_DIRECTORY=/tmp/vm-prepare
mkdir -p $TMP_DIRECTORY
cp ./standard_solo.json $TMP_DIRECTORY
cd $TMP_DIRECTORY
curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -v 11.16.2-1

# chef provisioning
mkdir -p $TMP_DIRECTORY/assets/cache
cat > $TMP_DIRECTORY/assets/solo.rb <<EOF
log_location STDOUT
file_cache_path File.join(File.expand_path(File.dirname(__FILE__)), "cache")
cookbook_path [ "/tmp/vm-prepare/travis-cookbooks/ci_environment" ]
EOF

rm -rf $TMP_DIRECTORY/travis-cookbooks
curl -L https://api.github.com/repos/travis-ci/travis-cookbooks/tarball/28a024a6e45d04ae495ebc8fe7a1cffc12f45c8b | tar xvfz -
mv $TMP_DIRECTORY/travis-ci-travis-cookbooks-* $TMP_DIRECTORY/travis-cookbooks

sudo chef-solo -c $TMP_DIRECTORY/assets/solo.rb -j $TMP_DIRECTORY/standard_solo.json

