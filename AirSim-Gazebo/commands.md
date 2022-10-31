docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai deep_sac_module"

docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai path_following_gpr"
docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai path_following_guid"
docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai path_following_att"

docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai JBNU_module"

docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 run a4vai controller"

clear

docker exec -it sitl-gz-px4 zsh -c "source /root/.zshrc ; ros2 topic echo /waypoint_indx"