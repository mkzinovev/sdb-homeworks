# Домашнее задание к занятию «ELK» — выполнил `Михаил Зиновьев`

---

## Используемое окружение

Работа выполнялась на сервере с **Red OS 7**.

Для развёртывания стенда использовался **Docker Compose**.

В работе были использованы следующие сервисы:

1. Elasticsearch 7.17.9
2. Kibana 7.17.9
3. Logstash 7.17.9
4. Filebeat 7.17.9
5. Nginx

---

## Предварительная подготовка Red OS 7

Перед выполнением заданий был установлен и запущен Docker.

Были выполнены команды:

```bash
sudo dnf install -y docker-ce docker-ce-cli docker-compose
sudo systemctl enable docker --now
sudo systemctl status docker
```

<img width="1356" height="505" alt="изображение" src="https://github.com/user-attachments/assets/bdba5bb6-15a0-46a5-a1a9-f9bc971ecc40" />

Текущий пользователь был добавлен в группу `docker`, чтобы запускать контейнеры без использования `sudo`.

Были выполнены команды:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

<img width="554" height="53" alt="изображение" src="https://github.com/user-attachments/assets/6e44b3e0-ec4b-443d-9d0a-68e07a019a57" />

Была выполнена проверка версии Docker и Docker Compose.

Команды проверки:

```bash
docker --version
docker-compose version || docker compose version
```

<img width="363" height="40" alt="изображение" src="https://github.com/user-attachments/assets/156b9eff-0e3a-4f4c-bbb1-50f572ec6d35" />

Перед запуском Elasticsearch был увеличен системный параметр `vm.max_map_count`.

Была выполнена команда:

```bash
sudo sysctl -w vm.max_map_count=262144
```

Чтобы параметр сохранился после перезагрузки, были выполнены команды:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

<img width="908" height="137" alt="изображение" src="https://github.com/user-attachments/assets/55a3fa37-dc39-49b4-9e57-4b29dab65f12" />

Для конфигурационных файлов и скриншотов были созданы рабочие каталоги.

Была выполнена команда:

```bash
mkdir -p logstash/pipeline filebeat screenshots
```

<img width="1916" height="759" alt="изображение" src="https://github.com/user-attachments/assets/5492eca1-a197-4be8-9b8c-42a19fa182fc" />

---

## Основной файл `docker-compose.yml`

Для описания сервисов стенда был создан файл `docker-compose.yml`.

Была выполнена команда:

```bash
nano docker-compose.yml
```

Содержимое файла `docker-compose.yml`:

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.9
    container_name: elasticsearch
    environment:
      - xpack.security.enabled=false
      - discovery.type=single-node
      - cluster.name=mkzinovyev-elk-cluster
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

В файле `docker-compose.yml` для Elasticsearch был задан нестандартный параметр имени кластера:

```yaml
cluster.name=mkzinovyev-elk-cluster
```

---

## Задание 1. Elasticsearch

Установите и запустите Elasticsearch, после чего поменяйте параметр `cluster_name` на случайный.

Приведите скриншот команды `curl -X GET 'localhost:9200/_cluster/health?pretty'`, сделанной на сервере с установленным Elasticsearch, где будет виден нестандартный `cluster_name`.

---

## Ответ на задание 1. Elasticsearch

Elasticsearch был запущен в Docker-контейнере через Docker Compose на сервере с Red OS 7.

Перед запуском Elasticsearch был увеличен системный параметр `vm.max_map_count`.

Были выполнены команды:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

В файле `docker-compose.yml` для сервиса Elasticsearch был указан нестандартный параметр `cluster.name`:

```yaml
environment:
  - xpack.security.enabled=false
  - discovery.type=single-node
  - cluster.name=mkzinovyev-elk-cluster
```

После этого был выполнен запуск Elasticsearch.

Команда запуска:

```bash
docker compose up -d elasticsearch
```

В рамках выполнения работы вместе с Elasticsearch также была запущена Kibana, которая используется в следующем задании.

Команда запуска:

```bash
docker compose up -d elasticsearch kibana
```

Скриншот — запуск контейнеров Elasticsearch и Kibana через Docker Compose:

<img width="2003" height="976" alt="изображение" src="https://github.com/user-attachments/assets/81c505df-6a89-4f27-bb72-f9dfd73c0e20" />

Была выполнена проверка запущенных контейнеров.

Команда проверки:

```bash
docker compose ps
```

<img width="1386" height="105" alt="image" src="https://github.com/user-attachments/assets/5b264d5c-828f-4fe9-9e91-8e35e30cebc8" />

Была выполнена проверка состояния кластера Elasticsearch.

Команда проверки:

```bash
curl -X GET 'localhost:9200/_cluster/health?pretty'
```

Результат выполнения команды:

```json
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

На скриншоте видно, что Elasticsearch успешно запущен, состояние кластера — `green`, а параметр `cluster_name` имеет нестандартное значение `mkzinovyev-elk-cluster`.

Скриншот — проверка состояния Elasticsearch и нестандартного `cluster_name`:

<img width="744" height="337" alt="изображение" src="https://github.com/user-attachments/assets/53ce8c47-f9e0-4907-b447-693f0b2d4ae3" />

Итог: Elasticsearch был успешно запущен, а параметр `cluster_name` был изменён на нестандартное значение `mkzinovyev-elk-cluster`.

---

## Задание 2. Kibana

Установите и запустите Kibana.

Приведите скриншот интерфейса Kibana на странице `http://<ip вашего сервера>:5601/app/dev_tools#/console`, где будет выполнен запрос `GET /_cluster/health?pretty`.

---

## Ответ на задание 2. Kibana

Так как Elasticsearch был запущен на предыдущем этапе, далее была запущена Kibana.

Команда запуска:

```bash
docker compose up -d kibana
```

<img width="1430" height="90" alt="image" src="https://github.com/user-attachments/assets/0a770508-babd-4697-8587-4ac2302891ba" />

Была выполнена проверка запущенных контейнеров Elasticsearch и Kibana.

Команда проверки:

```bash
docker ps
```

<img width="1595" height="128" alt="image" src="https://github.com/user-attachments/assets/f44f03e3-427f-486e-8f53-f941524ce99f" />

После запуска Kibana была открыта в браузере.

Адрес подключения:

```text
http://localhost:5601/
```

<img width="1419" height="862" alt="image" src="https://github.com/user-attachments/assets/56b001b3-17b5-4948-b190-3b930a0d46fc" />

Далее в интерфейсе Kibana был открыт раздел:

```text
Dev Tools → Console
```

В консоли Kibana был выполнен запрос к Elasticsearch:

```http
GET /_cluster/health?pretty
```

В результате выполнения запроса Kibana отобразила состояние кластера Elasticsearch. В ответе видно, что кластер находится в состоянии `green`, а параметр `cluster_name` имеет нестандартное значение:

```json
"cluster_name" : "mkzinovyev-elk-cluster"
```

Скриншот — Kibana Dev Tools с запросом `GET /_cluster/health?pretty`:

<img width="1915" height="591" alt="image" src="https://github.com/user-attachments/assets/83f89a9f-3a25-4d5d-a41c-aa463833eb5e" />

Итог: Kibana была успешно запущена, подключена к Elasticsearch и позволила выполнить запрос к кластеру через Dev Tools.

---

## Задание 3. Logstash

Установите и запустите Logstash и Nginx. С помощью Logstash отправьте access-лог Nginx в Elasticsearch.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx.

---

## Ответ на задание 3. Logstash

Для выполнения задания были запущены контейнеры Nginx и Logstash.

Nginx записывает access-логи в файл:

```text
/var/log/nginx/access.log
```

Logstash был настроен на чтение файла `/var/log/nginx/access.log`, обработку записей через фильтр `grok` и отправку событий в Elasticsearch в индекс:

```text
nginx-logstash-*
```

### Конфигурация Logstash

Для Logstash был создан конфигурационный файл.

Была выполнена команда:

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

После настройки конфигурации были запущены контейнеры Nginx и Logstash.

Команда запуска:

```bash
docker compose up -d nginx logstash
```

Была выполнена проверка запущенных контейнеров.

Команда проверки:

```bash
docker ps
```

<img width="539" height="142" alt="image" src="https://github.com/user-attachments/assets/09f86696-3733-4d79-840e-189f582693b3" />

Для генерации записей в access-логе Nginx были выполнены тестовые HTTP-запросы.

Команды:

```bash
curl http://localhost:8080/
curl http://localhost:8080/test1
curl http://localhost:8080/test2
curl http://localhost:8080/test3
```

После выполнения запросов была проведена проверка access-лога Nginx.

Команда проверки:

```bash
docker exec -it logstash tail -n 10 /var/log/nginx/access.log
```

Скриншот — проверка access-лога Nginx:

<img width="490" height="680" alt="image" src="https://github.com/user-attachments/assets/d4f10527-546d-4089-a447-562f2504dce7" />

На скриншоте видно, что после выполнения запросов к Nginx в файле `/var/log/nginx/access.log` появились записи. Запрос к главной странице вернул код `200`, а тестовые запросы `/test1`, `/test2`, `/test3` вернули код `404`, что также корректно записалось в access-лог.

Была выполнена проверка логов Logstash.

Команда проверки:

```bash
docker logs logstash --tail=100
```

<img width="2327" height="730" alt="image" src="https://github.com/user-attachments/assets/f3355afe-0658-4feb-9c89-2f63c2311e4b" />

На скриншоте видно, что Logstash успешно запустил pipeline `main`, подключился к Elasticsearch и начал отслеживать файл access-лога Nginx.

Была выполнена проверка наличия индекса Logstash в Elasticsearch.

Команда проверки:

```bash
curl 'localhost:9200/_cat/indices?v' | grep nginx
```

В результате проверки был обнаружен индекс вида:

```text
nginx-logstash-YYYY.MM.DD
```

Скриншот — проверка индекса `nginx-logstash-*` в Elasticsearch:

<img width="826" height="135" alt="image" src="https://github.com/user-attachments/assets/fcea7bdd-2f17-4afa-a5e5-c278535c1bdc" />

### Просмотр логов Logstash в Kibana

Для просмотра логов в Kibana был создан index pattern.

В интерфейсе Kibana был открыт раздел:

```text
Stack Management → Index Patterns → Create index pattern
```

Был указан шаблон индекса:

```text
nginx-logstash-*
```

В качестве поля времени было выбрано поле:

```text
@timestamp
```

После создания index pattern был открыт раздел:

```text
Analytics → Discover
```

В Discover был выбран index pattern:

```text
nginx-logstash-*
```

После этого в интерфейсе Kibana стали отображаться access-логи Nginx, которые были отправлены через Logstash.

Скриншот — логи Nginx в Kibana, отправленные через Logstash:

<img width="2549" height="759" alt="image" src="https://github.com/user-attachments/assets/02338271-0bce-49f4-a5ae-68ca0274a788" />

Итог: Logstash успешно прочитал access-лог Nginx, обработал записи через `grok` и отправил данные в Elasticsearch. В Kibana Discover были отображены события из индекса `nginx-logstash-*`.

---

## Задание 4. Filebeat

Установите и запустите Filebeat. Переключите поставку логов Nginx с Logstash на Filebeat.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx, которые были отправлены через Filebeat.

---

## Ответ на задание 4. Filebeat

Для выполнения задания поставка логов Nginx была переключена с Logstash на Filebeat.

Чтобы избежать дублирования событий, перед запуском Filebeat был остановлен Logstash.

Была выполнена команда:

```bash
docker compose stop logstash
```

### Конфигурация Filebeat

Для Filebeat был создан конфигурационный файл.

Была выполнена команда:

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

После настройки конфигурации был запущен Filebeat.

Команда запуска:

```bash
docker compose up -d filebeat
```

<img width="483" height="95" alt="image" src="https://github.com/user-attachments/assets/a815352c-54bc-44bd-be24-63527370610e" />

Была выполнена проверка запущенных контейнеров.

Команда проверки:

```bash
docker ps
```

Для генерации новых записей в access-логе Nginx были выполнены тестовые HTTP-запросы.

Команды:

```bash
curl http://localhost:8080/filebeat1
curl http://localhost:8080/filebeat2
curl http://localhost:8080/filebeat3
```

<img width="616" height="317" alt="image" src="https://github.com/user-attachments/assets/5bc0a1d8-32a0-4ffc-bcaf-8ffcc0c65db4" />

Была выполнена проверка логов Filebeat.

Команда проверки:

```bash
docker logs filebeat --tail=100
```

Затем была проведена проверка наличия индекса Filebeat в Elasticsearch.

Команда проверки:

```bash
curl 'localhost:9200/_cat/indices?v' | grep filebeat
```

В результате проверки был обнаружен индекс:

```text
nginx-filebeat-2026.05.15
```

В индексе присутствовали документы с access-логами Nginx, отправленными через Filebeat.

### Просмотр логов Filebeat в Kibana

Для просмотра логов в Kibana был создан новый index pattern.

В интерфейсе Kibana был открыт раздел:

```text
Stack Management → Index Patterns → Create index pattern
```

Был указан шаблон индекса:

```text
nginx-filebeat-*
```

В качестве поля времени было выбрано поле:

```text
@timestamp
```

После создания index pattern был открыт раздел:

```text
Analytics → Discover
```

В Discover был выбран index pattern:

```text
nginx-filebeat-*
```

После этого в интерфейсе Kibana стали отображаться access-логи Nginx, которые Filebeat прочитал из файла `/var/log/nginx/access.log` и отправил напрямую в Elasticsearch.

Скриншот — логи Nginx в Kibana, отправленные через Filebeat:

<img width="2542" height="1184" alt="image" src="https://github.com/user-attachments/assets/b043a4de-2f04-4e61-995d-89cb5da2c7de" />

На скриншоте видно, что в Kibana Discover выбран index pattern `nginx-filebeat-*`. В документах присутствуют поля `agent.type: filebeat`, `agent.version: 7.17.9`, `log_source: nginx_filebeat`, `log.file.path: /var/log/nginx/access.log`, а также сообщения с запросами `/filebeat1`, `/filebeat2`, `/filebeat3`.

Итог: Filebeat успешно прочитал access-лог Nginx и отправил события напрямую в Elasticsearch. В Kibana Discover были отображены события из индекса `nginx-filebeat-*`.

---

## Дополнительные задания со звёздочкой

Дополнительные задания не являются обязательными и не влияют на получение зачёта по домашнему заданию.

---

## Задание 5*. Доставка данных

Настройте поставку лога в Elasticsearch через Logstash и Filebeat любого другого сервиса, но не Nginx. Для этого лог должен писаться на файловую систему, Logstash должен корректно его распарсить и разложить на поля.

Приведите скриншот интерфейса Kibana, на котором будет виден этот лог, и напишите, лог какого приложения отправляется.

---

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
### Задание 5*. Доставка данных

Настройте поставку лога в Elasticsearch через Logstash и Filebeat любого другого сервиса, но не Nginx. Для этого лог должен писаться на файловую систему, Logstash должен корректно его распарсить и разложить на поля.

Приведите скриншот интерфейса Kibana, на котором будет виден этот лог, и напишите, лог какого приложения отправляется.

---

### Ответ задание 5*. Доставка данных

Для выполнения дополнительного задания была настроена доставка access-логов веб-сервера **Apache HTTP Server**.

Была использована следующая схема доставки данных:

```text
Apache HTTP Server → access.log → Filebeat → Logstash → Elasticsearch → Kibana
```

В качестве источника логов использовался файл access-лога Apache:

```text
/usr/local/apache2/logs/access.log
```

В контейнере Filebeat этот файл был доступен по пути:

```text
/var/log/apache/access.log
```

Logstash принимал события от Filebeat, обрабатывал строки access-лога через фильтр `grok`, раскладывал данные на отдельные поля и отправлял документы в Elasticsearch в индекс:

```text
apache-filebeat-logstash-*
```

---

### Конфигурация Docker Compose

В файл `docker-compose.yml` были добавлены сервисы `apache`, `logstash-apache` и `filebeat-apache`.

```yaml
  apache:
    image: httpd:2.4
    container_name: apache
    ports:
      - "8081:80"
    command: >
      sh -c "sed -i 's#CustomLog /proc/self/fd/1 common#CustomLog /usr/local/apache2/logs/access.log common#' /usr/local/apache2/conf/httpd.conf &&
             sed -i 's#ErrorLog /proc/self/fd/2#ErrorLog /usr/local/apache2/logs/error.log#' /usr/local/apache2/conf/httpd.conf &&
             httpd-foreground"
    volumes:
      - apache-logs:/usr/local/apache2/logs

  logstash-apache:
    image: docker.elastic.co/logstash/logstash:7.17.9
    container_name: logstash-apache
    volumes:
      - ./logstash/apache-pipeline:/usr/share/logstash/pipeline
    ports:
      - "5045:5045"
      - "9601:9600"
    depends_on:
      - elasticsearch
      - apache

  filebeat-apache:
    image: docker.elastic.co/beats/filebeat:7.17.9
    container_name: filebeat-apache
    user: root
    command: ["filebeat", "-e", "--strict.perms=false"]
    volumes:
      - ./filebeat/apache-filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - apache-logs:/var/log/apache:ro
    depends_on:
      - apache
      - logstash-apache
```

Также в блок `volumes` был добавлен отдельный volume для логов Apache:

```yaml
  apache-logs:
    driver: local
```

---

### Конфигурация Logstash для Apache

Был создан каталог для отдельного pipeline Logstash:

```bash
mkdir -p logstash/apache-pipeline
```

Был создан файл конфигурации Logstash:

```bash
nano logstash/apache-pipeline/apache.conf
```

Содержимое файла `logstash/apache-pipeline/apache.conf`:

```conf
input {
  beats {
    port => 5045
  }
}

filter {
  grok {
    match => {
      "message" => "%{COMMONAPACHELOG}"
    }
  }

  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    target => "@timestamp"
  }

  mutate {
    add_field => {
      "log_source" => "apache_filebeat_logstash"
      "service_name" => "apache_httpd"
    }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "apache-filebeat-logstash-%{+YYYY.MM.dd}"
  }

  stdout {
    codec => rubydebug
  }
}
```

Данная конфигурация выполняет следующие действия:

1. принимает события от Filebeat на порту `5045`;
2. обрабатывает строки access-лога Apache через шаблон `%{COMMONAPACHELOG}`;
3. выделяет поля `clientip`, `timestamp`, `verb`, `request`, `httpversion`, `response`, `bytes`;
4. добавляет служебные поля `log_source` и `service_name`;
5. отправляет обработанные события в Elasticsearch.

---

### Конфигурация Filebeat для Apache

Был создан файл конфигурации Filebeat:

```bash
nano filebeat/apache-filebeat.yml
```

Содержимое файла `filebeat/apache-filebeat.yml`:

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/apache/access.log
    fields:
      log_source: apache_filebeat
      service_name: apache_httpd
    fields_under_root: true

output.logstash:
  hosts: ["logstash-apache:5045"]

logging.level: info
```

В данной конфигурации Filebeat считывает файл:

```text
/var/log/apache/access.log
```

После чтения события отправляются в Logstash:

```text
logstash-apache:5045
```

---

### Запуск сервисов

После подготовки конфигурационных файлов была выполнена команда запуска сервисов Apache, Logstash и Filebeat:

```bash
docker compose up -d apache logstash-apache filebeat-apache
```

В ходе первоначального запуска была выявлена ошибка монтирования файла `apache-filebeat.yml`. Ошибка была связана с тем, что Docker не смог смонтировать файл конфигурации Filebeat, так как указанный путь не соответствовал ожидаемому типу объекта.

После проверки пути и создания файла `filebeat/apache-filebeat.yml` запуск был выполнен повторно.

Скриншот — первоначальная ошибка запуска Filebeat:

![[Pasted image 20260516124504.png]]
Скриншот — повторный запуск сервисов после исправления конфигурации:

![[Pasted image 20260516124915.png]]

После этого была выполнена проверка запущенных контейнеров:

```bash
docker ps
```

На скриншоте видно, что контейнеры `apache`, `logstash-apache`, `filebeat-apache` и `elasticsearch` находятся в состоянии `Up`.

Скриншот — проверка запущенных контейнеров:
![[Pasted image 20260516124953.png]]


---

### Генерация тестовых запросов к Apache

Для генерации записей в access-логе Apache были выполнены HTTP-запросы:

```bash
curl http://localhost:8081/
curl http://localhost:8081/apache1
curl http://localhost:8081/apache2
curl http://localhost:8081/apache3
```

Запрос к главной странице `/` вернул стандартную страницу Apache `It works!`.

Запросы `/apache1`, `/apache2`, `/apache3` вернули код `404 Not Found`, так как такие страницы не были созданы. При этом данные обращения также были корректно записаны в access-лог Apache.

Скриншот — выполнение тестовых запросов к Apache:

![[Pasted image 20260516125016.png]]

---

### Проверка access-лога Apache

Была выполнена проверка файла access-лога Apache:

```bash
docker exec -it apache tail -n 10 /usr/local/apache2/logs/access.log
```

В результате были получены записи по выполненным HTTP-запросам:

```text
GET / HTTP/1.1
GET /apache1 HTTP/1.1
GET /apache2 HTTP/1.1
GET /apache3 HTTP/1.1
```

На скриншоте видно, что Apache записал обращения в файл `/usr/local/apache2/logs/access.log`.

Скриншот — проверка access-лога Apache:

![[Pasted image 20260516125133.png]]

---

### Проверка работы Filebeat

Была выполнена проверка логов контейнера `filebeat-apache`:

```bash
docker logs filebeat-apache --tail=100
```

В логах видно, что Filebeat загрузил конфигурацию, обнаружил файл `/var/log/apache/access.log`, запустил harvester и установил соединение с Logstash:

```text
Configured paths: [/var/log/apache/access.log]
Harvester started for paths: [/var/log/apache/access.log]
Connection to backoff(async(tcp://logstash-apache:5045)) established
```

Скриншот — проверка логов Filebeat:
![[05-03-filebeat-apache-logs 1.png]]


---

### Проверка индекса в Elasticsearch

Была выполнена проверка индексов Elasticsearch:

```bash
curl 'localhost:9200/_cat/indices?v' | grep apache
```

В результате был найден индекс:

```text
apache-filebeat-logstash-2026.05.16
```

В индексе было создано 4 документа, что соответствует четырём тестовым HTTP-запросам к Apache.

Скриншот — проверка индекса Apache в Elasticsearch:
![[Pasted image 20260516125515.png]]


---

### Просмотр логов Apache в Kibana

В Kibana был создан новый index pattern:

```text
apache-filebeat-logstash-*
```

В качестве поля времени было выбрано:

```text
@timestamp
```

После создания index pattern был открыт раздел:

```text
Discover
```

В Discover был выбран index pattern:

```text
apache-filebeat-logstash-*
```

В интерфейсе Kibana отобразились события access-лога Apache, отправленные по цепочке Filebeat → Logstash → Elasticsearch.

На скриншоте видно, что документы содержат разобранные Logstash поля:

```text
clientip
verb
request
response
bytes
httpversion
log_source
service_name
```

Также видно, что лог относится к сервису:

```text
service_name: apache_httpd
```

Скриншот — логи Apache в Kibana, отправленные через Filebeat и Logstash:

![[Pasted image 20260516125939.png]]

---

### Итог

В рамках дополнительного задания была настроена доставка access-логов **Apache HTTP Server** в Elasticsearch через связку **Filebeat + Logstash**.

Были выполнены следующие действия:

1. был запущен контейнер Apache HTTP Server;
2. была настроена запись access-лога Apache в файл `/usr/local/apache2/logs/access.log`;
3. был настроен Filebeat для чтения файла `/var/log/apache/access.log`;
4. была настроена отправка событий из Filebeat в Logstash;
5. был настроен Logstash pipeline для разбора access-логов Apache через фильтр `grok`;
6. обработанные события были отправлены в Elasticsearch в индекс `apache-filebeat-logstash-*`;
7. в Kibana Discover были отображены события access-лога Apache с разобранными полями.

Итог: поставка логов другого сервиса, не Nginx, была успешно настроена. В качестве приложения-источника использовался **Apache HTTP Server**.

### Вывод

В ходе выполнения работы был развёрнут стек ELK на сервере с Red OS 7 с использованием Docker Compose.

Были выполнены следующие действия:

1. Запущен Elasticsearch с нестандартным именем кластера `redos-random-cluster-2026`.
2. Запущена Kibana и выполнен запрос `GET /_cluster/health?pretty` через Dev Tools.. Настроена доставка access-логов Nginx в Elasticsearch через Logstash.
3. Настроена доставка access-логов Nginx в Elasticsearch через Filebeat.
4. В Kibana созданы Data View для просмотра логов, отправленных через Logstash и Filebeat.






---

