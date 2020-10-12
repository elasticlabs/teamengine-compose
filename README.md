# teamengine-compose
OGC TEAMEngine docker-compose automated deployment

#### Preparation :
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)

#### Repository clone & application build
* Clone this repository and go to the `teamengine-compose` directory.
* Build the application using `sudo make build && sudo make proxy-up && sudo make wait && sudo make up`

#### Basic administration commands
* `make proxy-up` -> Initialize front proxy entrypoint
* `make up` ->  With working proxy, brings up the SDI
* `make build-ets` -> Build OGC Web services ETS
* `make build` -> Checks needs for ETS suites creation & Build TEAMEngine
* `make update` -> Update the whole stack