 # Домашнее задание к занятию «ELK» - выполнил `Михаил Зиновьев`

 **ОС:** РЕД ОС 7  
**Вариант выполнения:** Docker Compose  
**Используемые сервисы:** Elasticsearch 7.17.9, Kibana 7.17.9, Logstash 7.17.9, Filebeat 7.17.9, Nginx

---

## Цель работы

Развернуть стек ELK на сервере с РЕД ОС 7 и выполнить доставку логов Nginx в Elasticsearch двумя способами:

1. Через Logstash.
2. Через Filebeat.

---

## Подготовка окружения на РЕД ОС 7

Проверим версию ОС:

```bash
cat /etc/redos-release
```

Установим и запустим Docker:

```bash
sudo dnf install -y docker-ce docker-ce-cli docker-compose
sudo systemctl enable docker --now
sudo systemctl status docker
```

Добавим текущего пользователя в группу `docker`, чтобы запускать контейнеры без `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Проверим Docker и Docker Compose:

```bash
docker info
docker-compose version || docker compose version
```

Перед запуском Elasticsearch увеличим параметр `vm.max_map_count`:

```bash
sudo sysctl -w vm.max_map_count=262144
```

Чтобы сохранить параметр после перезагрузки:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

## Структура проекта

В репозитории была создана следующая структура:

```text
.
├── README.md
├── docker-compose.yml
├── filebeat
│   └── filebeat.yml
├── logstash
│   └── pipeline
│       └── logstash.conf
└── screenshots
    ├── 01-elasticsearch-health.png
    ├── 02-kibana-dev-tools.png
    ├── 03-nginx-logs-logstash.png
    └── 04-nginx-logs-filebeat.png
```

Команды для создания каталогов:

```bash
mkdir -p logstash/pipeline filebeat screenshots
```

---

## Файл `docker-compose.yml`

```yaml
version: '3.7'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.9
    container_name: elasticsearch
    environment:
      - xpack.security.enabled=false
      - discovery.type=single-node
      - cluster.name=redos-random-cluster-2026
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    cap_add:
      - IPC_LOCK
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.9
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "8080:80"
    volumes:
      - nginx-logs:/var/log/nginx

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.9
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - nginx-logs:/var/log/nginx:ro
    ports:
      - "5044:5044"
      - "9600:9600"
    depends_on:
      - elasticsearch
      - nginx

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.17.9
    container_name: filebeat
    user: root
    command: ["--strict.perms=false"]
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - nginx-logs:/var/log/nginx:ro
    depends_on:
      - elasticsearch
      - kibana
      - nginx

volumes:
  elasticsearch-data:
    driver: local

  nginx-logs:
    driver: local
```

В данном файле для Elasticsearch задан нестандартный параметр:

```yaml
cluster.name=redos-random-cluster-2026
```

---

## Конфигурация Logstash

Файл: `logstash/pipeline/logstash.conf`

```conf
input {
  file {
    path => "/var/log/nginx/access.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
}

filter {
  grok {
    match => {
      "message" => "%{COMBINEDAPACHELOG}"
    }
  }

  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    target => "@timestamp"
  }

  mutate {
    add_field => {
      "log_source" => "nginx_logstash"
    }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "nginx-logstash-%{+YYYY.MM.dd}"
  }

  stdout {
    codec => rubydebug
  }
}
```

---

## Конфигурация Filebeat

Файл: `filebeat/filebeat.yml`

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
    fields:
      log_source: nginx_filebeat
    fields_under_root: true

output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]
  index: "nginx-filebeat-%{+yyyy.MM.dd}"

setup.ilm.enabled: false
setup.template.name: "nginx-filebeat"
setup.template.pattern: "nginx-filebeat-*"

logging.level: info
```

---

# Задание 1. Elasticsearch

## Выполнение

Запустим Elasticsearch:

```bash
docker compose up -d elasticsearch
```

Если используется старая версия Docker Compose, команда может быть такой:

```bash
docker-compose up -d elasticsearch
```

Проверим, что контейнер запущен:

```bash
docker ps
```

Проверим состояние кластера Elasticsearch:

```bash
curl -X GET 'localhost:9200/_cluster/health?pretty'
```

Пример результата:

```json
{
  "cluster_name" : "redos-random-cluster-2026",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0
}
```

## Результат

Elasticsearch был успешно установлен и запущен в Docker-контейнере. В настройках был задан нестандартный `cluster_name`: `redos-random-cluster-2026`.

**Скриншот результата:**

![Скриншот health Elasticsearch](screenshots/01-elasticsearch-health.png)

---

# Задание 2. Kibana

## Выполнение

Запустим Kibana:

```bash
docker compose up -d kibana
```

Проверим контейнеры:

```bash
docker ps
```

Откроем Kibana в браузере:

```text
http://<IP-адрес-сервера>:5601
```

Перейдём в раздел:

```text
Dev Tools → Console
```

Выполним запрос:

```http
GET /_cluster/health?pretty
```

В результате был получен ответ Elasticsearch с информацией о состоянии кластера и нестандартным именем кластера.

## Результат

Kibana была успешно запущена и подключена к Elasticsearch.

**Скриншот результата:**

![Скриншот Kibana Dev Tools](screenshots/02-kibana-dev-tools.png)

---

# Задание 3. Logstash

## Выполнение

Запустим Nginx и Logstash:

```bash
docker compose up -d nginx logstash
```

Проверим контейнеры:

```bash
docker ps
```

Сгенерируем несколько обращений к Nginx:

```bash
curl http://localhost:8080/
curl http://localhost:8080/test1
curl http://localhost:8080/test2
curl http://localhost:8080/test3
```

Проверим логи Nginx внутри контейнера:

```bash
docker exec -it nginx cat /var/log/nginx/access.log
```

Проверим логи Logstash:

```bash
docker logs logstash --tail=100
```

Проверим, что в Elasticsearch появился индекс Logstash:

```bash
curl 'localhost:9200/_cat/indices?v'
```

Ожидаемый индекс:

```text
nginx-logstash-YYYY.MM.DD
```

## Просмотр логов в Kibana

В Kibana создаём Data View:

```text
Stack Management → Data Views → Create data view
```

Указываем шаблон индекса:

```text
nginx-logstash-*
```

Поле времени:

```text
@timestamp
```

После создания Data View переходим:

```text
Analytics → Discover
```

Выбираем Data View `nginx-logstash-*` и проверяем, что отображаются записи access-лога Nginx.

## Результат

Logstash был настроен на чтение файла `/var/log/nginx/access.log`, парсинг access-логов Nginx и отправку данных в Elasticsearch в индекс `nginx-logstash-*`.

**Скриншот результата:**

![Скриншот логов Nginx через Logstash](screenshots/03-nginx-logs-logstash.png)

---

# Задание 4. Filebeat

## Выполнение

Для проверки доставки логов через Filebeat остановим Logstash, чтобы не было дублирования событий:

```bash
docker compose stop logstash
```

Запустим Filebeat:

```bash
docker compose up -d filebeat
```

Сгенерируем новые обращения к Nginx:

```bash
curl http://localhost:8080/filebeat1
curl http://localhost:8080/filebeat2
curl http://localhost:8080/filebeat3
```

Проверим логи Filebeat:

```bash
docker logs filebeat --tail=100
```

Проверим индексы Elasticsearch:

```bash
curl 'localhost:9200/_cat/indices?v'
```

Ожидаемый индекс:

```text
nginx-filebeat-YYYY.MM.DD
```

## Просмотр логов в Kibana

В Kibana создаём новый Data View:

```text
Stack Management → Data Views → Create data view
```

Указываем шаблон индекса:

```text
nginx-filebeat-*
```

Поле времени:

```text
@timestamp
```

После создания Data View переходим:

```text
Analytics → Discover
```

Выбираем Data View `nginx-filebeat-*` и проверяем, что отображаются записи access-лога Nginx, отправленные через Filebeat.

## Результат

Filebeat был настроен на чтение файла `/var/log/nginx/access.log` и отправку логов Nginx напрямую в Elasticsearch в индекс `nginx-filebeat-*`.

**Скриншот результата:**

![Скриншот логов Nginx через Filebeat](screenshots/04-nginx-logs-filebeat.png)

---

# Дополнительное задание 5*. Доставка данных другого сервиса

Дополнительное задание не выполнялось.

---

## Полезные команды для проверки

Проверить запущенные контейнеры:

```bash
docker ps
```

Посмотреть все контейнеры:

```bash
docker ps -a
```

Посмотреть логи Elasticsearch:

```bash
docker logs elasticsearch --tail=100
```

Посмотреть логи Kibana:

```bash
docker logs kibana --tail=100
```

Посмотреть логи Logstash:

```bash
docker logs logstash --tail=100
```

Посмотреть логи Filebeat:

```bash
docker logs filebeat --tail=100
```

Проверить индексы Elasticsearch:

```bash
curl 'localhost:9200/_cat/indices?v'
```

Проверить состояние кластера:

```bash
curl -X GET 'localhost:9200/_cluster/health?pretty'
```

Остановить весь стенд:

```bash
docker compose down
```

Остановить стенд и удалить volume с данными Elasticsearch:

```bash
docker compose down -v
```

---

## Возможные ошибки и решения

### Ошибка 1. Elasticsearch не запускается из-за `vm.max_map_count`

Если в логах Elasticsearch есть ошибка вида:

```text
max virtual memory areas vm.max_map_count is too low
```

Нужно выполнить на хосте:

```bash
sudo sysctl -w vm.max_map_count=262144
```

И затем перезапустить Elasticsearch:

```bash
docker compose restart elasticsearch
```

---

### Ошибка 2. Kibana долго не открывается

Kibana может запускаться несколько минут. Проверить состояние можно командой:

```bash
docker logs kibana --tail=100
```

Также нужно проверить, что Elasticsearch доступен:

```bash
curl localhost:9200
```

---

### Ошибка 3. Logstash не отправляет логи

Проверить, что Nginx пишет access-log:

```bash
docker exec -it nginx cat /var/log/nginx/access.log
```

Проверить логи Logstash:

```bash
docker logs logstash --tail=100
```

Проверить индексы:

```bash
curl 'localhost:9200/_cat/indices?v'
```

---

### Ошибка 4. Filebeat не стартует из-за прав на конфигурационный файл

В `docker-compose.yml` для Filebeat используется параметр:

```yaml
command: ["--strict.perms=false"]
```

Он отключает строгую проверку прав на файл `filebeat.yml` внутри контейнера.

---

## Вывод

В ходе выполнения работы был развёрнут стек ELK на сервере с РЕД ОС 7 с использованием Docker Compose.

Были выполнены следующие действия:

1. Запущен Elasticsearch с нестандартным именем кластера `redos-random-cluster-2026`.
2. Запущена Kibana и выполнен запрос `GET /_cluster/health?pretty` через Dev Tools.
3. Настроена доставка access-логов Nginx в Elasticsearch через Logstash.
4. Настроена доставка access-логов Nginx в Elasticsearch через Filebeat.
5. В Kibana созданы Data View для просмотра логов, отправленных через Logstash и Filebeat.
