.. _integrator_upgrade_application:

==================================
Upgrading a GeoMapFish application
==================================

----------------
Preliminary work
----------------

Depending on your current version of GeoMapFish and the environment of your
target environment, some preliminary work is necessary before applying the
update steps via scripts.

GMF 1.X to GMF 2.1
==================

pip dependency
--------------
If you are updating directly from a GeoMapFish 1.X version to GeoMapFish 2.1,
and your target environment contains a new recent of pip (such as found on,
for example, Debian 9), you need to apply the following changes:

Edit ``CONST_Makefile`` (lines starting with a "+" need to be added;
lines starting with a "-" need to be removed):

.. code:: yaml

    ...
    -PIP_INSTALL_ARGS += install --trusted-host pypi.camptocamp.net
    +PIP_INSTALL_ARGS += install
    ...
    $(PIP_CMD) install \
    -    --index-url http://pypi.camptocamp.net/pypi \
         '$(PIP_VERSION)' '$(SETUPTOOL_VERSION)'
    ...

Edit ``CONST_dev-requirements.txt``:

.. code:: yaml

    ...
    -    --index-url http://pypi.camptocamp.net/pypi
    -    --find-links http://pypi.camptocamp.net/internal-pypi/index/c2cgeoportal
    ...
    -c2cgeoportal==1.6.8
    +c2cgeoportal==2.1.8
    ...

usage of intranet detection
---------------------------
If you are using automatic login via intranet detection, beware that the necessary code
has changed with GMF 2.1. See :ref:`integrator_intranet` and update your code accordingly.

-----------------------------
Updating the application code
-----------------------------

Verify that you have in your ``project.yaml.mako`` file the following ``template_vars``: ``package``, ``srid``, ``extent``, ``apache_vhost``, for example:

.. code:: yaml

   ...
   template_vars:
       package: ${'$'}{package}
       srid: ${'$'}{srid}
       extent: 489246, 78873, 837119, 296543
       apache_vhost: <apache_vhost>

Then run:

.. prompt:: bash

   make -f <makefile> update
   make -f <makefile> build

Where ``<makefile>`` is your user make file (``<user>.mk``).

------------------------
Upgrading an application
------------------------

In the ``setup.py`` be sure not to specify a ``c2cgeoportal`` version,
because it will prevent the installation of the new ``c2cgeoportal`` egg.

We consider that your makefile is named ``<instanceid>.mk``, if it is not the case
add in your Makefile ``UPGRADE_MAKE_FILE = <user.mk>``

.. note:: For Windows:

   You should add ``UPGRADE_ARGS += --windows`` in your ``<package>.mk`` file.

To upgrade run:

.. prompt:: bash

   export VERSION=<target_version>
   make -f <makefile> upgrade

.. note:: For Windows:

   You should replace ``export VERSION=<target_version>`` with
   ``SET VERSION=<target_version>``.

Where ``<makefile>`` is your user Makefile (``<user>.mk``),
``<target_version>`` is the version that you wish to upgrade to.

And follow the instructions.

.. note:: For Windows:

    If you are using Windows, you will have to execute some steps prior
    to the instructions hereunder:

    * Uninstall manually the old c2cgeoportal egg:

        ``.build/venv/Scripts/pip uninstall c2cgeoportal``

    * Clean / remove the generated files:

        ``make -f <makefile> clean``

    * Change the version in ``setup.py`` and ``CONST_requirements.txt``
      to the version you wish to install.
    * Build your application:

        ``make -f <makefile> build``

    *  Put your modifications under git revision:

        ``git add setup.py``

        ``git add CONST_requirements.txt``

        ``git commit -m "Upgrade c2cgeoportal version"``

        ``git push <remote> <branch>``

    * Follow the Windows instructions hereunder, note that you will have to use
      ``.build\venv\Scripts\...`` instead of ``.build\venv\bin\...`` in all given
      commands

--------------------
Upgrade the database
--------------------

The database will be automatically upgraded during the upgrade process.

To upgrade only the database you can use alembic directly.

The help:

.. code:: bash

   .build/venv/bin/alembic --help

Upgrade the main schema:

.. code:: bash

   .build/venv/bin/alembic --config alembic.ini upgrade head

Upgrade the static schema:

.. code:: bash

   .build/venv/bin/alembic --config alembic_static.ini upgrade head
