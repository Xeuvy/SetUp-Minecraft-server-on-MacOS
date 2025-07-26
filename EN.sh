#!/bin/bash

# Script to set up a Minecraft Paper server on macOS 13.0 and above
# Author: Хейви (YT: https://www.youtube.com/@Xeuvy, GitHub: https://github.com/Xeuvy)

# Check macOS version
macos_version=$(sw_vers -productVersion)
major_version=$(echo "$macos_version" | cut -d. -f1)
if [ "$major_version" -lt 13 ]; then
    echo "Error: This script supports macOS 13.0 and above. Current version: $macos_version"
    exit 1
fi

# Logging
log_file="$HOME/mc_server_setup.log"
echo "[$(date)] Starting Minecraft server setup" > "$log_file"

# Check internet connection
if ! ping -c 1 google.com &> /dev/null; then
    echo "Error: No internet connection. Please check your connection and try again."
    echo "[$(date)] Error: No internet connection" >> "$log_file"
    exit 1
fi
echo "[$(date)] Internet check passed" >> "$log_file"

# Prompt for sudo password
echo "Enter your sudo password:"
sudo -v
if [ $? -ne 0 ]; then
    echo "Error: Failed to obtain sudo privileges."
    echo "[$(date)] Error: Failed to obtain sudo privileges" >> "$log_file"
    exit 1
fi
echo "[$(date)] Sudo authentication successful" >> "$log_file"

# Prompt for server folder name
desktop_dir="$HOME/Desktop"
echo -e "\nEnter the server folder name:"
echo "Note: If the name is already taken, a generated name will be used automatically."
read server_folder

# Validate and process folder name
if [ -z "$server_folder" ]; then
    server_folder="MinecraftServer_$(date +%s)"
    echo "No name provided. Using: $server_folder"
fi

server_dir="$desktop_dir/$server_folder"

# Check for existing folder and generate unique name if needed
if [ -d "$server_dir" ]; then
    base_folder="$server_folder"
    counter=1
    while [ -d "$server_dir" ]; do
        server_folder="${base_folder}_$counter"
        server_dir="$desktop_dir/$server_folder"
        ((counter++))
    done
    echo "Folder '$base_folder' already exists. Using name: '$server_folder'"
fi

# Create server folder
mkdir -p "$server_dir"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create server folder: $server_dir"
    echo "[$(date)] Error: Failed to create server folder: $server_dir" >> "$log_file"
    exit 1
fi
echo "[$(date)] Server folder created: $server_dir" >> "$log_file"

# Prompt for server version
echo -e "\nEnter the server version (e.g., 1.16.5):"
read mc_version

# Validate version (range 1.16.5 - 1.21.8)
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
    echo "Error: Unsupported version specified. Supported versions: ${valid_versions[*]}"
    echo "[$(date)] Error: Unsupported version: $mc_version" >> "$log_file"
    exit 1
fi
echo "[$(date)] Selected server version: $mc_version" >> "$log_file"

# Prompt for Java installation
echo -e "\nInstall Java?"
echo "[1] Yes"
echo "[2] No"
echo "Note: If you choose No, the system Java will be used."
read java_choice
if [[ ! "$java_choice" =~ ^[1-2]$ ]]; then
    echo "Error: Please enter 1 or 2."
    echo "[$(date)] Error: Invalid Java choice: $java_choice" >> "$log_file"
    exit 1
fi

if [ "$java_choice" = "1" ]; then
    # Check and install Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install Homebrew."
            echo "[$(date)] Error: Failed to install Homebrew" >> "$log_file"
            exit 1
        fi
        # Add Homebrew to PATH
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "[$(date)] Homebrew installed" >> "$log_file"
    fi
    # Install Java
    echo "Installing Java 17..."
    brew install openjdk@17
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Java."
        echo "[$(date)] Error: Failed to install Java" >> "$log_file"
        exit 1
    fi
    sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
    echo "[$(date)] Java 17 installed" >> "$log_file"
else
    # Check system Java
    if ! command -v java >/dev/null 2>&1; then
        echo "Error: Java not found on the system. Please install Java manually."
        echo "[$(date)] Error: Java not found" >> "$log_file"
        exit 1
    fi
    java_version=$(java -version 2>&1 | head -n 1 | grep -o '"[0-9]*\.[0-9]*')
    if [[ ! "$java_version" =~ ^\"17 || ! "$java_version" =~ ^\"21 ]]; then
        echo "Warning: Paper recommends Java 17 or 21. Current version: $java_version"
        echo "[$(date)] Warning: Incompatible Java version: $java_version" >> "$log_file"
    fi
    echo "[$(date)] Using system Java" >> "$log_file"
fi

# Download Paper
echo "Downloading Paper for version $mc_version..."
curl -o "$server_dir/paper.jar" "$paper_url"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Paper."
    echo "[$(date)] Error: Failed to download Paper" >> "$log_file"
    exit 1
fi
echo "[$(date)] Paper downloaded successfully" >> "$log_file"

# Accept EULA
echo "eula=true" > "$server_dir/eula.txt"
echo "[$(date)] EULA accepted" >> "$log_file"

# Prompt for RAM allocation
echo -e "\nSelect server RAM allocation:"
echo "[1] 1GB - 4GB"
echo "[2] 1GB - 8GB"
echo "[3] 1GB - 16GB"
echo "[4] 1GB - 32GB"
echo "[5] 1GB - 64GB"
echo "[6] 1GB - 128GB"
echo "[7] 1GB - 256GB"
echo "[8] Maximum available (based on system resources)"
echo "Note: If you select a value larger than your system's capacity, the optimal option (1GB - 8GB) will be chosen."
read ram_choice
if [[ ! "$ram_choice" =~ ^[1-8]$ ]]; then
    echo "Error: Please enter a number from 1 to 8."
    echo "[$(date)] Error: Invalid RAM choice: $ram_choice" >> "$log_file"
    exit 1
fi

# Get system memory (in MB)
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
        # Reserve 2GB for the system
        max_mem=$((total_mem - 2048))
        if [ $max_mem -lt 8192 ]; then
            max_mem=8192
        fi
        ;;
esac

# Check if selected RAM exceeds available memory
if [ $max_mem -gt $total_mem ]; then
    echo "Selected RAM exceeds available memory. Defaulting to optimal: 1GB - 8GB."
    max_mem=8192
fi
min_mem=1024
echo "[$(date)] Selected RAM: $min_mem MB - $max_mem MB" >> "$log_file"

# Create start script
cat > "$server_dir/StartServer.sh" <<EOL
#!/bin/bash
cd "\$(dirname "\$0")"
java -Xms${min_mem}M -Xmx${max_mem}M -jar paper.jar nogui
EOL
chmod +x "$server_dir/StartServer.sh"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create start script."
    echo "[$(date)] Error: Failed to create StartServer.sh" >> "$log_file"
    exit 1
fi
echo "[$(date)] Start script created" >> "$log_file"

# Create restart script
cat > "$server_dir/RestartServer.sh" <<EOL
#!/bin/bash
cd "\$(dirname "\$0")"
while true; do
    java -Xms${min_mem}M -Xmx${max_mem}M -jar paper.jar nogui
    echo "Server stopped. Restarting in 5 seconds..."
    sleep 5
done
EOL
chmod +x "$server_dir/RestartServer.sh"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create restart script."
    echo "[$(date)] Error: Failed to create RestartServer.sh" >> "$log_file"
    exit 1
fi
echo "[$(date)] Restart script created" >> "$log_file"

# Display final message
echo -e "\n================\n"
echo "Server setup completed!"
echo -e "\nServer folder path: $server_dir\n"
echo "Instructions:\n"
echo "Run the StartServer.sh script in the server folder,"
echo "and the server console will open in the same terminal."
echo -e "\n================\n"
echo "By: Хейви"
echo "YT: https://www.youtube.com/@Xeuvy"
echo "GitHub: https://github.com/Xeuvy"
echo -e "\n================\n"
echo "[$(date)] Setup completed successfully" >> "$log_file"