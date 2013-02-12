Shellwrapper
============

This script is a wrapper to run several shell scripts located in a folder.

See example.sh for an example how to call.

Features
--------

- Running scripts in alphabetical order
- Running .sh files as subshells (using sh -e)
- Running .exportsh files as sourced shells (using source)
- Run tag specific files only if the tag is passed (e.g. myfile.mytag.sh)

Arguments
---------

1. The relative or absolute path of the folder the scripts are located.
2. (optional) a string that is used as tag. Multiple tags can be separated by
   comma ","

Our use case
------------

We use that wrapper to call several scripts, that are made to update our Drupal
sites. Therefore we place drush commands (and some others) in different files
to structure them in topic groups and in an alphabetical/numerial order.

The tag is used to run scripts only on a specific stage (like local, integra or
live).

Contribution
------------

You are very welcome to contribute to the code, fork the repository, file
issues and especially: use the script.

Licence
-------

The code is licensed under GPL2 (see LICENSE.txt).

Contact
-------

Originally created by Johannes Haseitl - johannes@undpaul.de

undpaul GmbH - die Drupal Spezialisten

http://www.undpaul.de
