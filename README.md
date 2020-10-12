# teamengine-compose
OGC TEAMEngine docker-compose automated deployment

Get an automated TEAMEngine with most common test suites up and running in minutes without headache!

**TODO** : finalize HTTPS proxy 

For information on available **Test Suites & leads**, head to `https://github.com/opengeospatial/cite/wiki/Overview-of-Test-Suites-and-Test-Leads`

#### Preparation :
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* GIT clone this repository `git clone https://github.com/elasticlabs/teamengine-compose.git`
* Choose & configure a selected DNS name (e.g. `teamengine.your-awesome-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands
* Modify `docker-compose.yml` and `docker-compose.proxy.yml` in order to setup the `VIRTUAL_HOST` parameter to match your choosen DNS TEAMEngine record

#### Repository clone & application build
* Clone this repository and go to the `teamengine-compose` directory.
* Build the application using `sudo make build && sudo make proxy-up && sudo make wait && sudo make up`
* or.... `make proxy-up && make up`
* or.... `make build` to get confident, the `make up` and `make clean`

#### Basic admin commands
* `make proxy-up` -> Initialize front proxy entrypoint
* `make up` ->  With working proxy, brings up the SDI
* `make build` -> Checks needs for ETS suites creation & Build TEAMEngine
* `make update` -> Update the whole stack
* `make clean` -> Do some Docker cleanup within containers, images, and volumes