# NGINX Rolling Update Demo

**Requirements:** Clone git repo and install Docker.

1. Start NGINX and the demo apps in Docker: `docker-compose up --build`  
This will start 5 docker containers: the NGINX load balancer and 4 sample apps (on different ports), as configured in docker-compose.yml.  
`--build` rebuilds the docker containers, if they are already created, so as to pick up any changes made to `docker-compose.yml`.

1. NGINX configuration:  
The `nginx.conf` defines the configuration for NGINX and is used to configure server groups and the load-balancing algorithm. The initial configuration in this file creates two server groups, one for the two nemo app instances (on port 11638) and one for the two grandma app instances (on port 11636).  
Because no load‑balancing algorithm is specified in the upstream block, NGINX uses the default algorithm, Round Robin, to route traffic between the two servers in each group.  

1. Go to the apps at `http://localhost:11638/` and `http://localhost:11636/`. Refresh the page multiple times and you will see each app switches between server A and server B.

1. Perform rolling update:  
Example: Execute the `rolling-update.sh` script from inside the load_balancer container.  
`docker-compose exec load_balancer /etc/nginx/rolling-update.sh a` 

- Run `./rolling-update.sh a` to edit and reload nginx.conf, routing all traffic to servers marked with '_a' in nginx.conf; all servers marked with '_b' will be marked as unavailable to new traffic.  
Go to the apps at `http://localhost:11638/` and `http://localhost:11636/`.  
Refresh the pages multiple times and you will see that the page always goes to server A.

- Run `./rolling-update.sh b` to edit and reload nginx.conf, routing all traffic to servers marked with '_b' in nginx.conf; all servers marked with '_a' will be marked as unavailable to new traffic.  
Go to the apps at `http://localhost:11638/` and `http://localhost:11636/`.  
Refresh the pages multiple times and you will see that the page always goes to server B.

- Finally, run `./rolling-update.sh ab` to edit and reload nginx.conf (return to the initial configuration), routing traffic to all _a and _b servers, using the Round Robin algorithm.  
Go to the apps at `http://localhost:11638/` and `http://localhost:11636/`.  
Refresh the page multiple times and you will see each app switches between server A and server B.
