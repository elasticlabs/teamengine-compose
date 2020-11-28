# TEAMEngine docker composition suite
OGC TEAMEngine docker-compose automated deployment, including most common test suites up and running in minutes!

## Docker environment preparation 
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)
* This software stack relies on an automated NTTPS Nginx reverse proxy. Please refer to [our Elasticlabs official Let'sencrypt HTTPS repository](https://github.com/elasticlabs/https-nginx-proxy-docker-compose) for how to setup your own + Clean portainer admin dashboard for your containers.

#### TEAMEngine deployment preparation :
* Choose & configure a selected DNS name (e.g. `teamengine.your-awesome-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* GIT clone this repository `git clone https://github.com/elasticlabs/teamengine-compose.git`
* Modify `docker-compose.yml` in order to setup the `VIRTUAL_HOST` parameter to match your choosen DNS TEAMEngine record
* Create the `te-proxy` network -> `sudo docker network create te-proxy`
* Attach the new network to the existing `nginx-proxy` container to ensure proper proxy operations -> `sudo docker network connect te-proxy <nginx-proxy container name>`

#### Build and run the TEAMEngine application
* Build the application using `sudo make build` to get confident, the `make up`
* Head to **`http://teamengine.your-awesome-domain.ltd/app`** and enjoy TEAMENgine test suites!

#### Basic admin commands
* `make up` ->  With working proxy, brings up the SDI
* `make build` -> Checks needs for ETS suites creation & Build TEAMEngine
* `make update` -> Update the whole stack
* `make clean` -> Do some Docker cleanup within containers, images, and volumes