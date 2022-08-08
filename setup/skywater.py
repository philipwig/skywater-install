import argparse, toml
import os
import subprocess
from datetime import datetime
from pathlib import Path

config_file = os.path.abspath(os.path.dirname(__file__)) + "/config.toml"

class _HelpAction(argparse._HelpAction):
    def __call__(self, parser, namespace, values, option_string=None):
        parser.print_help()

        # retrieve subparsers from parser
        subparsers_actions = [
            action for action in parser._actions
            if isinstance(action, argparse._SubParsersAction)
        ]
        # there will probably only be one subparser_action,
        # but better save than sorry
        for subparsers_action in subparsers_actions:
            # get all subparsers and print help
            for choice, subparser in subparsers_action.choices.items():
                print("Subparser '{}'".format(choice))
                print(subparser.format_help())

        parser.exit()


# function to build 
def build(args):
    # load config from config file
    config = toml.load(config_file)
    config_images = config['images']

    # Set install directory path
    install_dir = str(Path.home()) + "/tools"

    # print info
    print("\n------------------------------------------------------------")
    print("Running install from config.toml")
    print("Building " + str(len(config_images.keys())) + " images")
    print("View script output and error log in scripts folder")
    print("------------------------------------------------------------\n")

    # count number of images
    image_count = 0

    for image in config_images.keys():
        # get current image install script path
        image_path = os.path.abspath(os.path.dirname(__file__)) + "/scripts/" + image

        # increment current image number
        image_count += 1

        # print script status
        print("INFO: Building image " + str(image_count) + " of " + str(len(config_images.keys())))
        print("INFO: Running " + image + " install script")

        # open log and error files
        with open(image_path + '/log.txt', 'w') as std_out, open(image_path + '/err.txt', 'w') as std_err:
            # run install script as subprocess forwarding stderr and stout to err and log file
            return_value = subprocess.run([image_path + "/install.sh", install_dir, config_images[image]['url'], config_images[image]['commit_id']], stdout=std_out, stderr=std_err)

            # check return code of install script to see if install was sucessful
            if(return_value.returncode == 0):
                print("SUCCESS: " + image + " installed successfully!\n")
            else:
                print("ERROR: " + image + " install failed. Check log.txt and err.txt in image folder\n")
            
            # append timestamp err and log files
            iso_date = datetime.now().isoformat()
            std_out.write("\nFile Created: " + iso_date + "\n")
            std_out.write("Script last updated: " + str(config["last_update"]) + "\n")
            std_err.write("\nFile Created: " + iso_date + "\n")
            std_err.write("Script last updated: " + str(config["last_update"]) + "\n")






# get most recent commit id
def get_latest_commit(url):
    process = subprocess.Popen(["git", "ls-remote", "--exit-code", url, "HEAD"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    
    latest_commit = ""
    if (process.returncode == 0):
        latest_commit = stdout.decode('ascii').split()[0]
    elif (process.returncode == 2):
        print("could not get remote repository")

    return latest_commit


# updates the specified image
def update_image(config, image, skip_prompt):

    if skip_prompt:
        config['images'][image]['commit_id'] = get_latest_commit(config['images'][image]['url'])
    else:
        # get latest commit
        new_version = get_latest_commit(config['images'][image]['url'])

        # prompt user if commit is new
        if (new_version != config['images'][image]['commit_id']):
            user_response = ""
            while user_response not in ("y", "yes",  "n", "no"):
                # prompt for user input
                print("\nA new commit for (%s) is available:\n%s" % (image, new_version))
                user_response = input("Would you like to update? [Y/n] ").lower()

                if (user_response in ("y", "yes")):
                    config['images'][image]['commit_id'] = new_version
                elif (user_response not in ("n", "no")):
                    print("\nPlease answer yes or no [Y/n]")


# update specified images
def update(args):
    # load config from config file
    config = toml.load(config_file)

    try:
        config_images = config['images'].keys()
    except KeyError:
        print("ERROR: Ensure config file exists and contains all the necessary config values")
        exit()

    print("Images read from config file: " + ", ".join(list(config_images)))

    # update specified image(s)
    if args.image == "all":
        for image in config_images:
            update_image(config, image, args.yes)
            # new_config = update_image(config, image, args.yes)
    elif args.image in config_images:
        update_image(config, args.image, args.yes)
        # new_config = update_image(config, args.image, args.yes)
    else:
        print("ERROR: Could not find valid image name")
        exit()

    # Update date of last update
    config['last_update'] = datetime.now().date()

    # write config to file if it changed
    if (config != toml.load(config_file)):
        with open(config_file, 'w') as f:
            toml.dump(config, f)
        print("Wrote new config to " + config_file)
    else:
        print("Config file already up to date")

    # prompt user to rebuild images if config changed
    # if (new_config != config):
    #     user_response = ""
    #     while user_response not in ("y", "yes",  "n", "no"):
    #         # prompt for user input
    #         print("\nA new commit for (%s) is available:\n%s" % (image, new_version))
    #         user_response = input("Would you like to update? [Y/n] ").lower()

    #         if (user_response in ("y", "yes")):
    #             config['images'][image]['commit_id'] = new_version
    #         elif (user_response not in ("n", "no")):
    #             print("\nPlease answer yes or no [Y/n]")

def clean(args):
    print("test")

if __name__ == '__main__':
    # create the top-level parser
    parser = argparse.ArgumentParser(
        description="A tool that builds and updates a set of docker images",
        add_help=False)

    parser.add_argument("-h",
                        "--help",
                        action=_HelpAction,
                        help="show help message and exit")

    subparsers = parser.add_subparsers()


    # create parser for "build" command
    build_subparser = subparsers.add_parser("build", help="build one or more images")
    # build_subparser.add_argument("--all", action="store_true")
    build_subparser.add_argument("-i", "--image", type=str, default='final')
    build_subparser.set_defaults(func=build)


    # create parser for "update" command
    update_subparser = subparsers.add_parser("update",
                                            help="update one or more image")
    update_subparser.add_argument("-y", "--yes", action="store_true")
    update_subparser.add_argument("-i", "--image", nargs='?', type=str, default="all")
    update_subparser.set_defaults(func=update)

    # # create parser for "recipe" command
    # recipe_subparser = subparsers.add_parser("recipe",
    #                                          help="build images in a recipe file")
    # recipe_group = recipe_subparser.add_mutually_exclusive_group(required=True)
    # recipe_group.add_argument("--json", type=str)
    # recipe_group.add_argument("--csv", type=str)
    # recipe_subparser.add_argument(
    #     "--update-reference",
    #     help=
    #     "update reference in a recipe file. Run without --update-reference to update the tool(s) afterwards",
    #     action="store_true")
    # recipe_subparser.set_defaults(func=handleRecipe)

    # create parser for "run" command
    # update_subparser = subparsers.add_parser("run", help="run an image")
    # # update_subparser.add_argument("-i", "--image", nargs='?', type=str, default="all")
    # update_subparser.add_argument('command', nargs='?', type=str, default="/bin/bash")
    # update_subparser.add_argument("-v", "--volume", nargs='?', type=str, default="all")
    # update_subparser.set_defaults(func=run)
    # TODO: Add option to set path to mount design directory to


    # parse the args and call whatever function was selected
    args = parser.parse_args()
    args.func(args)
