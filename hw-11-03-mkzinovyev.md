# Домашнее задание к занятию «ELK» - выполнил `Михаил Зиновьев`
---

### Используемое окружение

Работа выполнялась на сервере с **Red OS 7**.

Для развёртывания ELK использовался **Docker Compose**.

В работе используются следующие сервисы:

1. Elasticsearch 7.17.9
2. Kibana 7.17.9
3. Logstash 7.17.9
4. Filebeat 7.17.9
5. Nginx

---

### Предварительная подготовка Red OS 7

Перед выполнением заданий был установлен и запущен Docker.

Команды:

```bash
sudo dnf install -y docker-ce docker-ce-cli docker-compose
sudo systemctl enable docker --now
sudo systemctl status docker
```
<img width="1356" height="505" alt="изображение" src="https://github.com/user-attachments/assets/bdba5bb6-15a0-46a5-a1a9-f9bc971ecc40" />

Добавим текущего пользователя в группу `docker`, чтобы запускать контейнеры без `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```
<img width="554" height="53" alt="изображение" src="https://github.com/user-attachments/assets/6e44b3e0-ec4b-443d-9d0a-68e07a019a57" />

Проверим версию Docker и Docker Compose:

```bash
docker --version
docker-compose version || docker compose version
```
<img width="563" height="104" alt="изображение" src="https://github.com/user-attachments/assets/4433019a-b007-41a1-8a7f-0f7c0a515e5c" />
<img width="363" height="40" alt="изображение" src="https://github.com/user-attachments/assets/156b9eff-0e3a-4f4c-bbb1-50f572ec6d35" />

Перед запуском Elasticsearch увеличим параметр `vm.max_map_count`:

```bash
sudo sysctl -w vm.max_map_count=262144
```

Чтобы параметр сохранился после перезагрузки:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
<img width="908" height="137" alt="изображение" src="https://github.com/user-attachments/assets/55a3fa37-dc39-49b4-9e57-4b29dab65f12" />

Создадим рабочие каталоги для конфигурационных файлов и скриншотов:

```bash
mkdir -p logstash/pipeline filebeat screenshots
```
<img width="1916" height="759" alt="изображение" src="https://github.com/user-attachments/assets/5492eca1-a197-4be8-9b8c-42a19fa182fc" />

---

### Основной файл `docker-compose.yml`

Создадим файл `docker-compose.yml`:

```bash
nano docker-compose.yml
```

Содержимое файла:

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

В данном файле для Elasticsearch был задан нестандартный параметр:

```yaml
cluster.name=redos-random-cluster-2026
```

---

### Задание 1. Elasticsearch

Установите и запустите Elasticsearch, после чего поменяйте параметр `cluster_name` на случайный.

Приведите скриншот команды `curl -X GET 'localhost:9200/_cluster/health?pretty'`, сделанной на сервере с установленным Elasticsearch. Где будет виден нестандартный `cluster_name`.

---

### Ответ задание 1. Elasticsearch

Elasticsearch был запущен в Docker-контейнере через Docker Compose на Red OS 7.

Для работы Elasticsearch предварительно был увеличен системный параметр `vm.max_map_count`:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

 В файле docker-compose.yaml для сервиса Elasticsearch был указан нестандартный параметр cluster.name:

```
environment:
  - xpack.security.enabled=false
  - discovery.type=single-node
  - cluster.name=mkzinovyev-elk-cluster
---
После этого Elasticsearch был запущен командой:

```
docker compose up -d elasticsearch
```
В моём случае вместе с Elasticsearch также была запущена Kibana для выполнения следующего задания:

```
docker compose up -d elasticsearch kibana
```
Скриншот - запуск контейнеров Elasticsearch и Kibana через Docker Compose:

<img width="2003" height="976" alt="изображение" src="https://github.com/user-attachments/assets/81c505df-6a89-4f27-bb72-f9dfd73c0e20" />


Проверим, что контейнеры запущены:

```
docker compose ps
```
<img width="1386" height="105" alt="image" src="https://github.com/user-attachments/assets/5b264d5c-828f-4fe9-9e91-8e35e30cebc8" />


Проверим состояние кластера Elasticsearch:

```
curl -X GET 'localhost:9200/_cluster/health?pretty'
```

Результат выполнения команды:

```
{
  "cluster_name" : "mkzinovyev-elk-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
На скриншоте видно, что Elasticsearch успешно запущен, состояние кластера green, а параметр cluster_name имеет нестандартное значение `mkzinovyev-elk-cluster`.

Скриншот - проверка состояния Elasticsearch и нестандартного cluster_name:
<img width="744" height="337" alt="изображение" src="https://github.com/user-attachments/assets/53ce8c47-f9e0-4907-b447-693f0b2d4ae3" />

### Задание 2. Kibana

Установите и запустите Kibana.

Приведите скриншот интерфейса Kibana на странице `http://<ip вашего сервера>:5601/app/dev_tools#/console`, где будет выполнен запрос `GET /_cluster/health?pretty`.

---

### Ответ задание 2. Kibana

Kibana была запущена в Docker-контейнере и подключена к Elasticsearch.

Запустим Kibana:

```bash
docker compose up -d kibana
```
<img width="1430" height="90" alt="image" src="https://github.com/user-attachments/assets/0a770508-babd-4697-8587-4ac2302891ba" />

Проверим запущенные контейнеры:

```bash
docker ps
```
<img width="1595" height="128" alt="image" src="https://github.com/user-attachments/assets/f44f03e3-427f-486e-8f53-f941524ce99f" />

Откроем Kibana в браузере:

```text
http://<IP-адрес-сервера>:5601
```
<img width="1419" height="862" alt="image" src="https://github.com/user-attachments/assets/56b001b3-17b5-4948-b190-3b930a0d46fc" />

Далее перейдём в раздел:

```text
Dev Tools → Console
```
<img width="534" height="371" alt="image" src="https://github.com/user-attachments/assets/4f4e568e-c5b0-488d-bc98-16373c9f8553" />

Выполним запрос:

```http
GET /_cluster/health?pretty
```


В результате Kibana вывела состояние кластера Elasticsearch, где также видно нестандартное имя кластера:

```text
  "cluster_name" : "mkzinovyev-elk-cluster",
```

Итог: Kibana успешно запущена и подключена к Elasticsearch.

**Скриншот - Kibana Dev Tools с запросом GET /_cluster/health?pretty:**  

<img width="1915" height="591" alt="image" src="https://github.com/user-attachments/assets/83f89a9f-3a25-4d5d-a41c-aa463833eb5e" />

---

### Задание 3. Logstash

Установите и запустите Logstash и Nginx. С помощью Logstash отправьте access-лог Nginx в Elasticsearch.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx.

---

### Ответ задание 3. Logstash

Для выполнения задания был запущен Nginx и Logstash.

Logstash читает файл access-лога Nginx:

```text
/var/log/nginx/access.log
```

Затем Logstash парсит записи и отправляет их в Elasticsearch в индекс:

```text
nginx-logstash-*
```

### Конфигурация Logstash

Создадим файл конфигурации:

```bash
nano logstash/pipeline/logstash.conf
```

Содержимое файла `logstash/pipeline/logstash.conf`:

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

Запустим Nginx и Logstash:

```bash
docker compose up -d nginx logstash
```

Проверим контейнеры:

```bash
docker ps
```

Сгенерируем несколько запросов к Nginx, чтобы появились записи в access-логе:

```bash
curl http://localhost:8080/
curl http://localhost:8080/test1
curl http://localhost:8080/test2
curl http://localhost:8080/test3
```

Проверим, что Nginx записал логи:

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

### Просмотр логов в Kibana

В Kibana создадим Data View:

```text
Stack Management → Data Views → Create data view
```

Укажем шаблон индекса:

```text
nginx-logstash-*
```

Поле времени:

```text
@timestamp
```

После создания Data View перейдём в раздел:

```text
Analytics → Discover
```

В Discover выберем Data View `nginx-logstash-*` и проверим, что отображаются access-логи Nginx.

Итог: Logstash успешно прочитал access-лог Nginx, обработал его и отправил данные в Elasticsearch.

**Скриншот - логи Nginx в Kibana, отправленные через Logstash:**  

![Скриншот логов Nginx через Logstash](screenshots/03-nginx-logs-logstash.png)

---

### Задание 4. Filebeat

Установите и запустите Filebeat. Переключите поставку логов Nginx с Logstash на Filebeat.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx, которые были отправлены через Filebeat.

---

### Ответ задание 4. Filebeat

Для выполнения задания поставка логов Nginx была переключена с Logstash на Filebeat.

Чтобы не было дублирования событий, перед запуском Filebeat остановим Logstash:

```bash
docker compose stop logstash
```

### Конфигурация Filebeat

Создадим файл конфигурации Filebeat:

```bash
nano filebeat/filebeat.yml
```

Содержимое файла `filebeat/filebeat.yml`:

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

Проверим, что в Elasticsearch появился индекс Filebeat:

```bash
curl 'localhost:9200/_cat/indices?v'
```

Ожидаемый индекс:

```text
nginx-filebeat-YYYY.MM.DD
```

### Просмотр логов в Kibana

В Kibana создадим новый Data View:

```text
Stack Management → Data Views → Create data view
```

Укажем шаблон индекса:

```text
nginx-filebeat-*
```

Поле времени:

```text
@timestamp
```

После создания Data View перейдём в раздел:

```text
Analytics → Discover
```

В Discover выберем Data View `nginx-filebeat-*` и проверим, что отображаются access-логи Nginx, отправленные через Filebeat.

Итог: Filebeat успешно прочитал access-лог Nginx и отправил его напрямую в Elasticsearch.

**Скриншот - логи Nginx в Kibana, отправленные через Filebeat:**  

![Скриншот логов Nginx через Filebeat](screenshots/04-nginx-logs-filebeat.png)

---

### Дополнительные задания (со звёздочкой*)

Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение зачёта по этому домашнему заданию.

### Задание 5*. Доставка данных

Настройте поставку лога в Elasticsearch через Logstash и Filebeat любого другого сервиса, но не Nginx. Для этого лог должен писаться на файловую систему, Logstash должен корректно его распарсить и разложить на поля.

Приведите скриншот интерфейса Kibana, на котором будет виден этот лог и напишите лог какого приложения отправляется.

---

### Ответ задание 5*. Доставка данных

Дополнительное задание не выполнялось.

---

### Полезные команды для проверки

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

Проверить состояние кластера Elasticsearch:

```bash
curl -X GET 'localhost:9200/_cluster/health?pretty'
```

Остановить стенд:

```bash
docker compose down
```

Остановить стенд и удалить данные Elasticsearch:

```bash
docker compose down -v
```

---

### Возможные ошибки и решения

### Ошибка 1. Elasticsearch не запускается из-за `vm.max_map_count`

Если Elasticsearch не запускается и в логах есть ошибка про `vm.max_map_count`, нужно выполнить на хосте:

```bash
sudo sysctl -w vm.max_map_count=262144
```

После этого перезапустить Elasticsearch:

```bash
docker compose restart elasticsearch
```

---

### Ошибка 2. Kibana долго не открывается

Kibana может запускаться несколько минут.

Проверить логи Kibana можно командой:

```bash
docker logs kibana --tail=100
```

Также нужно проверить, что Elasticsearch доступен:

```bash
curl localhost:9200
```

---

### Ошибка 3. Logstash не отправляет логи

Проверим, что Nginx пишет access-лог:

```bash
docker exec -it nginx cat /var/log/nginx/access.log
```

Проверим логи Logstash:

```bash
docker logs logstash --tail=100
```

Проверим индексы Elasticsearch:

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

### Вывод

В ходе выполнения работы был развёрнут стек ELK на сервере с Red OS 7 с использованием Docker Compose.

Были выполнены следующие действия:

1. Запущен Elasticsearch с нестандартным именем кластера `redos-random-cluster-2026`.
2. Запущена Kibana и выполнен запрос `GET /_cluster/health?pretty` через Dev Tools.
3. Настроена доставка access-логов Nginx в Elasticsearch через Logstash.
4. Настроена доставка access-логов Nginx в Elasticsearch через Filebeat.
5. В Kibana созданы Data View для просмотра логов, отправленных через Logstash и Filebeat.
