#!/bin/bash
set -e  # Завжди виходити при помилці

source <(curl -s https://raw.githubusercontent.com/abzalliance/utils/master/common.sh)

# Оновлення та оновлення пакетів
printPurple "✅ Оновлення та оновлення списку пакетів..."
sudo apt update -y && sudo apt upgrade -y || { printPurple "❌ Не вдалося оновити пакети"; exit 1; }

# Видалення конфліктних пакетів Docker
printPurple "🔧 Видалення конфліктних пакетів Docker..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || { printPurple "❌ Не вдалося видалити пакет $pkg"; exit 1; }
done

# Встановлення необхідних пакетів
printPurple "🔧 Встановлення необхідних пакетів: ca-certificates, curl, gnupg..."
sudo apt-get update || { printPurple "❌ Не вдалося оновити пакети"; exit 1; }
sudo apt-get install -y ca-certificates curl gnupg || { printPurple "❌ Не вдалося встановити необхідні пакети"; exit 1; }

# Додавання офіційного GPG ключа Docker
printPurple "🔑 Додавання офіційного GPG ключа Docker..."
sudo install -m 0755 -d /etc/apt/keyrings || { printPurple "❌ Не вдалося створити директорію keyrings"; exit 1; }
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || { printPurple "❌ Не вдалося додати GPG ключ Docker"; exit 1; }
sudo chmod a+r /etc/apt/keyrings/docker.gpg || { printPurple "❌ Не вдалося встановити права на GPG ключ Docker"; exit 1; }

# Налаштування репозиторію Docker
printPurple "📦 Налаштування репозиторію Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || { printPurple "❌ Не вдалося налаштувати репозиторій Docker"; exit 1; }

# Оновлення та оновлення пакетів після додавання репозиторію Docker
printPurple "✅ Оновлення списку пакетів після додавання репозиторію Docker..."
sudo apt update -y && sudo apt upgrade -y || { printPurple "❌ Не вдалося оновити пакети після додавання репозиторію Docker"; exit 1; }

# Встановлення Docker Engine та Docker Compose
printPurple "🐳 Встановлення Docker Engine, Docker CLI, containerd та Docker Compose plugin..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || { printPurple "❌ Не вдалося встановити Docker компоненти"; exit 1; }

# Надання прав на Docker Compose
printPurple "🔧 Надавання прав на Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose || { printPurple "❌ Не вдалося надати права на Docker Compose"; exit 1; }

# Перевірка версії Docker
printPurple "🐳 Перевірка версії Docker..."
docker --version || { printPurple "❌ Перевірка Docker не вдалася"; exit 1; }

# Встановлення Ollama
printPurple "📦 Встановлення Ollama..."
curl -fsSL https://ollama.com/install.sh | sh || { printPurple "❌ Не вдалося встановити Ollama"; exit 1; }

# Завантаження та налаштування DKN Compute Node
printPurple "📥 Завантаження DKN Compute Node..."
cd "$HOME" || { printPurple "❌ Не вдалося перейти до домашньої директорії"; exit 1; }
curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip || { printPurple "❌ Не вдалося завантажити DKN Compute Node"; exit 1; }

printPurple "📦 Розпаковка DKN Compute Node..."
unzip dkn-compute-node.zip || { printPurple "❌ Не вдалося розпакувати DKN Compute Node"; exit 1; }
cd dkn-compute-node || { printPurple "❌ Не вдалося перейти до директорії DKN Compute Node"; exit 1; }

printPurple "🚀 Запуск DKN Compute Launcher..."
./dkn-compute-launcher || { printPurple "❌ Не вдалося запустити DKN Compute Launcher"; exit 1; }

# Інструкції для користувача
printPurple "ℹ️ Будь ласка, виконайте наступні дії вручну:"
printPurple "1️⃣ Введіть ваш DKN wallet Secret key (Ваш приватний ключ Metamask без 0x)"
printPurple "2️⃣ Виберіть модель: Рекомендація Gemini (1500 запитів в день безкоштовно (10)) або OpenRouter (Платно, але поінти краще капають (25))"
printPurple "3️⃣ Пропустіть Jina & Serper API key, натиснувши Enter"
printPurple "4️⃣ Ваш вузол почне завантажувати моделі та тестувати їх"
printPurple "❗ Якщо виникнуть конфлікти портів, змініть порти в файлі .env або використовуйте команду: nano $HOME/dkn-compute-node/.env"
printPurple "🔄 Для перезапуску вузла, очистіть змінну DKN_MODELS= у файлі .env та знову запустіть Dria: ./dkn-compute-launcher"

# Налаштування Screen для фонової роботи
printPurple "📺 Налаштування Screen для запуску вузла у фоновому режимі..."
screen -S dria || { printPurple "❌ Не вдалося створити сесію Screen"; exit 1; }
./dkn-compute-launcher || { printPurple "❌ Не вдалося запустити DKN Compute Launcher у Screen"; exit 1; }
printPurple "📉 Мінімізація Screen з CTRL+A+D"
printPurple "🔍 Щоб повернутися до Screen: screen -r dria"
