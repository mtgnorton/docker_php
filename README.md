# 本地 docker php环境

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## 内容列表
- [安装和更新](#安装和更新)
- [目录介绍](#目录介绍)
- [注意事项](#注意事项)
- [常用命令](#常用命令)
- [新建一个laravel项目](#新建一个laravel项目)

## 安装和更新
- 安装 `git clone git@github.com:mtgnorton/docker_php.git`
- 更新 `git pull`

## 目录介绍
- src: 源码目录，所有的php项目放在此目录下
- dockerfiles: 镜像脚本目录
  - artisan.dockerfile: laravel artisan 或 tp6 think 命令 使用的镜像
  - nginx.dockerfile: nginx 镜像
  - composer.dockerfile: composer命令镜像
  - php.dockerfile: php镜像
- nginx:
    - nginx.conf: nginx 主配置文件
    - conf.d: 站点虚拟主机配置文件
## 注意事项
1. 在php的配置文件中，mysql的连接地址为：`mysql`,redis的连接地址为：`redis`,不是localhost或127.0.0.1
2. 修改了某个镜像文件后，使用`dc build 镜像文件名称`进行重新构建,需要安装某个扩展的时候需要修改镜像文件
## 常用命令
- 启动，停止，重启环境
  - 启动： docker-compose up    （可选参数 -d 后台启动）
  - 停止： docker-compose stop
  - 重启： docker-compose restart 
- 查看日志
docker-compose logs -f
- php环境相关
  - 使用composer： `dc run  --rm  --entrypoint "bash -c"   composer "cd /var/www/html/项目目录名称 && composer install --ignore-platform-reqs --no-scripts"`
  - 使用artisan： `dc run --rm --entrypoint "bash -c" artisan " cd /var/www/html/项目目录名称; php /var/www/html/项目目录名称/artisan 命令名称"` 此处artisan可替换为think
  
    
## 新建一个laravel项目

1. 在src目录下，执行`git clone git@github.com:mtgnorton/laravel_admin_base.git laravel_admin_base_test `
2. 进入laravel_admin_base_test,执行`mv .env.example .env`
3. 修改.env配置文件类似如下
```azure
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:TOjhFnjw4tF6nNR4+vd3ISs/jgyLht8tI0AY+tLK+Qg=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_admin_base_test
DB_USERNAME=root
DB_PASSWORD=secret

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=null
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
```
4. 把storage/sql下的文件导入到数据库中
5. 执行 `dc run  --rm  --entrypoint "bash -c"   composer "cd /var/www/html/laravel_admin_base_test && composer install   --ignore-platform-reqs --no-scripts"`,安装第三方依赖
6. 执行`dc run --rm --entrypoint "bash -c" artisan " cd/var/www/html/laravel_admin_base_test; php /var/www/html/laravel_admin_base_test/artisan key:generate"`,生成key
7. 执行`chmod -R a+w storage`
8. 执行 `dc run --rm --entrypoint "bash -c" artisan " cd /var/www/html/laravel_admin_base_test; php /var/www/html/laravel_admin_base_test/artisan storage:link"`
9. 在nginx/conf.d目录下新建虚拟主机配置文件,文件名称随意，内容如下
```azure
server {
listen 80;
index index.php index.html;
server_name base.local; # 本地域名
root /var/www/html/laravel_admin_base/public; #项目目录

location / {
        try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
try_files $uri =404;
fastcgi_split_path_info ^(.+\.php)(/.+)$;
fastcgi_pass php:9000;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO $fastcgi_path_info;
}
}
```
10. 修改host文件，将本地域名添加到hosts中
```azure
127.0.0.1 base_test.local
```
  
11. 执行`dc restart `，因为修改了nginx配置文件后需要重启compose
