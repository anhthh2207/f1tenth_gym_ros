#!/bin/bash
SESSION="f1tenth"
read -sp "Enter password: " PASSWORD
LAYOUT="990a,179x55,0,0{89x55,0,0[89x13,0,0,5,89x13,0,14,30,89x27,0,28,8],89x55,90,0[89x27,90,0,6,89x27,90,28,7]}" # NOTE: achieve by `tmux list-windows -F '#{window_layout}'`

# check the password
echo "$PASSWORD" | sudo -S -v
if [ $? -eq 0 ]; then
  echo "Password correct, proceeding..."
  # Place the rest of your script here
else
  echo "Incorrect password, exiting."
  return 1
fi

# If a session with the same name exists, kill it.
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "detect running session with the same name. kill the existing session to start a new one"
    for pane in $(tmux list-panes -t "$SESSION" -F '#{pane_id}'); do
        tmux send-keys -t "$pane" C-c
    done
    tmux kill-session -t "$SESSION"
    sleep 2.5 # sleep here for the robustness of the process
fi

# Create a new detached session and layout
tmux new-session -d -s "$SESSION" -n main
for i in {1..4}; do
  tmux split-window -t "$SESSION:main.0"
done
tmux select-layout -t "$SESSION:main" "$LAYOUT"


# run docker compose
tmux send-keys -t "$SESSION:main.0" "echo '$PASSWORD'| sudo -S docker-compose up" C-m

# launch the simulation
tmux send-keys -t "$SESSION:main.1" "echo '$PASSWORD'| sudo -S whoami" C-m
tmux send-keys -t "$SESSION:main.1" "sleep 2.5 && \ 
                                    sudo docker exec -it f1tenth_gym_ros_sim_1 /bin/bash" C-m # sleep for the robustness of the process
tmux send-keys -t "$SESSION:main.1" "source /opt/ros/foxy/setup.bash && \
                                    colcon build && source install/local_setup.bash && \
                                    ros2 launch f1tenth_gym_ros gym_bridge_launch.py" C-m

# attach to the containter in other panes
tmux send-keys -t "$SESSION:main.3" "echo '$PASSWORD'| sudo -S whoami" C-m
tmux send-keys -t "$SESSION:main.3" "sleep 2.5 && \
                                    sudo docker exec -it f1tenth_gym_ros_sim_1 /bin/bash" C-m # sleep here for the robustness of the process
tmux send-keys -t "$SESSION:main.3" "cd ~ && clear" C-m
tmux send-keys -t "$SESSION:main.3" "echo 'check this address from your window browser http://localhost:8080/vnc.html'" C-m
tmux send-keys -t "$SESSION:main.3" "ls" C-m

tmux send-keys -t "$SESSION:main.2" "clear" C-m
tmux send-keys -t "$SESSION:main.2" "sudo docker exec -it f1tenth_gym_ros_sim_1 /bin/bash"

tmux send-keys -t "$SESSION:main.4" "clear" C-m
tmux send-keys -t "$SESSION:main.4" "sudo docker exec -it f1tenth_gym_ros_sim_1 /bin/bash"

# attach to the session
tmux attach-session -t "$SESSION"
