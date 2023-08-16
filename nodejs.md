# Kubernetes for NodeJS Developer

## Step 1. Run the tutorial

```
docker run -d -p 82:80 docker/getting-started
```

## Step 2. Download the ZIP file

```
wget http://localhost:82/assets/app.zip
```

## Step 3. Use the Dockerfile

Use Docker init to build NodeJS assets OR use the Dockerfile

```
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
```

## Step 4. Build the Containerised App

```
docker build -t ajeetraina/todo .
```

## Step 5. Run the containerised app

```
docker run -d -p 3000:3000 ajeetraina/todo
```

## Building Multi-Containerise App

```
services:
  app:
    image: node:18-alpine
    command: sh -c "yarn install && yarn run dev"
    ports:
      - 3000:3000
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: todos

  mysql:
    image: mysql:8.0
    volumes:
      - todo-mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: todos

volumes:
  todo-mysql-data:
```

## Running the Compose

```
docker compose up -d --build
```

```
docker compose ps
NAME                IMAGE               COMMAND                  SERVICE             CREATED             STATUS              PORTS
app-app-1           node:18-alpine      "docker-entrypoint.s…"   app                 16 seconds ago      Up 15 seconds       0.0.0.0:3000->3000/tcp
app-mysql-1         mysql:8.0           "docker-entrypoint.s…"   mysql               16 seconds ago      Up 15 seconds       3306/tcp, 33060/tcp
```

## Step 6. Running the container inside a Pod

```
kubectl run --image=ajeetraina/todo todolist-app --port=3000 --env="DOMAIN=cluster"
```

```
kubectl get po,deploy,svc
NAME                            READY   STATUS    RESTARTS   AGE
pod/todolist-app                1/1     Running   0          16s
```

## Step 7. Accessing the Pod

```
kubectl port-forward todolist-app 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```






