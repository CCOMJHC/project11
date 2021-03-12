
# Installing Project 11's backseat driver system and simulator.

## Introduction

CCOM/JHC's ASVs are capable of operating with a backseat driver, which is a computer not supplied by the manufaturer capable of taking control of the vehicle by supplying throttle or speed and rudder or heading commands. The vehicle's manufacturer supplied computer accepts such commands via a [ROS](http://www.ros.org/) interface.

ROS is offically supported on Ubuntu Linux so the Project 11 system runs on Ubuntu. The actual system consists of two separate computers, each running Ubuntu, comunicating over an unreliable wireless connection. For simulation puposes, the system has been designed to also work on a single computer.

A common directory structure has been created that typically resides in the user's home directory. The same structure is used both on the vehicle and on the operator station.

    project11/
    ├── catkin_ws
    ├── configuration
    ├── documentation
    ├── executed_missions
    ├── log
    ├── ros
    └── scripts

ROS development is done in the catkin_ws directory while ROS uses the ros directory at runtime. The documentation directory is where this and other documents live. The scripts directory contains useful shell scripts that help during development and operation.

## Background knowledge

### Ubuntu Linux

The ROS tutorials recommend [this page](http://www.ee.surrey.ac.uk/Teaching/Unix/) for beginner Unix tutorials.

### ROS

Project 11 uses the Noetic version of ROS. It is recomended to go through the [ROS Tutorials](http://wiki.ros.org/ROS/Tutorials) in order to better understand how it works.

### Git

TODO: Add git tutorials. [git book](https://git-scm.com/book/en/v2).

### Programing

Knowledge of Python or C++ is necessary for development.

#### Python

TODO Pyhton tutorials. (Python's own tutorial has served me well)

#### C++

TODO C++ tutorials.

## Prerequisite

The Project 11 system is based on ROS Noetic so it is designed to run on an Ubuntu 20.04 system.

If an Ubuntu 20.04 machine is not readily available, a virtual machine may be setup for this purpose.

### Setting up an Ubuntu virtual machine

These instructions were developed using VirtualBox on Ubuntu. Similar steps should work with VMWare as well.

  * Obtain an Ubuntu 20.04 iso install image from the [Ubuntu download page](https://ubuntu.com/download/desktop). 
  * Create a virtual machine for a 64-bit Ubuntu install with the following specs:
    * 4GB or more of memory. (TODO: do we need more? At 1GB, ran out of memory compiling QT5)
    * 50GB or more of hard drive space.
  * Insert the downloaded Ubuntu iso image in the virtual machine's optical drive and start the virtual machine.
  * Chose "Install Ubuntu" when presented the choice.
  * Select "Download updates while installing Ubuntu" and optonally select "Install third-party software" (TODO: do this last one make a difference?)
  * Continue with default "Erase disk and install Ubuntu".
  * Pick reasonable values for timezone and languages.
  * Create a user account for yourself (for a shared machine, you may create a field account instead).
  * Install guest additions or equivalent. (Caution, skipping this step with VMWare may have caused diplay errors on boot later on.)

Once Ubuntu is installed, you can make sure it's up to date by doing a apt-get update followed by an apt-get upgrade.

    sudo apt-get update
    sudo apt-get upgrade

## Installing ROS

Follow the instructions on the [Ubuntu install of ROS Noetic](http://wiki.ros.org/noetic/Installation/Ubuntu) page, picking the Desktop-Full installation.

If you are new to ROS, now is a good time to follow the ROS tutorials.

## Configuring git.

Make sure git is installed.

    sudo apt install git

The version control client git should already be installed so it only needs to be configured. The git book's [First Time Git Setup page](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup) contains instructions on how to configure your name and email address so that commits get attributed to you.

    git config --global user.name "Field User"
    git config --global user.email field@ccom.unh.edu

## Creating the Project 11 directory structure.

Fetching the Project11 workspace. 

    git clone --recursive https://github.com/CCOMJHC/project11.git

Alternatively, you may want to use SSH if you have an SSH key setup on github.

    git clone --recursive git@github.com:CCOMJHC/project11.git

Install additional packages available from the package manager.
    
    sudo project11/scripts/install_noetic_prereq_packages.bash
    sudo apt-get install python3-rosdep
    rosdep update
    cd project11/catkin_ws
    rosdep install --from-paths src --ignore-src -r -y
    
## Build the packages
Build in the catkin workspace.

    cd project11/catkin_ws
    catkin_make

Normally, the Project 11 Catkin workspace is the only one used, so we can make it the default workspace when logging in by sourcing the setup script from .bashrc.

    echo "source ~/project11/catkin_ws/devel/setup.bash" >> ~/.bashrc
    source ~/.bashrc

### Optional approach if using multiple workspaces
    
A more general approach if working with several catkin workspaces is to use the following alias to source the setup script (this alias is to be added to ~/.bashrc)


    function wsource() {
      WS_SETUP_SCRIPT=`catkin locate -qd`/setup.bash
      if [ -e $WS_SETUP_SCRIPT ];
      then
        echo -e "\e[32mAuto sourcing ros workspace at $WS_SETUP_SCRIPT\e[0m"
        source $WS_SETUP_SCRIPT
      fi
    }

Usage: call wsource once inside your catkin workspace.

## Run the simulation

Once catkin_make completes without error in ~/project11/catkin_ws/, we can try starting the simulation.

    roslaunch project11 sim_local.launch

You may encouter an error about a python script not being able to import a module. That may indicate that the catkin workspace's setup script needs to be resourced.

    source ~/project11/catkin_ws/devel/setup.bash

Once sim_local.launch is succesfully launch, we can verify that things are running:

    rostopic list
    rostopic echo /udp/position
    
    
## Contributing back to Project11

The standard way in "github" to contribute code and other changes back into a repository is to "fork" the repository. This creates a copy of the repository in your own github account to which you can push modifications as you wish.
But you cannot modify the code in the forked version of the repository directly, because it is on the github server. Rather you add a remote in the previously cloned copy on your local machine pointing to your github fork. You can make changes and "push" them back to your forked copy on github.
Finally, if you want to contribute your changes back to the original offical CCOMJHC repository you navigate to that repo on github and create a "pull request". This is a request for the maintainer of the CCOMJHC repository to "pull" your changes back into the original repository. If he/she agrees with your suggested changes, your request will be granted and your code will become part of the official archive.

Thus in addition to cloning the repositories as shown above, you may also want to fork the ones you wish to modify into your own github account and add remotes pointing to the forked copies.

## rviz

With the simulation running, rviz may be launched in a new terminal.

    rviz
    
A configuration file showing the map frame of reference as well as the simulated boat, named base_link, can be found at ~/project11/catkin_ws/src/project11/rviz/transforms.rviz. 

## Downloading NOAA raster navigation chart for CAMP

CAMP uses georeferenced raster images as background layers. The simulations defaults to Portsmouth Harbor in New Hampshire, so a raster nautical chart works fine as a background layer. NOAA chart 13283 has been included for your convenince.

In CAMP, File->Open Background or the BG button, and open 13283_2.KAP.
