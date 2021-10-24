# Yandex Cloud instructions

## Contents

* [Install tools](#install-tools)
* [Credentials](#credentials)
* [Deploying image](#deploying-image)
* [Using YC instance](#using-yc-instance)

* * *


## Install tools

Install Yandex Cloud CLI
```sh
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh
chmod +x install.sh
./install.sh -a
source "~/.bashrc"
```

Install Amazone AWS CLI
It is needed to upload images to the Yandex S3 storage

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## Credentials

Getting and setting up login details
* Login to Yandex Cloud Console and accept license agreement
* Get Yandex OAuth token https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb
* `yc init`

Setting up AWS CLI
* Create YC service account `yc iam service-account create --name ycaltrobot`
* Get Service Account ID from `yc iam service-account get ycaltrobot`
* `yc resource-manager cloud add-access-binding <cloud_name> --role resource-manager.clouds.owner --subject serviceAccount:<service_account_id>`
* Create static key for AWS CLI `yc iam access-key create --service-account-name ycaltrobot`
* `aws configure`
  * `AWS Access Key ID` = <key_id>
  * `AWS Secret Access Key` = \<secret\>
  * `Default region name` = ru-central1 (only this region)
  * `Default output format` = \<enter\>

## Deploying image

Upload qcow2 image to YC S3 Storage
```sh
aws --endpoint-url=https://storage.yandexcloud.net s3 cp qemu-alt-server-9.1-x86_64/qemu-alt-server-9.1-x86_64 s3://alt-distr/qemu-alt-server-9.1-x86_64
```
  
Create YC disk image
```sh
yc compute image create --name "alt-server-9-1-x86-64" --source-uri "https://storage.yandexcloud.net/alt-distr/qemu-alt-server-9.1-x86_64" --family alt-server-9
```

## Using YC instance
  
Create test instance from uploaded image
```sh
yc compute instance create test-alt-server-9-1 --zone ru-central1-a --memory 3G --cores 2 --core-fraction 20  --platform standard-v3 --preemptible=true --public-ip=true --ssh-key ~/.ssh/id_rsa.pub --create-boot-disk image-family=alt-server-9-1-x86-64
```

Remove exiting instance
```sh
yc compute instance delete --name test-alt-server-9-1
```
