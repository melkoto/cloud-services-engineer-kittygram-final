# Kittygram

Kittygram – это веб-приложение для обмена фотографиями кошек. Проект включает в себя бэкенд, фронтенд и шлюз (gateway), а также полностью автоматизированное развёртывание инфраструктуры и приложения с помощью Terraform, Docker Compose и GitHub Actions.   

Проект развернут на http://51.250.24.239


## Содержание

- [Требования](#требования)
- [Используемые технологии](#используемые-технологии)
- [Структура репозитория](#структура-репозитория)
- [Развёртывание инфраструктуры](#развёртывание-инфраструктуры)
- [Деплой приложения](#деплой-приложения)
- [CI/CD](#cicd)
- [Чек-лист проектной работы](#чек-лист-проектной-работы)
- [Полезные ссылки](#полезные-ссылки)
- [Контакты](#контакты)

## Требования

- Развёртывание инфраструктуры должно выполняться автоматически через Terraform.
- Приложение должно корректно деплоиться и работать без ошибок.
- Безопасность должна обеспечиваться через правильно настроенные Security Groups.
- Конфигурация cloud-init должна запускаться при первом старте ВМ и устанавливать все необходимые компоненты (например, Docker).
- Функциональность приложения полностью соответствует описанию задания.

## Используемые технологии

- **Terraform** – для описания и развёртывания облачной инфраструктуры (VPC, подсети, виртуальные машины, Security Groups).
- **Docker & Docker Compose** – для упаковки и запуска компонентов приложения (бэкенд, фронтенд, gateway, база данных).
- **Cloud-init** – для автоматической первоначальной настройки виртуальной машины (установка Docker, настройка пользователя, создание нужных директорий).
- **GitHub Actions** – для автоматизации CI/CD-процессов (планирование, сборка, тестирование и деплой).
- **PostgreSQL** – в качестве базы данных.


## Развёртывание инфраструктуры

Инфраструктура описана с помощью Terraform и включает:

- **VPC и подсеть:**  
  Создаются облачная сеть и подсеть с указанным CIDR-блоком.
- **Security Group:**  
  Настроена так, чтобы разрешать входящие соединения только для SSH и HTTP (или других нужных портов).

Чтобы развернуть инфраструктуру, выполните следующие команды (или воспользуйтесь GitHub Actions):

1. Инициализация Terraform:
   ```bash
   terraform init
   ```

2. Просмотр плана:
    ```bash
    terraform plan
    ```
   
3. Применение конфигурации:
    ```bash
    terraform apply
    ```

## Деплой приложения
Приложение Kittygram разворачивается с использованием Docker Compose. В файле docker-compose.production.yml описаны следующие сервисы:
- PostgreSQL: база данных с настройками healthcheck (использование pg_isready).
- Backend: Docker-образ бэкенда (Django).
- Frontend: Docker-образ фронтенда.
- Gateway: Docker-образ Nginx, который проксирует запросы к бэкенду и фронтенду.

Для деплоя на удалённом сервере используется GitHub Actions, который:
- Копирует docker-compose.yml (или docker-compose.production.yml) на сервер.
- Выполняет SSH-команды для остановки старых контейнеров, обновления образов и перезапуска приложения.
- Выполняет миграции и сбор статики для бэкенда.

## CI/CD
В репозитории настроены два workflow-файла:
1) Terraform Workflow (terraform.yml):
- Инициализация, планирование и применение конфигурации Terraform.
- Ожидание завершения cloud-init (ждёт 10 минут).

2) Deploy Workflow (deploy.yml):
- Тестирование бэкенда и фронтенда.
- Сборка и пуш Docker-образов в DockerHub.
- Деплой на удалённом сервере через SCP и SSH.
- Отправка уведомления в Telegram после успешного деплоя.

```yaml
- name: Executing remote ssh commands to deploy
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.SSH_HOST }}
    username: ${{ secrets.SSH_USERNAME }}
    key: ${{ secrets.SSH_KEY }}
    script: |
      set -e
      mkdir -p ~/kittygram
      cat <<EOF > ~/kittygram/.env
      SECRET_KEY=${{ secrets.SECRET_KEY }}
      DEBUG=${{ secrets.DEBUG }}
      DB_ENGINE=${{ secrets.DB_ENGINE }}
      DB_NAME=${{ secrets.DB_NAME }}
      POSTGRES_DB=${{ secrets.POSTGRES_DB }}
      POSTGRES_USER=${{ secrets.POSTGRES_USER }}
      POSTGRES_PASSWORD=${{ secrets.POSTGRES_PASSWORD }}
      DB_HOST=${{ secrets.DB_HOST }}
      DB_PORT=${{ secrets.DB_PORT }}
      EOF
      cd ~/kittygram
      sudo docker compose -f docker-compose.yml down
      sudo docker compose -f docker-compose.yml pull
      sudo docker compose -f docker-compose.yml up -d
      sudo docker compose -f docker-compose.yml exec backend python manage.py migrate
      sudo docker compose -f docker-compose.yml exec backend python manage.py collectstatic --noinput
      sudo docker system prune -af
```
