#!/bin/bash

# Скрипт для создания Minecraft Paper сервера на macOS 13.0 и выше
# Автор: Хейви (YT: https://www.youtube.com/@Xeuvy, GitHub: https://github.com/Xeuvy)

# Проверка версии macOS
macos_version=$(sw_vers -productVersion)
major_version=$(echo "$macos_version" | cut -d. -f1)
if [ "$major_version" -lt 13 ]; then
    echo "Ошибка: Этот скрипт поддерживает macOS 13.0 и выше. Текущая версия: $macos_version"
    exit 1
fi

# Логирование
log_file="$HOME/mc_server_setup.log"
echo "[$(date)] Начало установки сервера Minecraft" > "$log_file"

# Проверка подключения к интернету
if ! ping -c 1 google.com &> /dev/null; then
    echo "Ошибка: Нет подключения к интернету. Проверьте соединение и попробуйте снова."
    echo "[$(date)] Ошибка: Нет подключения к интернету" >> "$log_file"
    exit 1
fi
echo "[$(date)] Проверка интернета пройдена" >> "$log_file"

# Запрос пароля sudo
echo "Введите пароль для sudo:"
sudo -v
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось получить права sudo."
    echo "[$(date)] Ошибка: Не удалось получить права sudo" >> "$log_file"
    exit 1
fi
echo "[$(date)] Sudo авторизация успешна" >> "$log_file"

# Запрос имени папки сервера
desktop_dir="$HOME/Desktop"
echo -e "\nВведите имя папки сервера:"
echo "Примечание: Если имя уже занято, будет автоматически использовано сгенерированное имя."
read server_folder

# Проверка и обработка имени папки
if [ -z "$server_folder" ]; then
    server_folder="MinecraftServer_$(date +%s)"
    echo "Имя не указано. Использовано: $server_folder"
fi

server_dir="$desktop_dir/$server_folder"

# Проверка существования папки и генерация уникального имени
if [ -d "$server_dir" ]; then
    base_folder="$server_folder"
    counter=1
    while [ -d "$server_dir" ]; do
        server_folder="${base_folder}_$counter"
        server_dir="$desktop_dir/$server_folder"
        ((counter++))
    done
    echo "Папка '$base_folder' уже существует. Использовано имя: '$server_folder'"
fi

# Создание папки сервера
mkdir -p "$server_dir"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось создать папку сервера: $server_dir"
    echo "[$(date)] Ошибка: Не удалось создать папку сервера: $server_dir" >> "$log_file"
    exit 1
fi
echo "[$(date)] Папка сервера создана: $server_dir" >> "$log_file"

# Запрос версии сервера
echo -e "\nВведите версию сервера (например, 1.16.5):"
read mc_version

# Проверка версии (диапазон 1.16.5 - 1.21.8)
valid_versions=("1.16.5" "1.17" "1.17.1" "1.18" "1.18.1" "1.18.2" "1.19" "1.19.1" "1.19.2" "1.19.3" "1.19.4" "1.20" "1.20.1" "1.20.2" "1.20.4" "1.20.5" "1.20.6" "1.21" "1.21.1" "1.21.3" "1.21.4" "1.21.5" "1.21.6" "1.21.7" "1.21.8")
valid_version=false
paper_url=""
case "$mc_version" in
    "1.21.8") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.8/builds/10/downloads/paper-1.21.8-10.jar" ;;
    "1.21.7") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.7/builds/32/downloads/paper-1.21.7-32.jar" ;;
    "1.21.6") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.6/builds/48/downloads/paper-1.21.6-48.jar" ;;
    "1.21.5") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.5/builds/114/downloads/paper-1.21.5-114.jar" ;;
    "1.21.4") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/232/downloads/paper-1.21.4-232.jar" ;;
    "1.21.3") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.3/builds/83/downloads/paper-1.21.3-83.jar" ;;
    "1.21.1") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/133/downloads/paper-1.21.1-133.jar" ;;
    "1.21") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.21/builds/130/downloads/paper-1.21-130.jar" ;;
    "1.20.6") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.6/builds/151/downloads/paper-1.20.6-151.jar" ;;
    "1.20.5") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.5/builds/22/downloads/paper-1.20.5-22.jar" ;;
    "1.20.4") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/499/downloads/paper-1.20.4-499.jar" ;;
    "1.20.2") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar" ;;
    "1.20.1") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar" ;;
    "1.20") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20/builds/17/downloads/paper-1.20-17.jar" ;;
    "1.19.4") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar" ;;
    "1.19.3") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/448/downloads/paper-1.19.3-448.jar" ;;
    "1.19.2") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/307/downloads/paper-1.19.2-307.jar" ;;
    "1.19.1") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.19.1/builds/111/downloads/paper-1.19.1-111.jar" ;;
    "1.19") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.19/builds/81/downloads/paper-1.19-81.jar" ;;
    "1.18.2") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/388/downloads/paper-1.18.2-388.jar" ;;
    "1.18.1") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.18.1/builds/216/downloads/paper-1.18.1-216.jar" ;;
    "1.18") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.18/builds/66/downloads/paper-1.18-66.jar" ;;
    "1.17.1") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.17.1/builds/411/downloads/paper-1.17.1-411.jar" ;;
    "1.17") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.17/builds/79/downloads/paper-1.17-79.jar" ;;
    "1.16.5") paper_url="https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar" ;;
    *) paper_url="" ;;
esac

if [ -z "$paper_url" ]; then
    echo "Ошибка: Указана неподдерживаемая версия. Допустимые версии: ${valid_versions[*]}"
    echo "[$(date)] Ошибка: Неподдерживаемая версия: $mc_version" >> "$log_file"
    exit 1
fi
echo "[$(date)] Выбрана версия сервера: $mc_version" >> "$log_file"

# Запрос установки Java
echo -e "\nУстановить Java?"
echo "[1] Да"
echo "[2] Нет"
echo "Примечание: В случае отказа будет использоваться системная Java."
read java_choice
if [[ ! "$java_choice" =~ ^[1-2]$ ]]; then
    echo "Ошибка: Введите 1 или 2."
    echo "[$(date)] Ошибка: Некорректный выбор Java: $java_choice" >> "$log_file"
    exit 1
fi

if [ "$java_choice" = "1" ]; then
    # Проверка и установка Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "Установка Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -ne 0 ]; then
            echo "Ошибка: Не удалось установить Homebrew."
            echo "[$(date)] Ошибка: Не удалось установить Homebrew" >> "$log_file"
            exit 1
        fi
        # Добавление Homebrew в PATH
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "[$(date)] Homebrew установлен" >> "$log_file"
    fi
    # Установка Java
    echo "Установка Java 17..."
    brew install openjdk@17
    if [ $? -ne 0 ]; then
        echo "Ошибка: Не удалось установить Java."
        echo "[$(date)] Ошибка: Не удалось установить Java" >> "$log_file"
        exit 1
    fi
    sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
    echo "[$(date)] Java 17 установлена" >> "$log_file"
else
    # Проверка системной Java
    if ! command -v java >/dev/null 2>&1; then
        echo "Ошибка: Java не найдена в системе. Пожалуйста, установите Java вручную."
        echo "[$(date)] Ошибка: Java не найдена" >> "$log_file"
        exit 1
    fi
    java_version=$(java -version 2>&1 | head -n 1 | grep -o '"[0-9]*\.[0-9]*')
    if [[ ! "$java_version" =~ ^\"17 || ! "$java_version" =~ ^\"21 ]]; then
        echo "Предупреждение: Для Paper рекомендуется Java 17 или 21. Текущая версия: $java_version"
        echo "[$(date)] Предупреждение: Неподходящая версия Java: $java_version" >> "$log_file"
    fi
    echo "[$(date)] Используется системная Java" >> "$log_file"
fi

# Загрузка Paper
echo "Загрузка Paper для версии $mc_version..."
curl -o "$server_dir/paper.jar" "$paper_url"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось загрузить Paper."
    echo "[$(date)] Ошибка: Не удалось загрузить Paper" >> "$log_file"
    exit 1
fi
echo "[$(date)] Paper успешно загружен" >> "$log_file"

# Принятие EULA
echo "eula=true" > "$server_dir/eula.txt"
echo "[$(date)] EULA принят" >> "$log_file"

# Запрос объема RAM
echo -e "\nВыберите характеристики RAM / ОЗУ сервера:"
echo "[1] 1GB - 4GB"
echo "[2] 1GB - 8GB"
echo "[3] 1GB - 16GB"
echo "[4] 1GB - 32GB"
echo "[5] 1GB - 64GB"
echo "[6] 1GB - 128GB"
echo "[7] 1GB - 256GB"
echo "[8] Без ограничений (Смотря по мощности устройства)"
echo "Примечание: Если вы выберете значение больше, чем у вас в системе, то будет выбран оптимальный вариант: 1GB - 8GB"
read ram_choice
if [[ ! "$ram_choice" =~ ^[1-8]$ ]]; then
    echo "Ошибка: Введите число от 1 до 8."
    echo "[$(date)] Ошибка: Некорректный выбор RAM: $ram_choice" >> "$log_file"
    exit 1
fi

# Получение объема оперативной памяти системы (в МБ)
total_mem=$(sysctl -n hw.memsize | awk '{print $1/1024/1024}')
case $ram_choice in
    1) max_mem=4096 ;;
    2) max_mem=8192 ;;
    3) max_mem=16384 ;;
    4) max_mem=32768 ;;
    5) max_mem=65536 ;;
    6) max_mem=131072 ;;
    7) max_mem=262144 ;;
    8)
        # Оставляем 2ГБ для системы
        max_mem=$((total_mem - 2048))
        if [ $max_mem -lt 8192 ]; then
            max_mem=8192
        fi
        ;;
esac

# Проверка, что выбранный объем RAM не превышает доступный
if [ $max_mem -gt $total_mem ]; then
    echo "Выбранный объем RAM превышает доступный. Установлен оптимальный: 1GB - 8GB."
    max_mem=8192
fi
min_mem=1024
echo "[$(date)] Выбрано RAM: $min_mem MB - $max_mem MB" >> "$log_file"

# Создание скрипта запуска
cat > "$server_dir/StartServer.sh" <<EOL
#!/bin/bash
cd "\$(dirname "\$0")"
java -Xms${min_mem}M -Xmx${max_mem}M -jar paper.jar nogui
EOL
chmod +x "$server_dir/StartServer.sh"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось создать скрипт запуска."
    echo "[$(date)] Ошибка: Не удалось создать StartServer.sh" >> "$log_file"
    exit 1
fi
echo "[$(date)] Скрипт запуска создан" >> "$log_file"

# Создание скрипта перезапуска
cat > "$server_dir/RestartServer.sh" <<EOL
#!/bin/bash
cd "\$(dirname "\$0")"
while true; do
    java -Xms${min_mem}M -Xmx${max_mem}M -jar paper.jar nogui
    echo "Сервер остановлен. Перезапуск через 5 секунд..."
    sleep 5
done
EOL
chmod +x "$server_dir/RestartServer.sh"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось создать скрипт перезапуска."
    echo "[$(date)] Ошибка: Не удалось создать RestartServer.sh" >> "$log_file"
    exit 1
fi
echo "[$(date)] Скрипт перезапуска создан" >> "$log_file"

# Вывод финального сообщения
echo -e "\n================\n"
echo "Установка сервера завершена!"
echo -e "\nПуть к папке сервера: $server_dir\n"
echo "Инструкция:\n"
echo "Запустите скрипт StartServer.sh в папке сервера,"
echo "в том же терминале будет консоль сервера."
echo -e "\n================\n"
echo "By: Хейви"
echo "YT: https://www.youtube.com/@Xeuvy"
echo "GitHub: https://github.com/Xeuvy"
echo -e "\n================\n"
echo "[$(date)] Установка завершена успешно" >> "$log_file"