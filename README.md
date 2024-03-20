# README

## SSH Login

Add the following lines to your `~/.ssh/config` file:
```
Host nccu-bastion-2
        User ec2-user
        Port 22
        ForwardAgent yes
        HostName xx.xx.xx.xx  # Find this in AWS
        IdentitiesOnly yes
        IdentityFile ~/.ssh/find-this-file-at-trln.pem

Host nccu-argon-3
        User ec2-user
        Port 22
        ForwardAgent yes
        HostName xx.xx.xx.xx  # Find this in AWS
        IdentitiesOnly yes
        IdentityFile ~/.ssh/find-this-file-at-trln.pem
        ProxyJump nccu-bastion-2
```
## Deploy updates:
Navigate to your ~/.ssh directory and run the following commands:
```
cd ~/.ssh
ssh nccu-argon-3
sudo -u nccu -H bash -l
cd /var/www/nccu-blacklight/code
git pull
bundle install --deployment --without development test
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
passenger-config restart-app
```