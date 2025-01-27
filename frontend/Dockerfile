# Используем базовый образ Node.js версии 18
FROM node:18

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json для установки зависимостей
COPY package.json package-lock.json ./

# Устанавливаем зависимости
RUN npm ci

# Копируем весь проект в контейнер
COPY . .

# Выполняем сборку проекта
RUN npm run build

# Устанавливаем глобально сервер serve
RUN npm install --global serve

# Команда запуска контейнера
CMD ["serve", "-s", "build", "-l", "8000"]
