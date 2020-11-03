# teamengine-compose
OGC TEAMEngine docker-compose automated deployment

Get an automated TEAMEngine with most common test suites up and running in minutes without headache!
For information on available **Test Suites & leads**, head to `https://github.com/opengeospatial/cite/wiki/Overview-of-Test-Suites-and-Test-Leads`

Tis software stack relies on an automated NTTPS Nginx reverse proxy
* Deployment behind an automated HTTPS proxy (see `https://github.com/nginx-proxy/nginx-proxy` for more information) : `docker-compose.nginx-proxy.yml`

## Docker environment preparation 
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)

#### TEAMEngine deployment preparation :
* Ensure that appropriate DNS record for `teamengine` base URL is created and resolve well. 
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* GIT clone this repository `git clone https://github.com/elasticlabs/teamengine-compose.git`
* Choose & configure a selected DNS name (e.g. `teamengine.your-awesome-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands
* Modify `docker-compose.yml` and `docker-compose.proxy.yml` in order to setup the `VIRTUAL_HOST` parameter to match your choosen DNS TEAMEngine record
* Create the `te-proxy` network -> `sudo docker network create te-proxy`
* Attach the new network to the existing `nginx-proxy` container to ensure proper proxy operations -> `sudo docker network connect te-proxy <nginx-proxy container name>`

#### Repository clone & application build
* Build the application using `sudo make build && sudo make proxy-up && sudo make wait && sudo make up`
* or.... `make proxy-up && make up`
* or.... `make build` to get confident, the `make up` and `make clean`
* Then, head to **`http://teamengine.your-awesome-domain.ltd/app`** and enjoy TEAMENgine test suites!

#### Basic admin commands
* `make up` ->  With working proxy, brings up the SDI
* `make build` -> Checks needs for ETS suites creation & Build TEAMEngine
* `make update` -> Update the whole stack
* `make clean` -> Do some Docker cleanup within containers, images, and volumes