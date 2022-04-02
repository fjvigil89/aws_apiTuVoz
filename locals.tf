locals {
  docker_compose = <<-EOF
#!/bin/bash
# ---> Updating, upgrating and installing the base
version: '2'
services:
  api_tuvoz:
    image: fjvigil/api_tuvoz
    user: root
    command: "php artisan serve --host=0.0.0.0 --port=8080"
    restart: always             # run as a service
    ports:
      - 8080:8080

                EOF

user_data = <<-EOF
                #!/bin/bash
                # ---> Updating, upgrating and installing the base
                apt update
                apt install git python3-pip apt-transport-https ca-certificates curl software-properties-common nfs-common -y
                mkdir /var/lib/docker
                echo "${aws_efs_file_system.persistent.dns_name}:/  /var/lib/docker    nfs4   nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 2" >> /etc/fstab
                mount -a
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
                apt update && apt upgrade -y
                apt install docker.io docker-compose -y
                systemctl status docker
                usermod -aG docker ubuntu

                echo "${local.docker_compose}" >> docker-compose.yaml
                docker-compose up -d
                
                EOF

}