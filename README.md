# Skywater PDK Install

I have created a script that will automatically create, install, and configure an lxc container for the skywater pdk and tools.
This container will attach to the native xserver to run the gui apps like they were installed natively.
The python script in the setup folder can also be used standalone without the lxc container to install the skywater tools.

See [here](https://philipwig.com/tutorials/installing-skywater) for more details.

## Usage

The `init-lxd.sh` script will create a lxc container for the skywater tools.

To run the python script to install all of the tools,

```bash
python setup/skywater.py build
```

This will build and install all of the tools specified in the `setup/config.toml` file.
They will be installed into their default install locations or the `~/tools` directory.

## Configuration

The versions of the installed tools can be configured by editing the `config.toml` file which contains the commit ids that will be installed.

If you want to update the tools versions to the latest versions run the following command.
The `-y` option can be appended to the command to automatically accept all of the changes.

```bash
python setup/skywater.py update
```

The tools specified in the `config.toml` will be installed in the order that they are listed there, so make sure that if any of the programs depend on another (open_pdks for example), that they are listed in the correct order.

All of the install scripts are located in the `setup/scripts` folder.
The python script will also create log and error files in each of the respective tools folders.
If there are errors during the install, check those files to see what went wrong.

You can also edit the install scripts if you want to customize your install.

To add another program to be installed, just create another folder with an install script named `install.sh`.
The python program passes three options into the script, first is the install directory, second is the git url, and the third is the git commit id.
Finally add the new program to the `setup/config.toml` file and the new program should be installed and managed along with all of the other tools.
