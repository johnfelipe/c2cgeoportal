.. _integrator_upgrade_application:

==================================
Upgrading a GeoMapFish application
==================================


From a version 2.2
~~~~~~~~~~~~~~~~~~

If you have some custom Angular components, you should first follow these instructions:
`Migration from ngeo 2.2 to ngeo 2.3
<https://github.com/camptocamp/ngeo/blob/2.3/docs/how_to_migrate_from_2.2_to_2.3.md>`_

Add a section ``managed_files:`` in the file ``project.yaml.mako``.
In this section, you must select by a regular expression the project files you need to keep, and that are
not handled by the GeoMapFish upgrade process. You can see in the GeoMapFish upgrade configuration, section
``default_project_file``, which files will get handled by the GeoMapFish upgrade process:
`for non-Docker version <https://github.com/camptocamp/c2cgeoportal/blob/${git_branch}/geoportal/c2cgeoportal_geoportal/scaffolds/nondockerupdate/%2Bdot%2Bupgrade.yaml_tmpl>`_,
`for Docker version <https://github.com/camptocamp/c2cgeoportal/blob/${git_branch}/geoportal/c2cgeoportal_geoportal/scaffolds/update/%2Bdot%2Bupgrade.yaml_tmpl>`_.
Any files in your project that are not listed in the section ``managed_files`` will be overwritten by the
upgrade process.
Here an example that may apply to your situation:

.. code:: yaml

    managed_files:
    - deploy/deploy\.cfg\.mako
    - apache/application\.wsgi\.mako

If you have no such managed files, define an empty section like this: ``managed_files: []``

If in your project you have files from the GeoMapFish templates which you did not customize, you can add
these in a section ``unmanaged_files``. This will simplify the upgrade process for you, because the update
script will then simply update these project files with the new GeoMapFish template files, and not list any
changes for these in the "diff" file, therefore making it faster for you to review the differences during
the upgrade process. The syntax for ``unmanaged_files`` is the same as for ``managed_files``.

Prepare the upgrade:

.. prompt:: bash

   git submodule deinit <package>/static/lib/cgxp/
   git rm .gitmodules
   curl https://raw.githubusercontent.com/camptocamp/c2cgeoportal/${git_branch}/docker-run > docker-run
   chmod +x docker-run
   git add docker-run project.yaml.mako
   git commit --quiet --message="Start upgrade"
   make --makefile=<user>.mk project.yaml

.. note::

   If the last command failed, you should create the ``project.yaml`` file
   from the ``project.yaml.mako`` file.

For Docker (recommended):

.. prompt:: bash

   ./docker-run --version=<version> --home --image=camptocamp/geomapfish-build ${'\\'}
       c2cupgrade --force-docker --new-makefile=Makefile --makefile=<package>.mk

For non-Docker:

.. prompt:: bash

   ./docker-run --version=<version> --home --image=camptocamp/geomapfish-build ${'\\'}
       c2cupgrade --nondocker --makefile=<user>.mk

Where ``<version>`` is the version number of GeoMapFish you want to use.
You will find available versions on `Dockerhub <https://hub.docker.com/r/camptocamp/geomapfish-build>`_.
For example, ``${major_version}.0`` is the first stable release of the version ``${major_version}``.

Then follow the instructions.

.. note:: Known issue

   If you have the following message:

   .. code:: text

      Host key verification failed.
      fatal: Could not read from remote repository.

      Please make sure you have the correct access rights
      and the repository exists.

   you can fix it by using the following command,

   .. prompt:: bash

      ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

   and then re-executing the step that failed.

From a version 2.3 and next
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Build the project file:

.. prompt:: bash

   ./docker-run make project.yaml

Change the version in the file ``.config`` to the wanted version.

If you should specify a makefile:

.. prompt:: bash

   ./docker-run --home make --makefile=<user>.mk upgrade

Also:

.. prompt:: bash

   ./docker-run --home make upgrade

Then follow the instructions.


Convert a version 2.3 to Docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add ``UPGRADE_ARGS += --force-docker --new-makefile=Makefile`` in your ``<user>.mk`` file.

.. prompt:: bash

   git add <user>.mk
   git commit --message="Start upgrade"
   ./docker-run --home make --makefile=temp.mk upgrade

Then follow the instructions.

Remove the ``UPGRADE_ARGS`` in your ``<user>.mk`` file.

.. prompt:: bash

   git add <user>.mk
   git commit --quiet --message="Finish upgrade"


Convert a version 2.3 to non-Docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add the ``apache_vhost`` in the ``template_vars`` of the ``project.yaml.mako`` file.
Add ``UPGRADE_ARGS += --nondocker --new-makefile=<package>.mk`` in the ``Makefile``.

.. prompt:: bash

   git add project.yaml.mako Makefile
   git commit --message="Start upgrade"
   ./docker-run --home make --new-makefile=<user>.mk upgrade

Then follow the instructions.

Remove the ``UPGRADE_ARGS`` in your ``Makefile``.


Upgrade the database
~~~~~~~~~~~~~~~~~~~~

The database will be automatically upgraded during the upgrade process.

To upgrade only the database you can use alembic directly.

The help:

.. prompt:: bash

   ./docker-compose-run alembic --help

Upgrade the main schema:

.. prompt:: bash

   ./docker-compose-run alembic --name=main --config=geoportal/alembic.ini upgrade head

Upgrade the static schema:

.. prompt:: bash

   ./docker-compose-run alembic --name=static --config=geoportal/alembic.ini upgrade head

.. _integrator_upgrade_application_cgxp_to_ngeo:

From CGXP to ngeo
~~~~~~~~~~~~~~~~~

Layer definition for ngeo clients is separate and different from layer
definition for CGXP clients, see :ref:`administrator_administrate_layers` for details.
To migrate the layer definitions from the CGXP structure to the ngeo
structure, you can use the script ``themev1tov2``.

.. prompt:: bash

   .build/venv/bin/themev1tov2 -i geoportal/production.ini


Text translations for ngeo clients are separate and different from text translations for CGXP clients.
To migrate your text translations from CGXP to ngeo, you can use the script ``.build/venv/bin/l10nv1tov2``.
For example, for converting french texts, in non docker context, the script can be used as follows:

.. prompt:: bash

   docker-compose up -d
   ./docker-compose-run l10nv1tov2 fr geoportal/<package>_geoportal/static/js/Proj/Lang/fr.js ${'\\'}
   geoportal/<package>_geoportal/locale/fr/LC_MESSAGES/geoportal-client.po


In a non docker project, the script can be used as follows:

.. prompt:: bash

   .build/venv/bin/l10nv1tov2 fr geoportal/<package>_geoportal/static/js/Proj/Lang/fr.js \
   geoportal/locale/fr/LC_MESSAGES/geoportal-client.po
