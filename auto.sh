 ██████╗ ██╗  ██╗    ██████╗ ███████╗███╗   ██╗ █████╗ ███╗   ██╗
██╔═████╗╚██╗██╔╝    ██╔══██╗██╔════╝████╗  ██║██╔══██╗████╗  ██║
██║██╔██║ ╚███╔╝     ██████╔╝█████╗  ██╔██╗ ██║███████║██╔██╗ ██║
████╔╝██║ ██╔██╗     ██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║██║╚██╗██║
╚██████╔╝██╔╝ ██╗    ██║  ██║███████╗██║ ╚████║██║  ██║██║ ╚████║
 ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝

sleep 5

echo "Removing previously existing models..."
rm -rf /root/.cache/hyperspace/models/*
sleep 5

#!/bin/bash
echo "Enter your private key (end with CTRL+D):"
cat > .pem

read -p "Enter screen name: " screen_name

if [[ -z "$screen_name" ]]; then
    echo "Screen name cannot be empty."
    exit 1
fi

echo "Creating a screen session with the name '$screen_name'..."
screen -S "$screen_name" -dm

echo "Running the 'aios-cli start' command within the screen session '$screen_name'..."
screen -S "$screen_name" -X stuff "aios-cli start\n"

sleep 5

echo "Exiting the screen session '$screen_name'..."
screen -S "$screen_name" -X detach
sleep 5

if [[ $? -eq 0 ]]; then
    echo "Screen session '$screen_name' successfully created and running 'aios-cli start' command."
else
    echo "Failed to create screen session."
    exit 1
fi

sleep 2

echo "Adding model with the 'aios-cli models add' command..."
url="https://huggingface.com/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf"
model_folder="/root/.cache/hyperspace/models/hf__TheBloke___phi-2-GGUF__phi-2.Q4_K_M.gguf"
model_path="$model_folder/phi-2.Q4_K_M.gguf"

if [[ ! -d "$model_folder" ]]; then
    echo "Folder not found, creating folder $model_folder..."
    mkdir -p "$model_folder"
else
    echo "Folder already exists, continuing..."
fi

if [[ ! -f "$model_path" ]]; then
    echo "Downloading model from $url..."
    while true; do
        if wget -q "$url" -O "$model_path"; then
            echo "Model successfully downloaded and saved to $model_path!"
            break
        else
            echo "An error occurred while downloading the model. Retrying..."
            sleep 3  
        fi
    done
else
    echo "Model already exists at $model_path, skipping download."
fi

echo "Model successfully added!"

echo "Running inference using the added model..."
read -p "Do you want to run inference? (y/n): " user_choice

if [[ "$user_choice" == "y" || "$user_choice" == "Y" ]]; then
    echo "Running inference using the added model..."
    infer_prompt="Can you explain how to write an HTTP server in Rust?"

    while true; do
        if aios-cli infer --model hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf --prompt "$infer_prompt"; then
            echo "Inference successful."
            break
        else
            echo "An error occurred while running inference. Retrying..."
            sleep 3
        fi
    done
else
    echo "Inference step skipped."
fi

echo "Running import-keys command with file.pem..."
aios-cli hive import-keys ./.pem

sleep 5

echo "Running login and select-tier..."
aios-cli hive login
aios-cli hive select-tier 5
sleep 5

echo "Running Hive inference with the added model..."
read -p "Do you want to run inference for the first model? (y/n): " user_choice

if [[ "$user_choice" == "y" || "$user_choice" == "Y" ]]; then
    echo "Running inference using the added model..."
    infer_prompt="how do I support the Share it hub community?"

    while true; do
        if aios-cli infer --model hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf --prompt "$infer_prompt"; then
            echo "Inference successful."
            break
        else
            echo "An error occurred while running inference. Retrying..."
            sleep 3
        fi
    done
else
    echo "First model inference step skipped."
fi

# Asking the user whether to run hive inference
read -p "Do you want to run Hive inference? (y/n): " hive_choice

if [[ "$hive_choice" == "y" || "$hive_choice" == "Y" ]]; then
    # Running Hive inference using the added model
    echo "Running Hive inference using the added model..."
    infer_prompt="how do I support the Share it hub community?"

    while true; do
        if aios-cli hive infer --model "$model" --prompt "$infer_prompt"; then
            echo "Hive inference successful."
            break
        else
            echo "An error occurred while running Hive inference. Retrying..."
            sleep 3
        fi
    done
else
    echo "Hive inference step skipped."
fi

sleep 5

echo "Stopping the 'aios-cli start' process with 'aios-cli kill'..."
aios-cli hive login
sleep 5

aios-cli hive connect
sleep 5

echo "DONE. IF YOU WANT TO CHECK USE THE COMMAND : screen -r ""name of screen created without quotes "" !"
